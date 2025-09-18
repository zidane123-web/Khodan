import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/animal.dart';

abstract class AnimalRepository {
  Future<List<Animal>> fetchAnimals({int? speciesId});

  Future<Animal> createAnimal(Animal animal);

  Future<Animal> updateAnimal(Animal animal);

  Future<void> deleteAnimal(String id);
}

class InMemoryAnimalRepository implements AnimalRepository {
  factory InMemoryAnimalRepository() => _instance;

  InMemoryAnimalRepository._internal();

  static final InMemoryAnimalRepository _instance =
      InMemoryAnimalRepository._internal();

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
  SupabaseAnimalRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    PostgrestFilterBuilder<dynamic> query = _client.from('animals').select();

    if (speciesId != null) {
      query = query.eq('species_id', speciesId);
    }

    final List<dynamic> data = await query.order('birth_date');
    return data
        .map((dynamic row) => Animal.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Animal> createAnimal(Animal animal) async {
    final List<dynamic> response = await _client
        .from('animals')
        .insert(animal.toJson())
        .select();
    return Animal.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<Animal> updateAnimal(Animal animal) async {
    final List<dynamic> response = await _client
        .from('animals')
        .update(animal.toJson())
        .eq('id', animal.id)
        .select();
    return Animal.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAnimal(String id) {
    return _client.from('animals').delete().eq('id', id);
  }
}
