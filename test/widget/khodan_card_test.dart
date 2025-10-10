import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/app/config/theme.dart';
import 'package:khodan/app/core/widgets/khodan_card.dart';
import 'package:khodan/app/core/widgets/khodan_tag.dart';

void main() {
  Widget createHarness(Widget child) {
    return MaterialApp(
      theme: buildKhodanTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('KhodanCard renders header, body and footer', (WidgetTester tester) async {
    await tester.pumpWidget(
      createHarness(
        KhodanCard(
          title: 'Production',
          subtitle: 'Derniers 7 jours',
          trailing: const Icon(Icons.chevron_right),
          footer: const Text('Mise à jour : il y a 2h'),
          child: const Text('42 naissances'),
        ),
      ),
    );

    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Derniers 7 jours'), findsOneWidget);
    expect(find.text('42 naissances'), findsOneWidget);
    expect(find.text('Mise à jour : il y a 2h'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('KhodanTag displays label and icon for success variant', (WidgetTester tester) async {
    await tester.pumpWidget(
      createHarness(
        const KhodanTag(
          'On track',
          icon: Icons.check_circle,
          variant: KhodanTagVariant.success,
        ),
      ),
    );

    expect(find.text('On track'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
