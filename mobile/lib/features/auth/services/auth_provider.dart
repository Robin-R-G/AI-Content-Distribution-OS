import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_provider.dart';
import 'auth_service.dart';
import 'auth_security.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Auth form state
class AuthFormState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isLockedOut;
  final Duration? lockoutRemaining;
  final int failedAttempts;

  const AuthFormState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isLockedOut = false,
    this.lockoutRemaining,
    this.failedAttempts = 0,
  });

  AuthFormState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isLockedOut,
    Duration? lockoutRemaining,
    int? failedAttempts,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      isLockedOut: isLockedOut ?? this.isLockedOut,
      lockoutRemaining: lockoutRemaining,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

// Auth form notifier with security
class AuthFormNotifier extends StateNotifier<AuthFormState> {
  final AuthService _authService;

  AuthFormNotifier(this._authService) : super(const AuthFormState()) {
    checkLockout();
  }

  Future<void> checkLockout() async {
    final isLocked = await AuthSecurity.isAccountLockedOut();
    final remaining = await AuthSecurity.getRemainingLockout();
    final attempts = await AuthSecurity.getFailedAttempts();

    if (isLocked) {
      state = state.copyWith(
        isLockedOut: true,
        lockoutRemaining: remaining,
        failedAttempts: attempts,
        error: remaining != null
            ? 'Account temporarily locked. Try again in ${_formatDuration(remaining)}.'
            : 'Account temporarily locked. Please try again later.',
      );
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    // Check lockout
    if (state.isLockedOut) {
      await checkLockout();
      return false;
    }

    // Check rate limiting
    if (await AuthSecurity.isRateLimited()) {
      state = state.copyWith(
        error: 'Too many requests. Please wait a moment and try again.',
      );
      return false;
    }

    // Sanitize and validate inputs
    final sanitizedEmail = AuthSecurity.sanitizeEmail(email);
    final emailError = AuthSecurity.validateEmail(sanitizedEmail);
    if (emailError != null) {
      state = state.copyWith(error: emailError);
      return false;
    }

    if (password.isEmpty) {
      state = state.copyWith(error: 'Password is required');
      return false;
    }

    // Record request
    await AuthSecurity.recordRequest();

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signIn(
        email: sanitizedEmail,
        password: password,
      );

      // Success - reset attempts
      await AuthSecurity.resetAttempts();
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (authError) {
      // Record failed attempt
      await AuthSecurity.recordFailedAttempt();
      final attempts = await AuthSecurity.getFailedAttempts();
      final isLocked = await AuthSecurity.isAccountLockedOut();
      final remaining = await AuthSecurity.getRemainingLockout();

      state = state.copyWith(
        isLoading: false,
        failedAttempts: attempts,
        isLockedOut: isLocked,
        lockoutRemaining: remaining,
        error: AuthSecurity.getSafeErrorMessage(authError.message),
      );
      return false;
    } catch (e) {
      await AuthSecurity.recordFailedAttempt();
      state = state.copyWith(
        isLoading: false,
        error: AuthSecurity.getSafeErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Check rate limiting
    if (await AuthSecurity.isRateLimited()) {
      state = state.copyWith(
        error: 'Too many requests. Please wait a moment and try again.',
      );
      return false;
    }

    // Sanitize and validate inputs
    final sanitizedEmail = AuthSecurity.sanitizeEmail(email);
    final emailError = AuthSecurity.validateEmail(sanitizedEmail);
    if (emailError != null) {
      state = state.copyWith(error: emailError);
      return false;
    }

    final passwordError = AuthSecurity.validatePassword(password);
    if (passwordError != null) {
      state = state.copyWith(error: passwordError);
      return false;
    }

    final sanitizedFirstName = AuthSecurity.sanitizeName(firstName);
    final sanitizedLastName = AuthSecurity.sanitizeName(lastName);

    if (sanitizedFirstName.isEmpty) {
      state = state.copyWith(error: 'First name is required');
      return false;
    }
    if (sanitizedLastName.isEmpty) {
      state = state.copyWith(error: 'Last name is required');
      return false;
    }

    // Record request
    await AuthSecurity.recordRequest();

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.signUp(
        email: sanitizedEmail,
        password: password,
        firstName: sanitizedFirstName,
        lastName: sanitizedLastName,
      );

      if (response.user != null && response.session == null) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Check your email for a verification link.',
        );
        return true;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (authError) {
      state = state.copyWith(
        isLoading: false,
        error: AuthSecurity.getSafeErrorMessage(authError.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthSecurity.getSafeErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    // Check rate limiting
    if (await AuthSecurity.isRateLimited()) {
      state = state.copyWith(
        error: 'Too many requests. Please wait a moment and try again.',
      );
      return;
    }

    final sanitizedEmail = AuthSecurity.sanitizeEmail(email);
    final emailError = AuthSecurity.validateEmail(sanitizedEmail);
    if (emailError != null) {
      state = state.copyWith(error: emailError);
      return;
    }

    await AuthSecurity.recordRequest();

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.resetPassword(sanitizedEmail);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'If an account exists with this email, you will receive a password reset link.',
      );
    } on AuthException catch (_) {
      // Always show success to prevent email enumeration
      state = state.copyWith(
        isLoading: false,
        successMessage: 'If an account exists with this email, you will receive a password reset link.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        successMessage: 'If an account exists with this email, you will receive a password reset link.',
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (authError) {
      state = state.copyWith(
        isLoading: false,
        error: AuthSecurity.getSafeErrorMessage(authError.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AuthSecurity.getSafeErrorMessage(e.toString()),
      );
      return false;
    }
  }
}

final authFormProvider =
    StateNotifierProvider<AuthFormNotifier, AuthFormState>((ref) {
  return AuthFormNotifier(ref.watch(authServiceProvider));
});
