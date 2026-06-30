# Authentication Flow Diagrams

## Registration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Supabase │               │
│  │  (App)   │     │ Gateway  │     │   Auth   │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ 1. POST /auth/register         │                       │
│       │ {email, password, name}        │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 2. Validate    │                       │
│       │                │ (rate limit,   │                       │
│       │                │  email format) │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 3. Create User │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 4. Send Email  │                       │
│       │                │ Confirmation   │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 5. Return {user, session}     │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 6. User clicks confirmation link                       │
│       │───────────────────────────────────────►│               │
│       │                │                │                       │
│       │                │ 7. Verify Token│                       │
│       │                │◄───────────────│                       │
│       │                │                │                       │
│       │ 8. Account Activated           │                       │
│       │◄───────────────│                │                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Registration Implementation

```typescript
// lib/auth/registration.ts
interface RegisterRequest {
  email: string;
  password: string;
  full_name: string;
  organization_name?: string;
}

async function register(request: RegisterRequest): Promise<AuthResponse> {
  // 1. Validate input
  const validated = registrationSchema.validate(request);

  // 2. Check rate limit
  const rateLimit = await checkRateLimit('auth', request.email);
  if (!rateLimit.allowed) {
    throw new RateLimitError('Too many registration attempts');
  }

  // 3. Check existing user
  const existingUser = await supabase.auth.getUserByEmail(request.email);
  if (existingUser) {
    throw new ConflictError('Email already registered');
  }

  // 4. Create user with Supabase Auth
  const { data: authData, error: authError } = await supabase.auth.signUp({
    email: request.email,
    password: request.password,
    options: {
      data: {
        full_name: request.full_name
      }
    }
  });

  if (authError) throw authError;

  // 5. Create user profile
  await db.users.create({
    id: authData.user!.id,
    email: request.email,
    full_name: request.full_name
  });

  // 6. Create default organization if provided
  if (request.organization_name) {
    const org = await createOrganization({
      name: request.organization_name,
      owner_id: authData.user!.id
    });

    // Add user as owner
    await db.organization_members.create({
      organization_id: org.id,
      user_id: authData.user!.id,
      role: 'owner'
    });
  }

  // 7. Send confirmation email
  await sendEmail({
    to: request.email,
    template: 'welcome',
    data: { name: request.full_name }
  });

  // 8. Track registration
  await analytics.track('user_registered', {
    user_id: authData.user!.id,
    method: 'email'
  });

  return {
    user: authData.user!,
    session: authData.session!
  };
}
```

## Login Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      LOGIN FLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Supabase │               │
│  │  (App)   │     │ Gateway  │     │   Auth   │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ 1. POST /auth/login            │                       │
│       │ {email, password}              │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 2. Rate Limit  │                       │
│       │                │ Check          │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 3. Authenticate│                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 4. Check MFA   │                       │
│       │                │◄───────────────│                       │
│       │                │                │                       │
│       │ 5. Return {session, mfa_required}                      │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ [If MFA Required]              │                       │
│       │                │                │                       │
│       │ 6. POST /auth/mfa/verify       │                       │
│       │ {code}                         │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 7. Verify MFA  │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 8. Return {session}            │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 9. Store tokens,                │                       │
│       │    redirect to dashboard        │                       │
│       │───────────────────────────────────────►│               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Login Implementation

```typescript
// lib/auth/login.ts
interface LoginRequest {
  email: string;
  password: string;
  mfa_code?: string;
}

async function login(request: LoginRequest): Promise<AuthResponse> {
  // 1. Rate limit check
  const rateLimit = await checkRateLimit('auth-login', request.email);
  if (!rateLimit.allowed) {
    throw new RateLimitError('Too many login attempts');
  }

  // 2. Authenticate with Supabase
  const { data, error } = await supabase.auth.signInWithPassword({
    email: request.email,
    password: request.password
  });

  if (error) {
    await incrementFailedAttempts(request.email);
    throw new UnauthorizedError('Invalid credentials');
  }

  // 3. Check if MFA is enabled
  const user = await db.users.findById(data.user.id);
  if (user.mfa_enabled && !request.mfa_code) {
    return {
      user: data.user,
      session: null,
      mfa_required: true,
      mfa_session: data.session.access_token
    };
  }

  // 4. Verify MFA if provided
  if (user.mfa_enabled && request.mfa_code) {
    const mfaValid = await verifyMFACode(user.id, request.mfa_code);
    if (!mfaValid) {
      throw new UnauthorizedError('Invalid MFA code');
    }
  }

  // 5. Create session
  const session = await createSession(data.user.id, {
    ip: getClientIp(),
    userAgent: getUserAgent(),
    lastActivity: Date.now()
  });

  // 6. Track login
  await analytics.track('user_login', {
    user_id: data.user.id,
    method: 'email',
    mfa_used: !!request.mfa_code
  });

  // 7. Reset failed attempts
  await resetFailedAttempts(request.email);

  return {
    user: data.user,
    session: data.session
  };
}
```

