import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  GoTrueClient get auth => _client.auth;
  User? get currentUser => auth.currentUser;

  // Sign up with email/password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'full_name': '$firstName $lastName',
      },
    );
    return response;
  }

  // Sign in with email/password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.contentos://login-callback/',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.contentos://reset-password-callback/',
    );
  }

  // Update profile
  Future<UserResponse> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    final updates = <String, dynamic>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (firstName != null && lastName != null) {
      updates['full_name'] = '$firstName $lastName';
    }

    final response = await auth.updateUser(
      UserAttributes(data: updates),
    );
    return response;
  }

  // Get user display name
  String getDisplayName() {
    if (currentUser?.userMetadata?['full_name'] != null) {
      return currentUser!.userMetadata!['full_name'] as String;
    }
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@').first;
    }
    return 'Creator';
  }

  // Get user first name
  String getFirstName() {
    if (currentUser?.userMetadata?['first_name'] != null) {
      return currentUser!.userMetadata!['first_name'] as String;
    }
    return getDisplayName();
  }

  // Listen to auth changes
  Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;
}
