import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSecurity {
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 30;
  static const int rateLimitWindowSeconds = 60;
  static const int maxRequestsPerWindow = 10;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int emailMaxLength = 254;

  static const String _attemptsKey = 'auth_login_attempts';
  static const String _lockoutKey = 'auth_lockout_until';
  static const String _requestTimestampsKey = 'auth_request_timestamps';
  static const String _lockoutCountKey = 'auth_lockout_count';

  // ==================== INPUT SANITIZATION ====================

  /// Sanitize email: trim, lowercase, remove dangerous characters
  static String sanitizeEmail(String email) {
    var cleaned = email.trim().toLowerCase();
    // Remove null bytes and control characters
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
    // Remove surrounding quotes if present
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned;
  }

  /// Sanitize name: trim, remove control characters, limit length
  static String sanitizeName(String name) {
    var cleaned = name.trim();
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
    // Allow only letters, spaces, hyphens, apostrophes
    cleaned = cleaned.replaceAll(RegExp(r"[^a-zA-Z\s\-']"), '');
    return cleaned;
  }

  /// Validate email format with strict regex
  static String? validateEmail(String email) {
    final sanitized = sanitizeEmail(email);
    if (sanitized.isEmpty) return 'Email is required';
    if (sanitized.length > emailMaxLength) return 'Email is too long';

    // Strict email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(sanitized)) {
      return 'Please enter a valid email address';
    }

    // Check for disposable email domains
    final blockedDomains = [
      'tempmail.com', 'throwaway.email', 'guerrillamail.com',
      'mailinator.com', 'yopmail.com', 'trashmail.com',
      '10minutemail.com', 'guerrillamailblock.com',
    ];
    final domain = sanitized.split('@').last;
    if (blockedDomains.contains(domain)) {
      return 'Please use a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    if (password.length > passwordMaxLength) {
      return 'Password is too long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }
    // Check for common weak passwords
    final weakPasswords = [
      'password', '12345678', 'qwerty123', 'abc12345',
      'Password1', 'Admin123', 'Welcome1', 'Letmein12',
    ];
    if (weakPasswords.contains(password.toLowerCase())) {
      return 'Password is too common. Please choose a stronger one';
    }
    return null;
  }

  /// Calculate password strength (0.0 to 1.0)
  static double passwordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.15;
    if (password.length >= 16) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
    return strength.clamp(0.0, 1.0);
  }

  // ==================== RATE LIMITING ====================

  /// Check if the request is rate limited
  static Future<bool> isRateLimited() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamps = prefs.getStringList(_requestTimestampsKey) ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;

    // Remove timestamps outside the window
    final validTimestamps = timestamps.where((t) {
      final timestamp = int.tryParse(t) ?? 0;
      return (now - timestamp) < rateLimitWindowSeconds * 1000;
    }).toList();

    // Save cleaned timestamps
    await prefs.setStringList(_requestTimestampsKey, validTimestamps);

    return validTimestamps.length >= maxRequestsPerWindow;
  }

  /// Record a request timestamp
  static Future<void> recordRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamps = prefs.getStringList(_requestTimestampsKey) ?? [];
    timestamps.add(DateTime.now().millisecondsSinceEpoch.toString());
    await prefs.setStringList(_requestTimestampsKey, timestamps);
  }

  // ==================== ACCOUNT LOCKOUT ====================

  /// Check if account is locked out
  static Future<bool> isAccountLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getString(_lockoutKey);
    if (lockoutUntil == null) return false;

    final lockoutTime = DateTime.tryParse(lockoutUntil);
    if (lockoutTime == null) return false;

    if (DateTime.now().isAfter(lockoutTime)) {
      // Lockout expired, reset
      await prefs.remove(_lockoutKey);
      await prefs.setInt(_attemptsKey, 0);
      return false;
    }

    return true;
  }

  /// Get remaining lockout duration
  static Future<Duration?> getRemainingLockout() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getString(_lockoutKey);
    if (lockoutUntil == null) return null;

    final lockoutTime = DateTime.tryParse(lockoutUntil);
    if (lockoutTime == null) return null;

    final remaining = lockoutTime.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Record a failed login attempt
  static Future<void> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_attemptsKey) ?? 0) + 1;
    await prefs.setInt(_attemptsKey, attempts);

    if (attempts >= maxLoginAttempts) {
      // Apply lockout with increasing duration
      final lockoutCount = (prefs.getInt(_lockoutCountKey) ?? 0) + 1;
      await prefs.setInt(_lockoutCountKey, lockoutCount);

      // Exponential backoff: 30min, 1hr, 2hr, 4hr...
      final multiplier = lockoutCount > 4 ? 8 : (1 << (lockoutCount - 1));
      final lockoutDuration = Duration(
        minutes: lockoutDurationMinutes * multiplier,
      );

      final lockoutUntil = DateTime.now().add(lockoutDuration);
      await prefs.setString(_lockoutKey, lockoutUntil.toIso8601String());
    }
  }

  /// Reset failed attempts on successful login
  static Future<void> resetAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, 0);
    await prefs.remove(_lockoutKey);
  }

  /// Get current failed attempt count
  static Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_attemptsKey) ?? 0;
  }

  // ==================== GENERIC ERROR MESSAGES ====================

  /// Get a safe, generic error message (never reveal if email exists)
  static String getSafeErrorMessage(String? supabaseError) {
    if (supabaseError == null) {
      return 'Something went wrong. Please try again.';
    }

    final error = supabaseError.toLowerCase();

    // Rate limiting
    if (error.contains('rate limit') || error.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // Invalid credentials (generic)
    if (error.contains('invalid') ||
        error.contains('credentials') ||
        error.contains('unauthorized') ||
        error.contains('login') ||
        error.contains('password')) {
      return 'Email or password is incorrect. Please try again.';
    }

    // Email related
    if (error.contains('email') && error.contains('confirm')) {
      return 'Please verify your email address first.';
    }

    if (error.contains('email') && error.contains('already')) {
      return 'An account with this email already exists.';
    }

    // Network
    if (error.contains('network') ||
        error.contains('connection') ||
        error.contains('timeout')) {
      return 'Connection error. Please check your internet and try again.';
    }

    // Server
    if (error.contains('server') || error.contains('500')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  // ==================== TRUSTED AUTH PROVIDERS ====================

  static const List<TrustedAuthProvider> trustedProviders = [
    TrustedAuthProvider(
      id: 'google',
      name: 'Google',
      icon: 'g_mobiledata',
      isEnabled: true,
    ),
    TrustedAuthProvider(
      id: 'apple',
      name: 'Apple',
      icon: 'apple',
      isEnabled: true,
    ),
  ];
}

class TrustedAuthProvider {
  final String id;
  final String name;
  final String icon;
  final bool isEnabled;

  const TrustedAuthProvider({
    required this.id,
    required this.name,
    required this.icon,
    required this.isEnabled,
  });
}