## OAuth Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     OAUTH FLOW                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Provider │               │
│  │  (App)   │     │ Gateway  │     │ (Google) │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ 1. POST /auth/oauth/google     │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │ 2. Redirect to Google OAuth    │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 3. User authorizes            │                       │
│       │───────────────────────────────────────►│               │
│       │                │                │                       │
│       │ 4. Redirect back with code    │                       │
│       │◄───────────────────────────────────────│               │
│       │                │                │                       │
│       │ 5. POST /auth/oauth/callback   │                       │
│       │ {code, state}                 │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 6. Exchange    │                       │
│       │                │ code for token │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 7. Get user    │                       │
│       │                │ info           │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 8. Create/Find │                       │
│       │                │ user           │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 9. Return {user, session}     │                       │
│       │◄───────────────│                │                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### OAuth Implementation

```typescript
// lib/auth/oauth.ts
interface OAuthProvider {
  name: string;
  authorizeUrl: string;
  tokenUrl: string;
  userInfoUrl: string;
  scopes: string[];
  clientId: string;
  clientSecret: string;
}

const providers: Record<string, OAuthProvider> = {
  google: {
    name: 'google',
    authorizeUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    userInfoUrl: 'https://www.googleapis.com/oauth2/v2/userinfo',
    scopes: ['openid', 'email', 'profile'],
    clientId: process.env.GOOGLE_CLIENT_ID!,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET!
  },
  github: {
    name: 'github',
    authorizeUrl: 'https://github.com/login/oauth/authorize',
    tokenUrl: 'https://github.com/login/oauth/access_token',
    userInfoUrl: 'https://api.github.com/user',
    scopes: ['user:email'],
    clientId: process.env.GITHUB_CLIENT_ID!,
    clientSecret: process.env.GITHUB_CLIENT_SECRET!
  }
};

async function getOAuthRedirectUrl(provider: string): Promise<string> {
  const config = providers[provider];
  if (!config) throw new Error('Unknown provider');

  const state = crypto.randomBytes(32).toString('hex');
  await cache.set(`oauth:state:${state}`, provider, 600); // 10 minutes

  const params = new URLSearchParams({
    client_id: config.clientId,
    redirect_uri: `${process.env.APP_URL}/auth/callback`,
    response_type: 'code',
    scope: config.scopes.join(' '),
    state
  });

  return `${config.authorizeUrl}?${params.toString()}`;
}

async function handleOAuthCallback(
  provider: string,
  code: string,
  state: string
): Promise<AuthResponse> {
  // 1. Validate state
  const savedProvider = await cache.get(`oauth:state:${state}`);
  if (!savedProvider || savedProvider !== provider) {
    throw new Error('Invalid OAuth state');
  }
  await cache.del(`oauth:state:${state}`);

  const config = providers[provider];

  // 2. Exchange code for token
  const tokenResponse = await fetch(config.tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      code,
      redirect_uri: `${process.env.APP_URL}/auth/callback`
    })
  });

  const { access_token } = await tokenResponse.json();

  // 3. Get user info
  const userInfoResponse = await fetch(config.userInfoUrl, {
    headers: { Authorization: `Bearer ${access_token}` }
  });

  const userInfo = await userInfoResponse.json();

  // 4. Find or create user
  let user = await db.users.findByEmail(userInfo.email);

  if (!user) {
    user = await db.users.create({
      email: userInfo.email,
      full_name: userInfo.name,
      avatar_url: userInfo.picture
    });

    // Create default organization
    const org = await createOrganization({
      name: `${userInfo.name}'s Organization`,
      owner_id: user.id
    });

    await db.organization_members.create({
      organization_id: org.id,
      user_id: user.id,
      role: 'owner'
    });
  }

  // 5. Link OAuth account if not already linked
  const existingConnection = await db.oauth_connections.findOne({
    user_id: user.id,
    provider
  });

  if (!existingConnection) {
    await db.oauth_connections.create({
      user_id: user.id,
      provider,
      provider_user_id: userInfo.id,
      access_token
    });
  }

  // 6. Create session
  const session = await supabase.auth.signInWithOAuth({
    provider: provider as any,
    options: {
      redirectTo: `${process.env.APP_URL}/auth/callback`
    }
  });

  return {
    user,
    session: session.data.session
  };
}
```

## Token Refresh Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   TOKEN REFRESH FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Supabase │               │
│  │  (App)   │     │ Gateway  │     │   Auth   │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ 1. Token expires (401)         │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │ 2. POST /auth/refresh          │                       │
│       │ {refresh_token}               │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 3. Validate    │                       │
│       │                │ refresh token  │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 4. Issue new   │                       │
│       │                │ token pair     │                       │
│       │                │◄───────────────│                       │
│       │                │                │                       │
│       │ 5. Return {access_token,       │                       │
│       │    refresh_token}              │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 6. Update tokens in storage   │                       │
│       │───────────────────────────────────────►│               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Token Refresh Implementation

```typescript
// lib/auth/token-refresh.ts
async function refreshToken(refreshToken: string): Promise<TokenPair> {
  // 1. Validate refresh token
  const tokenData = await validateRefreshToken(refreshToken);
  if (!tokenData) {
    throw new UnauthorizedError('Invalid refresh token');
  }

  // 2. Check if token is revoked
  const isRevoked = await isTokenRevoked(refreshToken);
  if (isRevoked) {
    throw new UnauthorizedError('Refresh token revoked');
  }

  // 3. Get user
  const user = await db.users.findById(tokenData.user_id);
  if (!user) {
    throw new UnauthorizedError('User not found');
  }

  // 4. Issue new token pair
  const newTokens = await supabase.auth.admin.generateLink({
    type: 'magiclink',
    user_id: user.id
  });

  // 5. Revoke old refresh token
  await revokeRefreshToken(refreshToken);

  // 6. Store new refresh token
  await storeRefreshToken(newTokens.properties.refresh_token, {
    user_id: user.id,
    expires_at: Date.now() + 7 * 24 * 60 * 60 * 1000 // 7 days
  });

  return {
    access_token: newTokens.properties.access_token,
    refresh_token: newTokens.properties.refresh_token,
    expires_in: 3600
  };
}

