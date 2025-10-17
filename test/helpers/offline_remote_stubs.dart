import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/breeding_record.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';

class RecordingAnimalRepository implements AnimalRepository {
  int fetchCount = 0;

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    fetchCount += 1;
    throw StateError('Remote animal fetch invoked while offline');
  }

  @override
  Future<Animal> createAnimal(Animal animal) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAnimal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Animal> updateAnimal(Animal animal) {
    throw UnimplementedError();
  }
}

class RecordingBreedingRepository implements BreedingRepository {
  int fetchCount = 0;

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBreedingRecord(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    fetchCount += 1;
    throw StateError('Remote breeding fetch invoked while offline');
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) {
    throw UnimplementedError();
  }
}

class RecordingEventRepository implements EventRepository {
  int fetchEventsCount = 0;
  int fetchLinksCount = 0;

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    fetchEventsCount += 1;
    throw StateError('Remote event fetch invoked while offline');
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    fetchLinksCount += 1;
    throw StateError('Remote event links fetch invoked while offline');
  }
}
