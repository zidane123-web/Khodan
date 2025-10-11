import '../entities/animal_entity.dart';

abstract class AnimalRepositoryInterface {
  Future<List<AnimalEntity>> fetchAnimals({
    String? farmId,
    String? status,
  });

  Future<AnimalEntity> getAnimal(String id);

  Future<String> createAnimal(AnimalEntity animal);

  Future<void> updateAnimal(AnimalEntity animal);

  Future<void> deleteAnimal(String id);
}
