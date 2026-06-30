export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  avatarUrl?: string;
  emailVerified: boolean;
  createdAt: string;
  updatedAt: string;
  lastLoginAt?: string;
  metadata?: Record<string, unknown>;
}

export interface Session {
  id: string;
  userId: string;
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
  createdAt: string;
  ipAddress?: string;
  userAgent?: string;
  isActive: boolean;
}

export interface Token {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
}

export type OAuthProvider = 'google' | 'apple' | 'github';

export interface MFAConfig {
  enabled: boolean;
  secret?: string;
  backupCodes?: string[];
  verifiedAt?: string;
}

export interface AuthConfig {
  supabaseUrl: string;
  supabaseAnonKey: string;
  jwtSecret: string;
  sessionDuration: number;
  maxLoginAttempts: number;
  lockoutDurationMinutes: number;
  mfaEnabled: boolean;
  oauthProviders: OAuthProvider[];
  passwordMinLength: number;
  passwordRequireUppercase: boolean;
  passwordRequireLowercase: boolean;
  passwordRequireDigit: boolean;
  passwordRequireSpecial: boolean;
}

export interface LoginRequest {
  email: string;
  password: string;
  mfaCode?: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

export interface AuthResponse {
  user: User;
  session: Session;
  token: Token;
  mfaRequired?: boolean;
}

export interface PasswordResetRequest {
  email: string;
}

export interface TokenRefreshRequest {
  refreshToken: string;
}

export interface LoginAttempt {
  email: string;
  ip: string;
  timestamp: number;
  success: boolean;
}

export interface InputValidationError {
  field: string;
  message: string;
}

export interface AuthError {
  code: AuthErrorCode;
  message: string;
}

export type AuthErrorCode =
  | 'INVALID_CREDENTIALS'
  | 'ACCOUNT_LOCKED'
  | 'EMAIL_NOT_VERIFIED'
  | 'MFA_REQUIRED'
  | 'MFA_INVALID'
  | 'RATE_LIMITED'
  | 'INVALID_INPUT'
  | 'USER_EXISTS'
  | 'WEAK_PASSWORD'
  | 'TOKEN_EXPIRED'
  | 'TOKEN_INVALID'
  | 'OAUTH_FAILED'
  | 'SERVER_ERROR';
