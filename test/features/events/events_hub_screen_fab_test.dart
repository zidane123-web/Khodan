import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/features/events/presentation/screens/events_hub_screen.dart';

void main() {
  testWidgets('FAB label switches between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<AnimalRepository>(
            create: (_) => InMemoryAnimalRepository(),
          ),
          RepositoryProvider<BreedingRepository>(
            create: (_) => InMemoryBreedingRepository(),
          ),
          RepositoryProvider<EventRepository>(
            create: (_) => InMemoryEventRepository(),
          ),
        ],
        child: const MaterialApp(
          home: EventsHubScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Nouvelle saillie'), findsOneWidget);

    await tester.tap(find.text('Sant\u00e9'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nouvel'), findsOneWidget);

    await tester.tap(find.text('Autres'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nouvel'), findsOneWidget);
  });
}
