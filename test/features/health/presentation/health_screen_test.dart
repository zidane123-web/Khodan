import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/health_repository.dart';
import 'package:khodan/features/health/presentation/screens/health_screen.dart';
import 'package:khodan/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows health library results', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<HealthRepository>(
            create: (_) => InMemoryHealthRepository(),
          ),
          RepositoryProvider<AnimalRepository>(
            create: (_) => InMemoryAnimalRepository(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HealthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Coccidiosis'), findsOneWidget);
  });
}
