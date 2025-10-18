import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/features/events/presentation/screens/events_hub_screen.dart';

void main() {
  testWidgets('FAB label switches between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EventsHubScreen(),
      ),
    );

    // Initial tab is Reproduction
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle saillie'), findsOneWidget);

    // Switch to Sante tab
    await tester.tap(find.text('Sante'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvel evenement'), findsOneWidget);

    // Switch to Autres tab
    await tester.tap(find.text('Autres'));
    await tester.pumpAndSettle();
    expect(find.text('Nouvel evenement'), findsOneWidget);
  });
}

