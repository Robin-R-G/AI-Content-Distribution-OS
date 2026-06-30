import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  User,
  Session,
  Token,
  OAuthProvider,
  AuthConfig,
  AuthResponse,
  AuthErrorCode,
} from './types';
import {
  validateInput,
  loginSchema,
  registerSchema,
  mfaCodeSchema,
  passwordResetSchema,
  sanitizeInput,
} from './validation';
import { RateLimiter, getAuthErrorMessage } from './rate-limiter';

export class AuthService {
  private supabase: SupabaseClient;
  private config: AuthConfig;
  private rateLimiter: RateLimiter;

  constructor(config: AuthConfig) {
    this.config = config;
    this.supabase = createClient(config.supabaseUrl, config.supabaseAnonKey);
    this.rateLimiter = new RateLimiter({
      maxAttempts: config.maxLoginAttempts,
      lockoutMinutes: config.lockoutDurationMinutes,
    });
  }

  async register(
    email: string,
    password: string,
    firstName: string,
    lastName: string
  ): Promise<AuthResponse> {
    const validation = validateInput(registerSchema, {
      email,
      password,
      firstName,
      lastName,
    });

    if (!validation.success) {
      throw this.createError('INVALID_INPUT', validation.errors.join(', '));
    }

    const { email: cleanEmail, password: cleanPassword } = validation.data;

    const lockStatus = this.rateLimiter.isLocked(cleanEmail);
    if (lockStatus.locked) {
      throw this.createError(
        'ACCOUNT_LOCKED',
        `Account locked. Try again in ${lockStatus.remainingMinutes} minutes.`
      );
    }

    const { data: existingUser } = await this.supabase
      .from('users')
      .select('id')
      .eq('email', cleanEmail)
      .single();

    if (existingUser) {
      throw this.createError('USER_EXISTS');
    }

    const { data, error } = await this.supabase.auth.signUp({
      email: cleanEmail,
      password: cleanPassword,
      options: {
        data: {
          firstName: sanitizeInput(validation.data.firstName),
          lastName: sanitizeInput(validation.data.lastName),
        },
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    });

    if (error) {
      if (error.message.includes('already registered')) {
        throw this.createError('USER_EXISTS');
      }
      throw this.createError('SERVER_ERROR');
    }

    if (!data.user || !data.session) {
      return {
        user: this.mapUser(data.user!),
        session: this.createEmptySession(data.user?.id ?? ''),
        token: this.createEmptyToken(),
      };
    }

    return {
      user: this.mapUser(data.user),
      session: this.mapSession(data.session),
      token: this.mapToken(data.session),
    };
  }

  async login(
    email: string,
    password: string,
    ip?: string
  ): Promise<AuthResponse> {
    const validation = validateInput(loginSchema, { email, password });
    if (!validation.success) {
      throw this.createError('INVALID_INPUT', validation.errors.join(', '));
    }

    const { email: cleanEmail, password: cleanPassword } = validation.data;

    const lockStatus = this.rateLimiter.isLocked(cleanEmail);
    if (lockStatus.locked) {
      throw this.createError(
        'ACCOUNT_LOCKED',
        `Account locked. Try again in ${lockStatus.remainingMinutes} minutes.`
      );
    }

    const { data, error } = await this.supabase.auth.signInWithPassword({
      email: cleanEmail,
      password: cleanPassword,
    });

    if (error) {
      this.rateLimiter.recordAttempt(cleanEmail, ip ?? 'unknown', false);
      const remaining = this.rateLimiter.getAttemptsRemaining(cleanEmail);

      if (remaining === 0) {
        throw this.createError('ACCOUNT_LOCKED');
      }

      if (
        error.message.includes('Invalid login credentials') ||
        error.message.includes('Email not confirmed')
      ) {
        throw this.createError('INVALID_CREDENTIALS');
      }

      throw this.createError('SERVER_ERROR');
    }

    if (!data.user.email_confirmed_at) {
      throw this.createError('EMAIL_NOT_VERIFIED');
    }

    this.rateLimiter.recordAttempt(cleanEmail, ip ?? 'unknown', true);

    if (
      this.config.mfaEnabled &&
      data.user.factors &&
      data.user.factors.length > 0
    ) {
      return {
        user: this.mapUser(data.user),
        session: this.mapSession(data.session),
        token: this.mapToken(data.session),
        mfaRequired: true,
      };
    }

    return {
      user: this.mapUser(data.user),
      session: this.mapSession(data.session),
      token: this.mapToken(data.session),
    };
  }

  async logout(accessToken: string): Promise<void> {
    const client = this.createClientWithToken(accessToken);
    const { error } = await client.auth.signOut({ scope: 'local' });
    if (error) throw this.createError('SERVER_ERROR');
  }

  async refreshToken(refreshToken: string): Promise<Token> {
    if (!refreshToken || refreshToken.length < 10) {
      throw this.createError('TOKEN_INVALID');
    }

    const { data, error } = await this.supabase.auth.refreshSession({
      refresh_token: refreshToken,
    });

    if (error || !data.session) {
      throw this.createError('TOKEN_EXPIRED');
    }

    return this.mapToken(data.session);
  }

  async resetPassword(email: string): Promise<void> {
    const validation = validateInput(passwordResetSchema, { email });
    if (!validation.success) {
      throw this.createError('INVALID_INPUT', validation.errors.join(', '));
    }

    const { error } = await this.supabase.auth.resetPasswordForEmail(
      validation.data.email,
      {
        redirectTo: `${window.location.origin}/auth/reset-password`,
      }
    );

    if (error) throw this.createError('SERVER_ERROR');
  }

  async verifyMFA(userId: string, code: string): Promise<boolean> {
    const validation = validateInput(mfaCodeSchema, code);
    if (!validation.success) {
      throw this.createError('MFA_INVALID');
    }

    const { data: factors } = await this.supabase.auth.mfa.list();
    const totpFactor = factors?.find((f) => f.factor_type === 'totp');

    if (!totpFactor) {
      throw this.createError('SERVER_ERROR', 'MFA not configured');
    }

    const { error: challengeError } = await this.supabase.auth.mfa.challenge({
      factorId: totpFactor.id,
    });

    if (challengeError) throw this.createError('SERVER_ERROR');

    const { error: verifyError } = await this.supabase.auth.mfa.verify({
      factorId: totpFactor.id,
      code: validation.data,
    });

    if (verifyError) {
      throw this.createError('MFA_INVALID');
    }

    return true;
  }

  async oauthLogin(provider: OAuthProvider): Promise<void> {
    const trustedProviders: OAuthProvider[] = ['google', 'apple', 'github'];
    if (!trustedProviders.includes(provider)) {
      throw this.createError('OAUTH_FAILED', 'Unsupported provider');
    }

    const { error } = await this.supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        skipBrowserRedirect: false,
      },
    });

    if (error) throw this.createError('OAUTH_FAILED');
  }

  async getCurrentUser(accessToken: string): Promise<User | null> {
    if (!accessToken) return null;

    const client = this.createClientWithToken(accessToken);
    const { data, error } = await client.auth.getUser();

    if (error || !data.user) return null;

    return this.mapUser(data.user);
  }

  async verifyEmail(token: string, email: string): Promise<void> {
    if (!token || !email) {
      throw this.createError('INVALID_INPUT');
    }

    const { error } = await this.supabase.auth.verifyOtp({
      email: sanitizeInput(email),
      token: sanitizeInput(token),
      type: 'signup',
    });

    if (error) throw this.createError('SERVER_ERROR');
  }

  private createClientWithToken(accessToken: string): SupabaseClient {
    return createClient(this.config.supabaseUrl, this.config.supabaseAnonKey, {
      global: {
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    });
  }

  private mapUser(supabaseUser: Record<string, unknown>): User {
    const u = supabaseUser as {
      id: string;
      email: string;
      user_metadata?: Record<string, unknown>;
      email_confirmed_at?: string;
      created_at: string;
      updated_at: string;
      last_sign_in_at?: string;
      factors?: unknown[];
    };

    return {
      id: u.id,
      email: u.email,
      firstName: (u.user_metadata?.firstName as string) ?? '',
      lastName: (u.user_metadata?.lastName as string) ?? '',
      avatarUrl: u.user_metadata?.avatarUrl as string | undefined,
      emailVerified: !!u.email_confirmed_at,
      createdAt: u.created_at,
      updatedAt: u.updated_at,
      lastLoginAt: u.last_sign_in_at,
    };
  }

  private mapSession(supabaseSession: Record<string, unknown>): Session {
    const s = supabaseSession as {
      access_token: string;
      refresh_token: string;
      expires_in: number;
      expires_at?: number;
      user?: Record<string, unknown>;
    };

    const expiresAt = s.expires_at
      ? new Date(s.expires_at * 1000).toISOString()
      : new Date(Date.now() + s.expires_in * 1000).toISOString();

    return {
      id: crypto.randomUUID(),
      userId: (s.user as Record<string, unknown>)?.id as string ?? '',
      accessToken: s.access_token,
      refreshToken: s.refresh_token,
      expiresAt,
      createdAt: new Date().toISOString(),
      isActive: true,
    };
  }

  private mapToken(supabaseSession: Record<string, unknown>): Token {
    const s = supabaseSession as {
      access_token: string;
      refresh_token: string;
      expires_in: number;
    };

    return {
      accessToken: s.access_token,
      refreshToken: s.refresh_token,
      expiresIn: s.expires_in,
      tokenType: 'Bearer',
    };
  }

  private createEmptySession(userId: string): Session {
    return {
      id: crypto.randomUUID(),
      userId,
      accessToken: '',
      refreshToken: '',
      expiresAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      isActive: false,
    };
  }

  private createEmptyToken(): Token {
    return {
      accessToken: '',
      refreshToken: '',
      expiresIn: 0,
      tokenType: 'Bearer',
    };
  }

  private createError(code: AuthErrorCode, details?: string): AuthError {
    return {
      code,
      message: getAuthErrorMessage(code, details),
    };
  }
}

interface AuthError {
  code: AuthErrorCode;
  message: string;
}
