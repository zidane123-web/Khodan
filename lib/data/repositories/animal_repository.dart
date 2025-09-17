import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/animal.dart';

abstract class AnimalRepository {
  Future<List<Animal>> fetchAnimals({int? speciesId});

  Future<Animal> createAnimal(Animal animal);

  Future<Animal> updateAnimal(Animal animal);

  Future<void> deleteAnimal(String id);
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
