import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/event.dart';
import 'package:khodan/features/events/presentation/widgets/event_timeline.dart';

void main() {
  testWidgets('EventTimeline shows empty message when no events', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventTimeline(events: <LivestockEvent>[]),
        ),
      ),
    );

    expect(find.text('Aucun evenement pour le moment.'), findsOneWidget);
  });

  testWidgets('EventTimeline taps item and navigates to detail', (WidgetTester tester) async {
    final LivestockEvent e = LivestockEvent(
      id: 'evt-1',
      profileId: 'demo',
      eventType: 'vaccination',
      eventDate: DateTime(2025, 1, 15),
      details: const <String, dynamic>{'product': 'RHDV2'},
      notes: 'Rappel',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventTimeline(events: <LivestockEvent>[e]),
        ),
      ),
    );

    // Ensure the tile renders
    expect(find.text('vaccination'), findsOneWidget);

    // Tap and navigate
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    // Detail screen should show the event type in AppBar or body
    expect(find.textContaining('Details de l\'evenement'), findsOneWidget);
    expect(find.text('vaccination'), findsWidgets);
  });
}

