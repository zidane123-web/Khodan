import 'package:flutter_test/flutter_test.dart';
import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/services/offline_sync_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalAnimalDataSource extends Mock
    implements LocalAnimalDataSource {}

class _FakeRemoteAnimalRepository implements AnimalRepository {
  _FakeRemoteAnimalRepository(this._animals);

  List<Animal> _animals;
  bool fetchCalled = false;

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    fetchCalled = true;
    return _animals;
  }

  @override
  Future<Animal> createAnimal(Animal animal) async {
    _animals = <Animal>[animal];
    return animal;
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async => animal;

  @override
  Future<void> deleteAnimal(String id) async {}
}

void main() {
  late _MockLocalAnimalDataSource local;
  late _FakeRemoteAnimalRepository remote;
  late SyncedAnimalRepository repository;

  final Animal sample = Animal(
    id: 'animal-1',
    profileId: 'profile-1',
    speciesId: 1,
    tagId: 'A-001',
    birthDate: DateTime(2024, 1, 1),
    sex: 'Femelle',
    status: 'Actif',
  );

  setUpAll(() {
    registerFallbackValue(<Animal>[]);
  });

  setUp(() {
    local = _MockLocalAnimalDataSource();
    remote = _FakeRemoteAnimalRepository(<Animal>[sample]);
    repository = SyncedAnimalRepository(
      remote: remote,
      local: local,
      offlineManager: OfflineSyncManager.instance,
    );
  });

  tearDown(() {
    OfflineSyncManager.instance.setOffline(false, flushWhenOnline: false);
  });

  test('fetchAnimals returns cached values when offline', () async {
    OfflineSyncManager.instance.setOffline(true, flushWhenOnline: false);
    when(
      () => local.fetchAnimals(
        profileId: any(named: 'profileId'),
        speciesId: any(named: 'speciesId'),
      ),
    ).thenAnswer((_) async => <Animal>[sample]);

    final List<Animal> result = await repository.fetchAnimals();

    expect(remote.fetchCalled, isFalse);
    expect(result, <Animal>[sample]);
  });

  test('fetchAnimals updates cache when online', () async {
    when(
      () => local.fetchAnimals(
        profileId: any(named: 'profileId'),
        speciesId: any(named: 'speciesId'),
      ),
    ).thenAnswer((_) async => <Animal>[]);
    when(
      () => local.replaceAnimals(
        any(),
        profileId: any(named: 'profileId'),
      ),
    ).thenAnswer((_) async {});

    final List<Animal> result = await repository.fetchAnimals();

    expect(remote.fetchCalled, isTrue);
    expect(result, <Animal>[sample]);
    verify(
      () => local.replaceAnimals(
        <Animal>[sample],
        profileId: any(named: 'profileId'),
      ),
    ).called(1);
  });
}
