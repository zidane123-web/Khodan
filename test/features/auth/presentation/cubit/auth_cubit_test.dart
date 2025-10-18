import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/models/profile.dart';
import 'package:khodan/data/repositories/auth_repository.dart';
import 'package:khodan/features/auth/presentation/cubit/auth_cubit.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLocalProfileDataSource extends Mock
    implements LocalProfileDataSource {}

void main() {
  late _MockAuthRepository repository;
  late _MockLocalProfileDataSource localProfile;
  late StreamController<supa.AuthState> authStateController;

  setUpAll(() {
    registerFallbackValue(
      Profile(
        id: 'fallback',
        email: 'fallback@example.com',
        farmName: 'Fallback',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  });

  setUp(() {
    repository = _MockAuthRepository();
    localProfile = _MockLocalProfileDataSource();
    authStateController = StreamController<supa.AuthState>.broadcast();
    when(() => repository.authStateChanges)
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() async {
    await authStateController.close();
  });

  supa.Session buildSession({bool confirmed = true}) {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> userJson = <String, dynamic>{
      'id': 'user-123',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'demo@example.com',
      'phone': '',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'email_confirmed_at': confirmed ? now.toIso8601String() : null,
      'confirmed_at': confirmed ? now.toIso8601String() : null,
      'last_sign_in_at': now.toIso8601String(),
    };

    final supa.Session? session = supa.Session.fromJson(<String, dynamic>{
      'access_token': 'token',
      'token_type': 'bearer',
      'expires_in': 3600,
      'refresh_token': 'refresh-token',
      'user': userJson,
      'expires_at': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000,
      'provider_token': null,
      'provider_refresh_token': null,
    });
    if (session == null) {
      throw StateError('Unable to build session for tests');
    }
    return session;
  }

  test('listenAuthChanges loads profile and emits authenticated state',
      () async {
    final supa.Session session = buildSession();
    when(() => repository.fetchProfile('user-123')).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'user-123',
        'email': 'demo@example.com',
        'farm_name': 'Ferme Demo',
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    when(() => localProfile.upsertProfile(any())).thenAnswer((_) async {});

    final AuthCubit cubit = AuthCubit(
      repository,
      localProfile: localProfile,
    );

    cubit.listenAuthChanges();
    authStateController.add(
      supa.AuthState(supa.AuthChangeEvent.signedIn, session),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.session, isNotNull);
    expect(cubit.state.session?.user.id, 'user-123');
    expect(cubit.state.profile, isA<Profile>());
    verify(() => localProfile.upsertProfile(any())).called(1);
  });

  test('resetPassword emits info message on success', () async {
    when(() => repository.requestPasswordReset(
          email: any(named: 'email'),
          redirectTo: any(named: 'redirectTo'),
        )).thenAnswer((_) async {});

    final AuthCubit cubit = AuthCubit(
      repository,
      localProfile: localProfile,
    );

    await cubit.resetPassword('demo@example.com');

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.infoMessage, isNotNull);
  });

  test('signIn surfaces mapped error for invalid credentials', () async {
    when(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      supa.AuthException('Invalid login credentials'),
    );

    final AuthCubit cubit = AuthCubit(
      repository,
      localProfile: localProfile,
    );

    await cubit.signIn('demo@example.com', 'wrong-pass');

    expect(cubit.state.status, AuthStatus.failure);
    expect(
      cubit.state.errorMessage,
      'Identifiants incorrects. Verifiez votre email et votre mot de passe.',
    );
  });
}
