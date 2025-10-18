import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:khodan/data/models/profile.dart';
import 'package:khodan/data/repositories/auth_repository.dart';
import 'package:khodan/data/repositories/profile_repository.dart';
import 'package:khodan/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:khodan/features/settings/presentation/screens/settings_profile_screen.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockSupabaseClient extends Mock implements supa.SupabaseClient {}

class _TestAuthCubit extends AuthCubit {
  _TestAuthCubit(AuthState initialState)
      : super(AuthRepository(client: _MockSupabaseClient())) {
    emit(initialState);
  }

  @override
  void listenAuthChanges() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockProfileRepository repository;
  late Profile profile;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = _MockProfileRepository();
    profile = Profile(
      id: 'profile-1',
      email: 'demo@khodan.app',
      farmName: 'Ferme Demo',
      createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
      updatedAt: DateTime.parse('2024-01-02T12:00:00Z'),
      phone: '+33123456789',
      locale: 'fr_FR',
      timeZone: 'Europe/Paris',
      farmLocation: 'Paris',
      legalPreferences: const <String, dynamic>{
        'termsAccepted': true,
        'privacyAccepted': true,
        'marketingOptIn': false,
      },
      billingStatus: 'active',
    );

    registerFallbackValue(profile);
  });

  testWidgets(
      'SettingsProfileScreen affiche et met à jour le profil via ProfileRepository',
      (WidgetTester tester) async {
    final Profile updatedProfile = profile.copyWith(
      farmName: 'Ferme du Soleil',
      updatedAt: DateTime.parse('2024-01-03T08:00:00Z'),
    );

    when(() => repository.fetch(profile.id)).thenAnswer(
      (_) async => profile,
    );
    when(() => repository.update(any())).thenAnswer(
      (_) async => updatedProfile,
    );

    final AuthState authState = AuthState(
      status: AuthStatus.authenticated,
      profile: profile,
    );

    await tester.pumpWidget(
      RepositoryProvider<ProfileRepository>.value(
        value: repository,
        child: BlocProvider<AuthCubit>.value(
          value: _TestAuthCubit(authState),
          child: const MaterialApp(
            home: SettingsProfileScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'Ferme Demo'),
      findsOneWidget,
    );

    await tester.enterText(
      find.bySemanticsLabel('Nom de l’élevage'),
      'Ferme du Soleil',
    );

    await tester.ensureVisible(find.byIcon(Icons.save_outlined));

    final Finder saveButton = find.ancestor(
      of: find.byIcon(Icons.save_outlined),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is FilledButton,
      ),
    );

    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    verify(
      () => repository.update(
        any(
          that: predicate<Profile>(
            (Profile value) => value.farmName == 'Ferme du Soleil',
          ),
        ),
      ),
    ).called(1);

    expect(
      find.widgetWithText(TextFormField, 'Ferme du Soleil'),
      findsOneWidget,
    );
  });
}
