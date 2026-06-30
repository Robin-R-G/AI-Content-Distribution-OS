import type { LoginAttempt, AuthErrorCode } from './types';

interface RateLimitConfig {
  maxAttempts: number;
  windowMinutes: number;
  lockoutMinutes: number;
}

const DEFAULT_CONFIG: RateLimitConfig = {
  maxAttempts: 5,
  windowMinutes: 15,
  lockoutMinutes: 30,
};

export class RateLimiter {
  private attempts: Map<string, LoginAttempt[]> = new Map();
  private lockouts: Map<string, number> = new Map();
  private config: RateLimitConfig;

  constructor(config: Partial<RateLimitConfig> = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  isLocked(email: string): { locked: boolean; remainingMinutes: number } {
    const lockoutExpiry = this.lockouts.get(email);
    if (!lockoutExpiry) return { locked: false, remainingMinutes: 0 };

    const now = Date.now();
    if (now > lockoutExpiry) {
      this.lockouts.delete(email);
      this.attempts.delete(email);
      return { locked: false, remainingMinutes: 0 };
    }

    return {
      locked: true,
      remainingMinutes: Math.ceil((lockoutExpiry - now) / 60000),
    };
  }

  recordAttempt(email: string, ip: string, success: boolean): void {
    if (success) {
      this.attempts.delete(email);
      this.lockouts.delete(email);
      return;
    }

    const now = Date.now();
    const windowStart = now - this.config.windowMinutes * 60000;

    const userAttempts = this.attempts.get(email) ?? [];
    const recentAttempts = userAttempts.filter((a) => a.timestamp > windowStart);

    recentAttempts.push({
      email,
      ip,
      timestamp: now,
      success: false,
    });

    this.attempts.set(email, recentAttempts);

    if (recentAttempts.length >= this.config.maxAttempts) {
      this.lockouts.set(email, now + this.config.lockoutMinutes * 60000);
    }
  }

  getAttemptsRemaining(email: string): number {
    const now = Date.now();
    const windowStart = now - this.config.windowMinutes * 60000;
    const userAttempts = this.attempts.get(email) ?? [];
    const recentAttempts = userAttempts.filter((a) => a.timestamp > windowStart);
    return Math.max(0, this.config.maxAttempts - recentAttempts.length);
  }

  cleanup(): void {
    const now = Date.now();
    const windowStart = now - this.config.windowMinutes * 60000;

    for (const [email, attempts] of this.attempts.entries()) {
      const recent = attempts.filter((a) => a.timestamp > windowStart);
      if (recent.length === 0) {
        this.attempts.delete(email);
      } else {
        this.attempts.set(email, recent);
      }
    }

    for (const [email, expiry] of this.lockouts.entries()) {
      if (now > expiry) {
        this.lockouts.delete(email);
      }
    }
  }
}

export function getAuthErrorMessage(
  code: AuthErrorCode,
  details?: string
): string {
  const messages: Record<AuthErrorCode, string> = {
    INVALID_CREDENTIALS: 'Invalid email or password',
    ACCOUNT_LOCKED:
      'Account is temporarily locked due to too many failed attempts. Please try again later.',
    EMAIL_NOT_VERIFIED:
      'Please verify your email address before signing in.',
    MFA_REQUIRED: 'Please enter your two-factor authentication code.',
    MFA_INVALID: 'Invalid authentication code. Please try again.',
    RATE_LIMITED: 'Too many requests. Please wait a moment and try again.',
    INVALID_INPUT: 'Please check your input and try again.',
    USER_EXISTS: 'An account with this email already exists.',
    WEAK_PASSWORD: 'Password does not meet security requirements.',
    TOKEN_EXPIRED: 'Your session has expired. Please sign in again.',
    TOKEN_INVALID: 'Invalid authentication token.',
    OAUTH_FAILED: 'Authentication with external provider failed.',
    SERVER_ERROR: 'Something went wrong. Please try again later.',
  };

  return messages[code] ?? 'An unexpected error occurred.';
}
