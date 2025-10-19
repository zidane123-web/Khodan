import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/species_config.dart';
import 'package:khodan/data/repositories/species_repository.dart';
import 'package:khodan/features/settings/presentation/cubit/species_cubit.dart';

class _MockSpeciesRepository extends Mock implements SpeciesRepository {}

SpeciesConfig _buildSpecies({int id = 1}) {
  return SpeciesConfig(
    id: id,
    profileId: 'profile',
    speciesName: 'Lapin',
    gestationDays: 31,
    weaningDays: 35,
    eventsSchema: const <String>['accouplement', 'mise bas'],
  );
}

void main() {
  late _MockSpeciesRepository repository;
  late SpeciesCubit cubit;

  setUpAll(() {
    registerFallbackValue(_buildSpecies());
  });

  setUp(() {
    repository = _MockSpeciesRepository();
    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[]);
    cubit = SpeciesCubit(repository, profileId: 'profile');
  });

  test('initialize loads species list', () async {
    await cubit.initialize();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.species, isEmpty);
    verify(() => repository.fetchSpecies('profile')).called(1);
  });

  test('saveSpecies creates a new species and refreshes list', () async {
    await cubit.initialize();

    final SpeciesConfig created = _buildSpecies(id: 10);
    when(() => repository.createSpecies(any())).thenAnswer((_) async => created);
    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[created]);

    await cubit.saveSpecies(
      name: 'Lapin',
      gestationDays: 31,
      weaningDays: 35,
      eventsSchema: const <String>['accouplement'],
    );

    expect(cubit.state.species, <SpeciesConfig>[created]);
    expect(cubit.state.successMessage, isNotNull);
    verify(() => repository.createSpecies(any())).called(1);
    verify(() => repository.fetchSpecies('profile')).called(greaterThanOrEqualTo(2));
  });

  test('saveSpecies updates existing species', () async {
    final SpeciesConfig existing = _buildSpecies(id: 2);
    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[existing]);
    await cubit.initialize();
    expect(cubit.state.species, <SpeciesConfig>[existing]);

    final SpeciesConfig updated = existing.copyWith(speciesName: 'Lapin Belier');
    when(() => repository.updateSpecies(any())).thenAnswer((_) async => updated);
    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[updated]);

    await cubit.saveSpecies(
      id: existing.id,
      name: 'Lapin Belier',
      gestationDays: existing.gestationDays,
      weaningDays: existing.weaningDays,
      eventsSchema: existing.eventsSchema,
    );

    expect(cubit.state.species.first.speciesName, 'Lapin Belier');
    verify(() => repository.updateSpecies(any())).called(1);
  });

  test('deleteSpecies removes species and refreshes list', () async {
    final SpeciesConfig existing = _buildSpecies(id: 3);
    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[existing]);
    await cubit.initialize();

    when(() => repository.fetchSpecies('profile'))
        .thenAnswer((_) async => <SpeciesConfig>[]);
    when(() => repository.deleteSpecies(existing.id))
        .thenAnswer((_) async {});

    await cubit.deleteSpecies(existing.id);

    expect(cubit.state.species, isEmpty);
    verify(() => repository.deleteSpecies(existing.id)).called(1);
  });
}

