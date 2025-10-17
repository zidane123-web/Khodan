import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/animal.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class AnimalRepository {
  Future<List<Animal>> fetchAnimals({int? speciesId});

  Future<Animal> createAnimal(Animal animal);

  Future<Animal> updateAnimal(Animal animal);

  Future<void> deleteAnimal(String id);
}

class InMemoryAnimalRepository implements AnimalRepository {
  factory InMemoryAnimalRepository() => _instance;

  InMemoryAnimalRepository._internal();

  static InMemoryAnimalRepository _instance =
      InMemoryAnimalRepository._internal();

  static void reset() {
    _instance = InMemoryAnimalRepository._internal();
  }

  final List<Animal> _animals = <Animal>[
    Animal(
      id: 'doe-001',
      profileId: 'demo-profile',
      speciesId: 1,
      tagId: 'F01',
      name: 'Fiona',
      birthDate: DateTime.now().subtract(const Duration(days: 420)),
      sex: 'Femelle',
      status: 'Vivant',
      cageNumber: 'C-101',
      origin: 'Élevage interne',
      entryDate: DateTime.now().subtract(const Duration(days: 390)),
      firstBreedingDate: DateTime.now().subtract(const Duration(days: 320)),
    ),
    Animal(
      id: 'doe-002',
      profileId: 'demo-profile',
      speciesId: 1,
      tagId: 'F02',
      name: 'Opale',
      birthDate: DateTime.now().subtract(const Duration(days: 360)),
      sex: 'Femelle',
      status: 'Vivant',
      cageNumber: 'C-108',
      origin: 'Achat - Ferme Martin',
      entryDate: DateTime.now().subtract(const Duration(days: 200)),
      firstBreedingDate: DateTime.now().subtract(const Duration(days: 40)),
    ),
    Animal(
      id: 'buck-001',
      profileId: 'demo-profile',
      speciesId: 1,
      tagId: 'M01',
      name: 'Jasper',
      birthDate: DateTime.now().subtract(const Duration(days: 500)),
      sex: 'Mâle',
      status: 'Vivant',
      cageNumber: 'C-205',
      origin: 'Élevage interne',
      entryDate: DateTime.now().subtract(const Duration(days: 470)),
    ),
    Animal(
      id: 'buck-002',
      profileId: 'demo-profile',
      speciesId: 1,
      tagId: 'M02',
      name: 'Gabin',
      birthDate: DateTime.now().subtract(const Duration(days: 610)),
      sex: 'Mâle',
      status: 'Vivant',
      cageNumber: 'C-208',
      origin: 'Achat - Ferme Martin',
      entryDate: DateTime.now().subtract(const Duration(days: 580)),
    ),
    Animal(
      id: 'doe-003',
      profileId: 'demo-profile',
      speciesId: 1,
      tagId: 'F03',
      birthDate: DateTime.now().subtract(const Duration(days: 280)),
      sex: 'Femelle',
      status: 'Vendu',
      cageNumber: 'C-115',
      origin: 'Achat - Marché local',
      entryDate: DateTime.now().subtract(const Duration(days: 250)),
    ),
  ];

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    final List<Animal> animals = speciesId == null
        ? List<Animal>.from(_animals)
        : _animals
            .where((Animal animal) => animal.speciesId == speciesId)
            .toList();
    animals.sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));
    return animals;
  }

  @override
  Future<Animal> createAnimal(Animal animal) async {
    final Animal created = animal.copyWith(
      id: 'animal-${DateTime.now().millisecondsSinceEpoch}',
    );
    _animals.add(created);
    return created;
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    final int index = _animals.indexWhere((Animal element) => element.id == animal.id);
    if (index == -1) {
      throw StateError('Animal ${animal.id} introuvable');
    }
    _animals[index] = animal;
    return animal;
  }

  @override
  Future<void> deleteAnimal(String id) async {
    _animals.removeWhere((Animal animal) => animal.id == id);
  }
}

class SupabaseAnimalRepository implements AnimalRepository {
  SupabaseAnimalRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    final List<dynamic> data = await _api.run(
      (SupabaseClient client) {
        dynamic query = client.from('animals').select();
        if (speciesId != null) {
          query = query.eq('species_id', speciesId);
        }
        return query.order('birth_date');
      },
      label: 'animals.fetch',
    );
    return data
        .map((dynamic row) => Animal.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Animal> createAnimal(Animal animal) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client.from('animals').insert(animal.toJson()).select();
      },
      label: 'animals.create',
    );
    return Animal.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('animals')
            .update(animal.toJson())
            .eq('id', animal.id)
            .select();
      },
      label: 'animals.update',
    );
    return Animal.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAnimal(String id) {
    return _api.run(
      (SupabaseClient client) {
        return client.from('animals').delete().eq('id', id);
      },
      label: 'animals.delete',
    );
  }
}

class SyncedAnimalRepository implements AnimalRepository {
  SyncedAnimalRepository({
    required AnimalRepository remote,
    required LocalAnimalDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance;

  final AnimalRepository _remote;
  final LocalAnimalDataSource _local;
  final OfflineSyncManager _offlineManager;

  String? get _currentProfileId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    final String? profileId = _currentProfileId;
    if (_offlineManager.isOffline.value) {
      return _local.fetchAnimals(
        profileId: profileId,
        speciesId: speciesId,
      );
    }

    try {
      final List<Animal> animals =
          await _remote.fetchAnimals(speciesId: speciesId);
      if (animals.isNotEmpty) {
        await _local.replaceAnimals(
          animals,
          profileId: profileId,
        );
      } else if (profileId != null) {
        await _local.replaceAnimals(const <Animal>[], profileId: profileId);
      }
      return animals;
    } catch (error) {
      final List<Animal> cached = await _local.fetchAnimals(
        profileId: profileId,
        speciesId: speciesId,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<Animal> createAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertAnimal(
        animal,
        syncState: kSyncStatePending,
      );
      return animal;
    }

    final Animal created = await _remote.createAnimal(animal);
    await _local.upsertAnimal(created);
    return created;
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertAnimal(
        animal,
        syncState: kSyncStatePending,
      );
      return animal;
    }

    final Animal updated = await _remote.updateAnimal(animal);
    await _local.upsertAnimal(updated);
    return updated;
  }

  @override
  Future<void> deleteAnimal(String id) async {
    if (_offlineManager.isOffline.value) {
      await _local.deleteAnimal(id);
      return;
    }
    await _remote.deleteAnimal(id);
    await _local.deleteAnimal(id);
  }
}
