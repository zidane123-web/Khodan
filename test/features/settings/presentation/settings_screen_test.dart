import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khodan/features/settings/presentation/screens/settings_screen.dart';
import 'package:khodan/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders settings sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final AppLocalizations l10n = AppLocalizations.of(context);

    expect(find.text(l10n.settingsOfflineSection), findsOneWidget);
    expect(find.text(l10n.settingsSpeciesTitle), findsOneWidget);
    expect(find.text(l10n.settingsSupportSection), findsOneWidget);
    await tester.scrollUntilVisible(find.text(l10n.settingsSignOut), 300);
    expect(find.text(l10n.settingsSignOut), findsOneWidget);
  });
}
