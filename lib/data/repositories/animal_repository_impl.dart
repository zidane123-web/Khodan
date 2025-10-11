import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/animals/entities/animal_entity.dart';
import '../../../domain/animals/repositories/animal_repository_interface.dart';
import '../../models/animal.dart';

class AnimalRepository implements AnimalRepositoryInterface {
  AnimalRepository(this.client);

  final SupabaseClient client;

  static const String table = 'animals';

  @override
  Future<List<AnimalEntity>> fetchAnimals({String? farmId, String? status}) async {
    final query = client.from(table).select();
    if (farmId != null) {
      query.eq('farm_id', farmId);
    }
    if (status != null) {
      query.eq('status', status);
    }

    final result = await query.order('created_at', ascending: false);
    return result
        .map((row) => Animal.fromJson(row as Map<String, dynamic>))
        .map((model) => AnimalEntity(
              id: model.id,
              farmId: farmId ?? '',
              speciesId: model.speciesId,
              tagId: model.tagId,
              sex: model.sex,
              status: model.status,
              birthDate: model.birthDate,
              profileId: model.profileId,
              name: model.name,
              imageUrl: model.imageUrl,
              sireId: model.sireId,
              damId: model.damId,
              cageNumber: model.cageNumber,
              origin: model.origin,
              entryDate: model.entryDate,
              firstBreedingDate: model.firstBreedingDate,
            ))
        .toList();
  }

  @override
  Future<AnimalEntity> getAnimal(String id) async {
    final data = await client.from(table).select().eq('id', id).maybeSingle();
    if (data == null) {
      throw Exception('Animal not found');
    }
    final model = Animal.fromJson(data as Map<String, dynamic>);
    return AnimalEntity(
      id: model.id,
      farmId: data['farm_id'] as String? ?? '',
      speciesId: model.speciesId,
      tagId: model.tagId,
      sex: model.sex,
      status: model.status,
      birthDate: model.birthDate,
      profileId: model.profileId,
      name: model.name,
      imageUrl: model.imageUrl,
      sireId: model.sireId,
      damId: model.damId,
      cageNumber: model.cageNumber,
      origin: model.origin,
      entryDate: model.entryDate,
      firstBreedingDate: model.firstBreedingDate,
    );
  }

  @override
  Future<String> createAnimal(AnimalEntity animal) async {
    final response = await client.from(table).insert(<String, dynamic>{
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
    return response['id'] as String;
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
}
