import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:khodan/features/settings/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders settings sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Synchroniser maintenant'), findsOneWidget);
    expect(find.text('Espèces, gestation & sevrage'), findsOneWidget);
    expect(find.text('Tableau de bord & rapports'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Profil'), 300);
    expect(find.text('Profil'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Base de connaissances'),
      300,
    );
    expect(find.text('Base de connaissances'), findsOneWidget);
  });
}
