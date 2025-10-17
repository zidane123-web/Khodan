import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthRepository {
  AuthRepository({supa.SupabaseClient? client})
      : _client = client ?? supa.Supabase.instance.client;

  final supa.SupabaseClient _client;

  Stream<supa.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  supa.Session? get currentSession => _client.auth.currentSession;

  supa.User? get currentUser => _client.auth.currentUser;

  Future<supa.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<supa.AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? farmName,
    String? redirectTo,
  }) async {
    final supa.AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectTo,
      data: <String, dynamic>{
        if (farmName != null && farmName.isNotEmpty) 'farm_name': farmName,
      },
    );

    if (response.user != null) {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': response.user!.id,
        'email': email,
        'farm_name': farmName ?? '',
      });
    }

    return response;
  }

  Future<void> resendConfirmationEmail({required String email}) {
    return _client.auth.resend(
      type: supa.OtpType.signup,
      email: email,
    );
  }

  Future<void> requestPasswordReset({
    required String email,
    String? redirectTo,
  }) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  Future<void> sendMagicLink({
    required String email,
    String? redirectTo,
  }) {
    return _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  Future<supa.AuthResponse?> refreshSession() {
    return _client.auth.refreshSession();
  }

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final List<dynamic> result =
        await _client.from('profiles').select().eq('id', userId);
    if (result.isEmpty || result.first is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(result.first as Map<dynamic, dynamic>);
  }

  Future<void> signOut() => _client.auth.signOut();
}
