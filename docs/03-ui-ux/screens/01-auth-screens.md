# Authentication Screens — AI Content Distribution OS

~15 screens covering the full auth lifecycle.

---

## 01. Splash Screen

### Purpose
App initialization, brand impression, token validation.

### Layout
Full-screen centered content. Logo animates in (scale + fade). Loading indicator below.

### Key Components
- Animated app logo (Lottie or Rive)
- App name text
- Circular progress indicator
- Version number (bottom)

### Navigation
- On success: → Dashboard (or onboarding for new users)
- On error: → Login

### States
| State | Behavior |
|-------|----------|
| Loading | Logo + spinner visible |
| Success | Fade transition to next screen |
| Error | Show error toast, redirect to Login |

### Responsive
- Full screen on all platforms
- Logo scales proportionally

### Accessibility
- Semantic label: "Loading application"
- No interactive elements

---

## 02. Onboarding — Slide 1

### Purpose
Introduce value proposition: AI-powered content creation.

### Layout
Full-screen illustration (top 50%), text block (bottom 50%). Page indicators. Skip button top-right.

### Key Components
- Illustration (vector art of AI content creation)
- Heading: "Create Smarter with AI"
- Subheading: "Generate captions, hashtags, and visuals in seconds"
- Page indicator (1/3)
- Skip button
- Next button (primary)

### Navigation
- Skip → Login
- Next → Onboarding Slide 2
- Swipe left → Onboarding Slide 2

### States
| State | Behavior |
|-------|----------|
| Default | Illustration + text visible |
| Transitioning | Slide animation between pages |

### Responsive
- Mobile: Full screen, stacked layout
- Tablet/Desktop: Centered card (max-width 480px)

### Accessibility
- Semantic labels on illustration
- Skip button labeled "Skip onboarding"

---

## 03. Onboarding — Slide 2

### Purpose
Introduce scheduling and publishing features.

### Layout
Same structure as Slide 1.

### Key Components
- Illustration (calendar with scheduled posts)
- Heading: "Schedule Everywhere"
- Subheading: "Plan and auto-publish to all platforms from one place"
- Page indicator (2/3)
- Skip button
- Next button (primary)

### Navigation
- Skip → Login
- Next → Onboarding Slide 3
- Back → Onboarding Slide 1

### States
Same as Slide 1.

### Responsive
Same as Slide 1.

### Accessibility
Same as Slide 1.

---

## 04. Onboarding — Slide 3

### Purpose
Introduce analytics and insights.

### Layout
Same structure as Slide 1.

### Key Components
- Illustration (charts and graphs)
- Heading: "Grow with Insights"
- Subheading: "Track performance and discover what works"
- Page indicator (3/3)
- Skip button
- Get Started button (primary, replaces Next)

### Navigation
- Get Started → Login
- Back → Onboarding Slide 2

### States
Same as Slide 1.

### Responsive
Same as Slide 1.

### Accessibility
Same as Slide 1.

---

## 05. Login — Email

### Purpose
Authenticate existing users via email/password.

### Layout
Split layout (desktop): Left = brand panel with illustration, Right = form. Stacked on mobile with illustration hidden.

### Key Components
- Email input (with icon)
- Password input (with visibility toggle)
- Remember me checkbox
- Forgot password link
- Login button (primary, full-width)
- Divider with "or"
- Social login buttons row (Google, Apple, Microsoft)
- Sign up link: "Don't have an account? Sign up"

### Navigation
- Login success → Dashboard
- Forgot password → Forgot Password screen
- Sign up → Register screen
- Social button → OAuth flow (respective provider)

### States
| State | Behavior |
|-------|----------|
| Default | Empty form |
| Loading | Button spinner, inputs disabled |
| Success | Redirect to dashboard |
| Error (invalid credentials) | Inline error below password |
| Error (account locked) | Alert dialog |
| Error (email not verified) | Redirect to Email Verification |

### Responsive
- Desktop: Split layout
- Mobile: Stacked, illustration compressed or hidden

### Accessibility
- Labels on all inputs
- Error messages announced via `Semantics`
- Keyboard: Enter submits form

