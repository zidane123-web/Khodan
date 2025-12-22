// lib/data/repositories/auth_repository.dart
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
    String? firstName,
    String? lastName,
  }) async {
    // Étape 1 : Créer le compte utilisateur
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null, // Important pour ne pas attendre la confirmation
    );

    // Étape 2 : Mettre à jour le profil de l'utilisateur
    if (response.user != null) {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': response.user!.id,
        'email': email,
        'farm_name': farmName,
        'first_name': firstName,
        'last_name': lastName,
      });
    }
    
    // Étape 3 : Connecter l'utilisateur immédiatement après la création du compte
    if (response.user != null) {
      return await signInWithEmail(email: email, password: password);
    }

    return response;
  }

  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();
}