// Auto-refresh interceptor
async function autoRefreshToken(
  request: Request,
  token: string
): Promise<Request> {
  const decoded = jwt.decode(token) as any;
  const expiresAt = decoded.exp * 1000;
  const now = Date.now();

  // Refresh if less than 5 minutes until expiry
  if (expiresAt - now < 5 * 60 * 1000) {
    const refreshToken = await getStoredRefreshToken(decoded.sub);
    if (refreshToken) {
      const newTokens = await refreshToken(refreshToken);
      return new Request(request.url, {
        ...request,
        headers: {
          ...request.headers,
          Authorization: `Bearer ${newTokens.access_token}`
        }
      });
    }
  }

  return request;
}
```

## MFA Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      MFA FLOW                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Supabase │               │
│  │  (App)   │     │ Gateway  │     │   Auth   │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ [Setup MFA]   │                │                       │
│       │                │                │                       │
│       │ 1. POST /auth/mfa/enable       │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 2. Generate    │                       │
│       │                │ TOTP secret    │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 3. Return {secret, qr_code}  │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 4. User scans QR code        │                       │
│       │───────────────────────────────────────►│               │
│       │                │                │                       │
│       │ 5. POST /auth/mfa/verify       │                       │
│       │ {code}                         │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 6. Verify TOTP │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 7. MFA enabled                 │                       │
│       │◄───────────────│                │                       │
│                                                                 │
│  [Login with MFA]                                              │
│                                                                 │
│       │ 1. POST /auth/login             │                       │
│       │ {email, password}              │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │ 2. Return {mfa_required: true} │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 3. POST /auth/mfa/verify       │                       │
│       │ {code, mfa_session}           │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 4. Verify TOTP │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 5. Return {session}           │                       │
│       │◄───────────────│                │                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### MFA Implementation

```typescript
// lib/auth/mfa.ts
import speakeasy from 'speakeasy';
import QRCode from 'qrcode';

