import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../data/local/local_data_sources.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailConfirmationRequired,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.profile,
    this.errorMessage,
    this.infoMessage,
    this.emailPendingVerification,
  });

  final AuthStatus status;
  final supa.Session? session;
  final Profile? profile;
  final String? errorMessage;
  final String? infoMessage;
  final String? emailPendingVerification;

  bool get isAuthenticated => session != null;

  AuthState copyWith({
    AuthStatus? status,
    supa.Session? session,
    bool clearSession = false,
    Profile? profile,
    bool clearProfile = false,
    String? errorMessage,
    bool resetError = false,
    String? infoMessage,
    bool resetInfo = false,
    String? emailPendingVerification,
    bool clearEmailPending = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      profile: clearProfile ? null : profile ?? this.profile,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
      infoMessage: resetInfo ? null : infoMessage ?? this.infoMessage,
      emailPendingVerification: clearEmailPending
          ? null
          : emailPendingVerification ?? this.emailPendingVerification,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        session,
        profile,
        errorMessage,
        infoMessage,
        emailPendingVerification,
      ];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._repository, {
    LocalProfileDataSource? localProfile,
  })  : _localProfile = localProfile,
        super(const AuthState());

  final AuthRepository _repository;
  final LocalProfileDataSource? _localProfile;

  StreamSubscription<supa.AuthState>? _authSubscription;
  bool _isListening = false;

  void listenAuthChanges() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    _authSubscription = _repository.authStateChanges.listen(
      (supa.AuthState authState) async {
        final supa.AuthChangeEvent event = authState.event;
        final supa.Session? session = authState.session;
        switch (event) {
          case supa.AuthChangeEvent.initialSession:
          case supa.AuthChangeEvent.signedIn:
          case supa.AuthChangeEvent.tokenRefreshed:
          case supa.AuthChangeEvent.userUpdated:
            if (session != null) {
              await _handleSignedIn(session);
            }
            break;
          case supa.AuthChangeEvent.signedOut:
          case supa.AuthChangeEvent.userDeleted:
            emit(
              state.copyWith(
                status: AuthStatus.unauthenticated,
                clearSession: true,
                clearProfile: true,
                resetError: true,
                resetInfo: true,
                clearEmailPending: true,
              ),
            );
            break;
          case supa.AuthChangeEvent.passwordRecovery:
            emit(
              state.copyWith(
                infoMessage:
                    'Consultez vos emails pour r\u00e9initialiser votre mot de passe.',
                resetError: true,
              ),
            );
            break;
          case supa.AuthChangeEvent.mfaChallengeVerified:
            break;
        }
      },
    );
  }

  Future<void> bootstrap() async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
      ),
    );
    try {
      supa.Session? session = _repository.currentSession;
      if (session == null) {
        try {
          final supa.AuthResponse? refreshed = await _repository.refreshSession();
          session = refreshed?.session ?? session;
        } on supa.AuthException {
          session = null;
        }
      }
      if (session != null) {
        await _handleSignedIn(session);
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearSession: true,
            clearProfile: true,
            resetError: true,
            resetInfo: true,
          ),
        );
      }
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
        clearEmailPending: true,
      ),
    );
    try {
      final supa.AuthResponse response = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      final supa.Session? session = response.session ?? _repository.currentSession;
      final supa.User? user = session?.user ?? response.user;
      if (session != null) {
        await _handleSignedIn(session);
        return;
      }
      if (user != null && user.emailConfirmedAt == null) {
        emit(
          state.copyWith(
            status: AuthStatus.emailConfirmationRequired,
            emailPendingVerification: email,
            clearSession: true,
            clearProfile: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage:
              'Impossible de r\u00e9cup\u00e9rer la session. Veuillez r\u00e9essayer.',
        ),
      );
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    String? farmName,
    String? redirectTo,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
        clearEmailPending: true,
      ),
    );
    try {
      final supa.AuthResponse response = await _repository.signUpWithEmail(
        email: email,
        password: password,
        farmName: farmName,
        redirectTo: redirectTo,
      );
      if (response.session != null) {
        await _handleSignedIn(response.session!);
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.emailConfirmationRequired,
          emailPendingVerification: email,
          clearSession: true,
          clearProfile: true,
          infoMessage:
              'Nous avons envoy\u00e9 un email de confirmation \u00e0 $email.',
        ),
      );
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
      ),
    );
    try {
      await _repository.resendConfirmationEmail(email: email);
      emit(
        state.copyWith(
          status: AuthStatus.emailConfirmationRequired,
          emailPendingVerification: email,
          infoMessage: 'Un nouvel email de confirmation a \u00e9t\u00e9 envoy\u00e9.',
        ),
      );
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> resetPassword(String email, {String? redirectTo}) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
      ),
    );
    try {
      await _repository.requestPasswordReset(
        email: email,
        redirectTo: redirectTo,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          infoMessage:
              'Si un compte existe pour $email, un email de r\u00e9initialisation a \u00e9t\u00e9 envoy\u00e9.',
        ),
      );
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> sendMagicLink(String email, {String? redirectTo}) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
      ),
    );
    try {
      await _repository.sendMagicLink(
        email: email,
        redirectTo: redirectTo,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          infoMessage: 'Un lien de connexion a \u00e9t\u00e9 envoy\u00e9 \u00e0 $email.',
        ),
      );
    } on supa.AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _mapAuthError(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshProfile() async {
    final supa.Session? session = state.session ?? _repository.currentSession;
    if (session == null) {
      return;
    }
    final Profile? profile = await _loadAndCacheProfile(session.user.id);
    emit(
      state.copyWith(
        profile: profile ?? state.profile,
        resetError: true,
      ),
    );
  }

  Future<void> signOut() async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        resetError: true,
        resetInfo: true,
      ),
    );
    try {
      await _repository.signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          clearProfile: true,
          clearEmailPending: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void acknowledgeError() {
    if (state.errorMessage != null) {
      emit(
        state.copyWith(
          resetError: true,
          status: state.isAuthenticated
              ? AuthStatus.authenticated
              : state.status == AuthStatus.emailConfirmationRequired
                  ? AuthStatus.emailConfirmationRequired
                  : AuthStatus.unauthenticated,
        ),
      );
    }
  }

  void acknowledgeInfo() {
    if (state.infoMessage != null) {
      emit(
        state.copyWith(
          resetInfo: true,
          status: state.status,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _handleSignedIn(supa.Session session) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        session: session,
        resetError: true,
        resetInfo: true,
        clearEmailPending: true,
      ),
    );
    final Profile? profile = await _loadAndCacheProfile(session.user.id);
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        profile: profile ?? state.profile,
      ),
    );
  }

  Future<Profile?> _loadAndCacheProfile(String userId) async {
    try {
      final Map<String, dynamic>? raw = await _repository.fetchProfile(userId);
      if (raw != null) {
        final Profile profile = Profile.fromJson(raw);
        await _localProfile?.upsertProfile(profile);
        return profile;
      }
    } catch (error, stackTrace) {
      debugPrint('Profil Supabase indisponible: $error\n$stackTrace');
    }
    final LocalProfileDataSource? local = _localProfile;
    if (local != null) {
      try {
        return await local.fetchProfile(userId);
      } catch (error, stackTrace) {
        debugPrint('Impossible de charger le profil local : $error\n$stackTrace');
      }
    }
    return null;
  }

  String _mapAuthError(supa.AuthException error) {
    final String message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Identifiants incorrects. Verifiez votre email et votre mot de passe.';
    }
    if (message.contains('email not confirmed')) {
      return 'Veuillez confirmer votre adresse email avant de vous connecter.';
    }
    if (message.contains('user banned') || message.contains('suspend')) {
      return 'Votre compte est suspendu. Contactez le support pour plus d\'informations.';
    }
    return error.message;
  }
}
