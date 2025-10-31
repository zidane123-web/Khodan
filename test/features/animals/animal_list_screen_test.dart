import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/features/animals/presentation/screens/animal_list_screen.dart';

class _MockLocalAnimalDataSource extends Mock implements LocalAnimalDataSource {}

final Animal _dummyAnimal = Animal(
  id: 'dummy',
  profileId: 'profile',
  speciesId: 1,
  tagId: 'D-001',
  birthDate: DateTime(2020, 1, 1),
  sex: 'Femelle',
  status: 'Actif',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_dummyAnimal);
    registerFallbackValue(<Animal>[]);
  });

  testWidgets('renders sample animals list', (WidgetTester tester) async {
    final AnimalRepository animalRepository = InMemoryAnimalRepository();
    final BreedingRepository breedingRepository = InMemoryBreedingRepository();
    final _MockLocalAnimalDataSource localSource = _MockLocalAnimalDataSource();

    when(() => localSource.replaceAnimals(any(), profileId: any(named: 'profileId')))
        .thenAnswer((Invocation _) async {});
    when(() => localSource.fetchAnimals(profileId: any(named: 'profileId'), speciesId: any(named: 'speciesId')))
        .thenAnswer((Invocation _) async => <Animal>[]);
    when(() => localSource.upsertAnimal(any(), syncState: any(named: 'syncState')))
        .thenAnswer((Invocation _) async {});
    when(() => localSource.deleteAnimal(any()))
        .thenAnswer((Invocation _) async {});

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<AnimalRepository>.value(value: animalRepository),
          RepositoryProvider<BreedingRepository>.value(value: breedingRepository),
          RepositoryProvider<LocalAnimalDataSource>.value(value: localSource),
        ],
        child: const MaterialApp(home: AnimalListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fiona'), findsOneWidget);
  });
}