async function enableMFA(userId: string): Promise<MFASetup> {
  // 1. Generate TOTP secret
  const secret = speakeasy.generateSecret({
    name: `ContentOS:${userId}`,
    issuer: 'ContentOS'
  });

  // 2. Store secret temporarily
  await cache.set(`mfa:pending:${userId}`, secret.base32, 600); // 10 minutes

  // 3. Generate QR code
  const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url!);

  return {
    secret: secret.base32,
    qr_code: qrCodeUrl
  };
}

async function verifyMFASetup(userId: string, code: string): Promise<void> {
  // 1. Get pending secret
  const secret = await cache.get<string>(`mfa:pending:${userId}`);
  if (!secret) {
    throw new Error('MFA setup session expired');
  }

  // 2. Verify code
  const verified = speakeasy.totp.verify({
    secret,
    encoding: 'base32',
    token: code,
    window: 1
  });

  if (!verified) {
    throw new Error('Invalid MFA code');
  }

  // 3. Enable MFA for user
  await db.users.update(userId, {
    mfa_enabled: true,
    mfa_secret: secret
  });

  // 4. Generate backup codes
  const backupCodes = generateBackupCodes();
  await storeBackupCodes(userId, backupCodes);

  // 5. Clean up
  await cache.del(`mfa:pending:${userId}`);

  return { backup_codes: backupCodes };
}

async function verifyMFACode(userId: string, code: string): Promise<boolean> {
  const user = await db.users.findById(userId);
  if (!user.mfa_enabled || !user.mfa_secret) {
    return false;
  }

  // Check if it's a backup code
  if (code.length === 8) {
    return verifyBackupCode(userId, code);
  }

  // Verify TOTP
  return speakeasy.totp.verify({
    secret: user.mfa_secret,
    encoding: 'base32',
    token: code,
    window: 1
  });
}

function generateBackupCodes(): string[] {
  const codes: string[] = [];
  for (let i = 0; i < 10; i++) {
    codes.push(crypto.randomBytes(4).toString('hex').toUpperCase());
  }
  return codes;
}
```

## Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  PASSWORD RESET FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Client  │────►│   API    │────►│ Supabase │               │
│  │  (App)   │     │ Gateway  │     │   Auth   │               │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       │                │                │                       │
│       │ 1. POST /auth/forgot-password  │                       │
│       │ {email}                        │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 2. Rate limit  │                       │
│       │                │ check          │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 3. Generate    │                       │
│       │                │ reset token    │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 4. Send reset  │                       │
│       │                │ email          │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 5. Return success             │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ [User clicks link]            │                       │
│       │                │                │                       │
│       │ 6. GET /auth/reset-password?token=xxx                  │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 7. Validate    │                       │
│       │                │ token          │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 8. Return reset form         │                       │
│       │◄───────────────│                │                       │
│       │                │                │                       │
│       │ 9. POST /auth/reset-password  │                       │
│       │ {token, new_password}        │                       │
│       │───────────────►│                │                       │
│       │                │                │                       │
│       │                │ 10. Update     │                       │
│       │                │ password       │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │                │ 11. Invalidate │                       │
│       │                │ all sessions   │                       │
│       │                │───────────────►│                       │
│       │                │                │                       │
│       │ 12. Return success           │                       │
│       │◄───────────────│                │                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Password Reset Implementation

```typescript
// lib/auth/password-reset.ts
async function requestPasswordReset(email: string): Promise<void> {
  // 1. Rate limit
  const rateLimit = await checkRateLimit('password-reset', email);
  if (!rateLimit.allowed) {
    throw new RateLimitError('Too many reset attempts');
  }

  // 2. Find user
  const user = await db.users.findByEmail(email);
  if (!user) {
    // Don't reveal if user exists
    return;
  }

  // 3. Generate reset token
  const token = crypto.randomBytes(32).toString('hex');
  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

  // 4. Store token
  await db.password_resets.create({
    user_id: user.id,
    token: hashedToken,
    expires_at: Date.now() + 60 * 60 * 1000 // 1 hour
  });

  // 5. Send email
  await sendEmail({
    to: email,
    template: 'password-reset',
    data: {
      reset_url: `${process.env.APP_URL}/auth/reset-password?token=${token}`
    }
  });

  // 6. Track event
  await analytics.track('password_reset_requested', { user_id: user.id });
}

