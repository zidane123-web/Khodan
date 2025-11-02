import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/pedigree.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/services/pedigree_service.dart';
import 'package:khodan/features/pedigrees/presentation/pages/pedigree_page.dart';

class MockPedigreeService extends Mock implements PedigreeService {}

class MockAnimalRepository extends Mock implements AnimalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PedigreePage', () {
    late MockPedigreeService service;
    late MockAnimalRepository repository;
    late Animal sampleAnimal;
    late PedigreeTree tree;

    setUp(() {
      service = MockPedigreeService();
      repository = MockAnimalRepository();
      sampleAnimal = Animal(
        id: 'root-id',
        profileId: 'profile-1',
        speciesId: 1,
        tagId: 'F01',
        name: 'Fiona',
        birthDate: DateTime(2024, 1, 1),
        sex: 'Femelle',
        status: 'Actif',
      );

      when(
        () => repository.fetchAnimals(),
      ).thenAnswer((_) async => <Animal>[sampleAnimal]);

      tree = PedigreeTree.fromRows(<Map<String, dynamic>>[
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': 'root-id',
          'generation': 0,
          'relation_path': '',
          'relation_side': 'root',
          'relation_label': 'Sujet',
          'tag_id': 'F01',
          'display_name': 'Fiona',
          'registered_name': 'Fiona',
          'sex': 'Femelle',
          'status': 'Actif',
          'birth_date': '2024-01-01',
          'entry_date': '2024-02-01',
          'cage_number': 'C101',
          'origin': 'Elevage interne',
          'species_id': 1,
          'missing': false,
          'last_mating_date': '2024-03-01',
          'last_kindling_date': null,
          'last_weaning_date': null,
          'node': <String, dynamic>{'id': 'root-id'},
        },
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': 'father-id',
          'generation': 1,
          'relation_path': 'P',
          'relation_side': 'P',
          'relation_label': 'Pere',
          'tag_id': 'M01',
          'display_name': 'Jasper',
          'registered_name': 'Jasper',
          'sex': 'Male',
          'status': 'Actif',
          'birth_date': '2022-01-01',
          'entry_date': '2022-02-01',
          'cage_number': 'C205',
          'origin': 'Elevage interne',
          'species_id': 1,
          'missing': false,
          'last_mating_date': '2024-02-15',
          'last_kindling_date': '2024-03-15',
          'last_weaning_date': null,
          'node': <String, dynamic>{'id': 'father-id'},
        },
        <String, dynamic>{
          'profile_id': 'profile-1',
          'breeder_id': null,
          'generation': 1,
          'relation_path': 'M',
          'relation_side': 'M',
          'relation_label': 'Mere',
          'tag_id': null,
          'display_name': null,
          'registered_name': null,
          'sex': null,
          'status': null,
          'birth_date': null,
          'entry_date': null,
          'cage_number': null,
          'origin': null,
          'species_id': 1,
          'missing': true,
          'last_mating_date': null,
          'last_kindling_date': null,
          'last_weaning_date': null,
          'node': null,
        },
      ], requestedGenerations: 4);

      when(
        () => service.fetchTree(breederId: sampleAnimal.id, generations: 4),
      ).thenAnswer((_) async => tree);
      when(
        () => service.buildShareLink(
          sampleAnimal.id,
          profileId: 'profile-1',
        ),
      ).thenReturn(Uri.parse('https://khodan.app/mock-share'));
    });

    testWidgets('affiche un pedigree simple avec message manquant', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: <RepositoryProvider<dynamic>>[
            RepositoryProvider<AnimalRepository>.value(value: repository),
            RepositoryProvider<PedigreeService>.value(value: service),
          ],
          child: const MaterialApp(home: PedigreePage()),
        ),
      );

      await tester.pumpAndSettle();

      // Ouvre la liste deroulante et selectionne le lapin.
      await tester.tap(find.byType(DropdownButtonFormField<Animal>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Fiona').last);
      await tester.pumpAndSettle();

      expect(find.text('Apercu'), findsOneWidget);
      expect(find.text('Certificat de naissance'), findsOneWidget);
      expect(find.text('Information a completer'), findsWidgets);

      verify(
        () => service.fetchTree(breederId: sampleAnimal.id, generations: 4),
      ).called(1);
    });
  });
}

