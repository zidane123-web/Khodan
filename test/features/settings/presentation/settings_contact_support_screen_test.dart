import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:khodan/data/models/profile.dart';
import 'package:khodan/data/models/support_request.dart';
import 'package:khodan/data/repositories/auth_repository.dart';
import 'package:khodan/data/repositories/support_repository.dart';
import 'package:khodan/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:khodan/features/settings/presentation/screens/settings_contact_support_screen.dart';
import 'package:khodan/l10n/app_localizations.dart';

class _MockSupportRepository extends Mock implements SupportRepository {}

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

  late _MockSupportRepository repository;
  late Profile profile;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = _MockSupportRepository();
    profile = Profile(
      id: 'profile-1',
      email: 'eleveur@khodan.app',
      farmName: 'Ferme Demo',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      legalPreferences: const <String, dynamic>{
        'termsAccepted': true,
        'privacyAccepted': true,
      },
    );

    registerFallbackValue(
      SupportRequest(
        profileId: profile.id,
        subject: 'Test',
        message: 'Message',
        contactEmail: profile.email,
        createdAt: DateTime.now(),
      ),
    );
  });

  testWidgets('SettingsContactSupportScreen envoie le ticket au repository',
      (WidgetTester tester) async {
    when(() => repository.submit(any())).thenAnswer((_) async {});

    final AuthState authState = AuthState(
      status: AuthStatus.authenticated,
      profile: profile,
    );

    await tester.pumpWidget(
      RepositoryProvider<SupportRepository>.value(
        value: repository,
        child: BlocProvider<AuthCubit>.value(
          value: _TestAuthCubit(authState),
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsContactSupportScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context =
        tester.element(find.byType(SettingsContactSupportScreen));
    final AppLocalizations l10n = AppLocalizations.of(context);

    await tester.enterText(
      find.bySemanticsLabel(l10n.contactSupportSubjectLabel),
      'Besoin d\'aide',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'Le module de reproduction affiche une erreur 500.',
    );

    await tester.tap(
      find.widgetWithText(
        DropdownButtonFormField<String>,
        l10n.contactSupportPriorityNormal,
      ),
    );
    await tester.pump();
    await tester.tap(find.text(l10n.contactSupportPriorityUrgent).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.send_outlined));

    final Finder submitButton = find.ancestor(
      of: find.byIcon(Icons.send_outlined),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is FilledButton,
      ),
    );

    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    verify(
      () => repository.submit(
        any(
          that: predicate<SupportRequest>(
            (SupportRequest request) =>
                request.subject == 'Besoin d\'aide' &&
                request.priority == 'urgent' &&
                request.profileId == profile.id,
          ),
        ),
      ),
    ).called(1);
  });
}