async function resetPassword(
  token: string,
  newPassword: string
): Promise<void> {
  // 1. Hash token
  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

  // 2. Find reset record
  const resetRecord = await db.password_resets.findOne({
    token: hashedToken,
    expires_at: { $gt: Date.now() }
  });

  if (!resetRecord) {
    throw new Error('Invalid or expired reset token');
  }

  // 3. Update password
  await supabase.auth.admin.updateUserById(resetRecord.user_id, {
    password: newPassword
  });

  // 4. Delete reset record
  await db.password_resets.delete(resetRecord.id);

  // 5. Invalidate all sessions
  await invalidateAllSessions(resetRecord.user_id);

  // 6. Track event
  await analytics.track('password_reset_completed', {
    user_id: resetRecord.user_id
  });
}
```

## Session Management

### Session Structure

```typescript
interface Session {
  id: string;
  user_id: string;
  ip_address: string;
  user_agent: string;
  last_activity: number;
  created_at: number;
  expires_at: number;
  mfa_verified: boolean;
}

// Session storage in Redis
const sessionSchema = {
  id: { type: 'string', primary: true },
  user_id: { type: 'string', index: true },
  ip_address: { type: 'string' },
  user_agent: { type: 'string' },
  last_activity: { type: 'number' },
  created_at: { type: 'number' },
  expires_at: { type: 'number' },
  mfa_verified: { type: 'boolean' }
};
```

### Session Operations

```typescript
// lib/auth/session-manager.ts
class SessionManager {
  private readonly MAX_SESSIONS = 5;
  private readonly SESSION_TTL = 7 * 24 * 60 * 60; // 7 days

  async createSession(
    userId: string,
    data: Partial<Session>
  ): Promise<string> {
    // Check max sessions
    const existingSessions = await this.getUserSessions(userId);
    if (existingSessions.length >= this.MAX_SESSIONS) {
      // Remove oldest session
      const oldest = existingSessions.sort(
        (a, b) => a.last_activity - b.last_activity
      )[0];
      await this.destroySession(oldest.id);
    }

    const sessionId = crypto.randomBytes(32).toString('hex');
    const session: Session = {
      id: sessionId,
      user_id: userId,
      ip_address: data.ip_address || '',
      user_agent: data.user_agent || '',
      last_activity: Date.now(),
      created_at: Date.now(),
      expires_at: Date.now() + this.SESSION_TTL * 1000,
      mfa_verified: data.mfa_verified || false
    };

    await cache.set(`session:${sessionId}`, session, this.SESSION_TTL);
    return sessionId;
  }

  async getSession(sessionId: string): Promise<Session | null> {
    const session = await cache.get<Session>(`session:${sessionId}`);
    if (!session) return null;

    if (session.expires_at < Date.now()) {
      await this.destroySession(sessionId);
      return null;
    }

    // Update last activity
    session.last_activity = Date.now();
    await cache.set(`session:${sessionId}`, session, this.SESSION_TTL);

    return session;
  }

  async destroySession(sessionId: string): Promise<void> {
    await cache.del(`session:${sessionId}`);
  }

  async destroyAllSessions(userId: string): Promise<void> {
    const sessions = await this.getUserSessions(userId);
    for (const session of sessions) {
      await this.destroySession(session.id);
    }
  }

  async getUserSessions(userId: string): Promise<Session[]> {
    const keys = await cache.keys('session:*');
    const sessions: Session[] = [];

    for (const key of keys) {
      const session = await cache.get<Session>(key);
      if (session && session.user_id === userId) {
        sessions.push(session);
      }
    }

    return sessions;
  }
}
```
