import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/animals/entities/animal_entity.dart';
import '../../../domain/animals/repositories/animal_repository_interface.dart';

class AnimalRepository implements AnimalRepositoryInterface {
  AnimalRepository(this.client);

  final SupabaseClient client;

  static const String table = 'animals';

  @override
  Future<List<AnimalEntity>> fetchAnimals({String? farmId, String? status}) async {
    final PostgrestFilterBuilder<dynamic> query = client.from(table).select();
    if (farmId != null) {
      query.eq('farm_id', farmId);
    }
    if (status != null) {
      query.eq('status', status);
    }

    final List<dynamic> result = await query.order('created_at', ascending: false);
    return result
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .map(_mapRow)
        .toList();
  }

  @override
  Future<AnimalEntity> getAnimal(String id) async {
    final dynamic data = await client.from(table).select().eq('id', id).maybeSingle();
    if (data == null) {
      throw Exception('Animal not found');
    }
    return _mapRow(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<String> createAnimal(AnimalEntity animal) async {
    final dynamic response = await client.from(table).insert(<String, dynamic>{
      'farm_id': animal.farmId,
      'species_id': animal.speciesId,
      'tag_id': animal.tagId,
      'sex': animal.sex,
      'status': animal.status,
      'birth_date': animal.birthDate.toIso8601String(),
      'profile_id': animal.profileId,
      'name': animal.name,
      'image_url': animal.imageUrl,
      'sire_id': animal.sireId,
      'dam_id': animal.damId,
      'cage_number': animal.cageNumber,
      'origin': animal.origin,
      'entry_date': animal.entryDate?.toIso8601String(),
      'first_breeding_date': animal.firstBreedingDate?.toIso8601String(),
    }).select('id').maybeSingle();

    if (response == null) {
      throw Exception('Failed to create animal');
    }
    return (response as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> updateAnimal(AnimalEntity animal) async {
    await client.from(table).update(<String, dynamic>{
      'species_id': animal.speciesId,
      'tag_id': animal.tagId,
      'sex': animal.sex,
      'status': animal.status,
      'birth_date': animal.birthDate.toIso8601String(),
      'profile_id': animal.profileId,
      'name': animal.name,
      'image_url': animal.imageUrl,
      'sire_id': animal.sireId,
      'dam_id': animal.damId,
      'cage_number': animal.cageNumber,
      'origin': animal.origin,
      'entry_date': animal.entryDate?.toIso8601String(),
      'first_breeding_date': animal.firstBreedingDate?.toIso8601String(),
    }).eq('id', animal.id);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    await client.from(table).delete().eq('id', id);
  }

  AnimalEntity _mapRow(Map<String, dynamic> row) {
    DateTime? parseDate(dynamic value) => value == null ? null : DateTime.parse(value as String);

    return AnimalEntity(
      id: row['id'] as String,
      farmId: row['farm_id'] as String? ?? '',
      speciesId: row['species_id'] as int,
      tagId: row['tag_id'] as String,
      sex: row['sex'] as String,
      status: row['status'] as String,
      birthDate: DateTime.parse(row['birth_date'] as String),
      profileId: row['profile_id'] as String?,
      name: row['name'] as String?,
      imageUrl: row['image_url'] as String?,
      sireId: row['sire_id'] as String?,
      damId: row['dam_id'] as String?,
      cageNumber: row['cage_number'] as String?,
      origin: row['origin'] as String?,
      entryDate: parseDate(row['entry_date']),
      firstBreedingDate: parseDate(row['first_breeding_date']),
    );
  }
}