---

## 06. Login — Phone

### Purpose
Authenticate via phone number + OTP.

### Layout
Same split layout as email login.

### Key Components
- Country code picker (dropdown)
- Phone number input
- Send OTP button (primary)
- OTP input (6-digit, auto-advance)
- Verify button
- Link to email login: "Login with email"
- Sign up link

### Navigation
- OTP sent → OTP input appears inline
- Verify success → Dashboard (or MFA if enabled)
- Sign up → Register

### States
| State | Behavior |
|-------|----------|
| Default | Phone input visible |
| OTP sent | OTP input replaces phone input, countdown timer |
| Loading | Button spinner |
| Success | Redirect to dashboard |
| Error (invalid phone) | Inline error |
| Error (invalid OTP) | Inline error, retry available |
| Resend available | Countdown → "Resend OTP" link |

### Responsive
Same as email login.

### Accessibility
- OTP input: individual digits, auto-advance announced
- Timer: announced when complete

---

## 07. Login — Social (OAuth)

### Purpose
Authenticate via third-party providers.

### Layout
Same split layout. Social buttons on the main login form.

### Key Components
- Google button (with Google icon)
- Apple button (with Apple icon)
- Microsoft button (with Microsoft icon)
- Loading overlay during OAuth redirect

### Navigation
- Button tap → Opens OAuth consent screen (webview/external browser)
- Callback → Validate token → Dashboard
- New account → Register (pre-filled)
- Error → Login with error message

### States
| State | Behavior |
|-------|----------|
| Default | Buttons visible |
| Loading | Button spinner + "Connecting..." |
| Success | Redirect to dashboard |
| Error (cancelled) | Return to login, toast "Login cancelled" |
| Error (account not found) | Prompt to register |

### Responsive
- Buttons stack vertically on mobile
- Horizontal row on desktop

### Accessibility
- Button labels: "Continue with Google", etc.
- Loading state announced

---

## 08. Register

### Purpose
Create new account.

### Layout
Same split layout as login. Left panel may show different illustration.

### Key Components
- Full name input
- Email input
- Password input (with strength indicator)
- Confirm password input
- Terms checkbox: "I agree to Terms of Service and Privacy Policy"
- Create account button (primary)
- Divider with "or"
- Social signup buttons
- Login link: "Already have an account? Log in"

### Navigation
- Success → Email Verification
- Social signup → OAuth flow
- Login link → Login

### States
| State | Behavior |
|-------|----------|
| Default | Empty form |
| Loading | Button spinner |
| Success | Redirect to email verification |
| Error (email taken) | Inline error with "Log in instead?" link |
| Error (validation) | Inline errors per field |
| Password strength | Weak/Medium/Strong indicator |

### Responsive
Same as login.

### Accessibility
- Password strength: announced as "Password strength: strong"
- Terms link opens in new tab

---

## 09. Forgot Password

### Purpose
Request password reset email.

### Layout
Centered card (max-width 440px). Back arrow to login.

### Key Components
- Heading: "Forgot your password?"
- Subheading: "Enter your email to receive a reset link"
- Email input
- Send reset link button (primary)
- Back to login link

### Navigation
- Success → Confirmation screen (check email)
- Back → Login

### States
| State | Behavior |
|-------|----------|
| Default | Empty email input |
| Loading | Button spinner |
| Success | Show confirmation message inline |
| Error (email not found) | Generic success message (security) |

### Responsive
- Full width on mobile with padding
- Centered card on desktop

### Accessibility
- Error announced via `Semantics`

---

## 10. Reset Password

### Purpose
Set new password via reset link.

### Layout
Centered card. Heading + form.

### Key Components
- Heading: "Set new password"
- New password input (with strength indicator)
- Confirm password input
- Show password toggle
- Reset password button (primary)
- Password requirements checklist (visible below input)

### Navigation
- Success → Login (with success toast)
- Invalid/expired link → Error message + "Request new link"

