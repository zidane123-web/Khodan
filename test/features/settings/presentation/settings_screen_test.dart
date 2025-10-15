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

    expect(find.text('Mode hors-ligne'), findsOneWidget);
    expect(find.text('Gestion des espèces'), findsOneWidget);
    expect(find.text('Assistance'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Déconnexion'), 300);
    expect(find.text('Déconnexion'), findsOneWidget);
  });
}
