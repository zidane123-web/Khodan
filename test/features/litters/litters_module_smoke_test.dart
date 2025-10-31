import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khodan/data/repositories/hutch_repository.dart';
import 'package:khodan/data/repositories/litter_repository.dart';
import 'package:khodan/features/litters/presentation/screens/litters_and_hutches_screen.dart';

void main() {
  setUp(() {
    InMemoryLitterRepository.reset();
    InMemoryHutchRepository.reset();
  });

  testWidgets('Litters tab displays seeded data', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<LitterRepository>.value(
            value: InMemoryLitterRepository(),
          ),
          RepositoryProvider<HutchRepository>.value(
            value: InMemoryHutchRepository(),
          ),
        ],
        child: const MaterialApp(
          home: LittersAndHutchesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('P-2025-18'), findsOneWidget);
    expect(find.text('Nouvelle portee'), findsOneWidget);
    expect(find.textContaining('Cage C-205'), findsOneWidget);
    expect(find.text('Clapiers'), findsOneWidget);
  });
}
