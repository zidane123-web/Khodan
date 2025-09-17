import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? farmName,
  }) async {
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (farmName != null && response.user != null) {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': response.user!.id,
        'email': email,
        'farm_name': farmName,
      });
    }

    return response;
  }

  Future<void> signOut() => _client.auth.signOut();
}