### States
| State | Behavior |
|-------|----------|
| Default | Empty form |
| Loading | Button spinner |
| Success | Redirect to login with toast |
| Error (link expired) | Error state + resend link |
| Error (passwords don't match) | Inline error |

### Responsive
Centered card, full width on mobile.

### Accessibility
- Requirements checklist announced as list
- Success announced

---

## 11. Email Verification

### Purpose
Verify email address after registration or resend.

### Layout
Centered card with illustration.

### Key Components
- Illustration (mailbox/email icon)
- Heading: "Check your email"
- Subheading: "We sent a verification link to {email}"
- Resend email button (secondary)
- Open email app button (if mobile)
- Change email link
- Back to login link

### Navigation
- Email link clicked → Verify → Dashboard
- Change email → Back to register with email pre-filled
- Back → Login

### States
| State | Behavior |
|-------|----------|
| Default | Message visible |
| Resending | Button spinner |
| Resent | Toast "Email sent!" |
| Verified | Auto-redirect to dashboard |
| Expired link | "Link expired. Resend?" |

### Responsive
- Mobile: "Open email app" button visible
- Desktop: Hidden (user checks email in another tab)

### Accessibility
- Email address announced
- Success announced when verified

---

## 12. MFA Setup

### Purpose
Enable multi-factor authentication.

### Layout
Centered card with stepper (2 steps).

### Key Components
- **Step 1**: Method selection (Authenticator app, SMS)
- **Step 2**: QR code + manual key for authenticator app
- Secret key (copyable)
- 6-digit verification input
- Verify & Enable button (primary)
- Backup codes section (hidden, toggle to show)
- Download backup codes button
- Skip for now link

### Navigation
- Success → Security Settings (with toast)
- Skip → Security Settings
- Back → Security Settings

### States
| State | Behavior |
|-------|----------|
| Default | Method selection |
| QR displayed | QR code + secret key |
| Loading | Button spinner |
| Success | Backup codes displayed, "MFA enabled" toast |
| Error (wrong code) | Inline error, retry |

### Responsive
- QR code centered, max-width 200px
- Mobile: full width card

### Accessibility
- QR code has alt text: "QR code for authenticator setup"
- Secret key: copy button with label
- Backup codes: screen reader friendly list

---

## 13. MFA Verify

### Purpose
Verify MFA code during login.

### Layout
Centered card.

### Key Components
- Heading: "Enter verification code"
- 6-digit OTP input
- Verify button (primary)
- Use backup code link
- Backup code input (replaces OTP on tap)
- Trust this device checkbox

### Navigation
- Success → Dashboard
- Use backup code → Backup code input
- Back → Login

### States
| State | Behavior |
|-------|----------|
| Default | OTP input visible |
| Backup mode | Text input for backup code |
| Loading | Button spinner |
| Success | Redirect to dashboard |
| Error (invalid code) | Inline error |
| Error (too many attempts) | Lockout message, wait timer |

### Responsive
Centered card, full width on mobile.

### Accessibility
- OTP digits: auto-advance, announced
- Backup code: labeled text input

---

## 14. OAuth Callback

### Purpose
Handle OAuth redirect and exchange tokens.

### Layout
Full-screen loading state.

### Key Components
- Loading spinner
- "Connecting to {provider}..." text
- Cancel button

### Navigation
- Success → Dashboard (or register if new user)
- Cancel → Login
- Error → Login with error toast

### States
| State | Behavior |
|-------|----------|
| Processing | Spinner + message |
| Success | Auto-redirect |
| Error | Redirect to login with error |
| Cancelled | Redirect to login |

### Responsive
Full screen on all platforms.

### Accessibility
- Loading announced
- Error announced on failure

---

## 15. Session Expired

### Purpose
Notify user of expired session, prompt re-authentication.

### Layout
Centered card with icon.

### Key Components
- Warning icon (clock/lock)
- Heading: "Session expired"
- Subheading: "Please log in again to continue"
- Login button (primary)

### Navigation
- Login → Login screen (current session cleared)

### States
| State | Behavior |
|-------|----------|
| Default | Message + button visible |

### Responsive
Centered card on all platforms.

### Accessibility
- Warning icon labeled
- Login button auto-focused
