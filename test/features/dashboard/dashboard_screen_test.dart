import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('affiche les sections principales', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.text('Bienvenue sur Khodan'), findsOneWidget);
      expect(find.text('Saillie'), findsOneWidget);
      expect(find.text('Mise bas'), findsOneWidget);
      expect(find.text('Pesée'), findsOneWidget);
      expect(find.text('Abattage'), findsOneWidget);
      expect(find.text('Planning des 7 prochains jours'), findsOneWidget);
    });
  });
}

