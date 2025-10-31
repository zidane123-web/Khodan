import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/breeding_record.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/features/planning/domain/models/planning_filters.dart';
import 'package:khodan/features/planning/domain/models/schedule_task.dart';
import 'package:khodan/features/planning/presentation/cubit/planning_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlanningCubit filtering', () {
    late PlanningCubit cubit;
    late DateTime referenceNow;

    setUp(() {
      referenceNow = DateTime.now();

      final List<LivestockEvent> events = <LivestockEvent>[
        LivestockEvent(
          id: 'event-planned',
          profileId: 'demo',
          eventType: 'inventory',
          eventDate: referenceNow.add(const Duration(days: 2)),
          details: <String, dynamic>{
            'status': 'planned',
            'animalIds': <String>['doe-001'],
          },
          notes: 'Inventaire aliments',
        ),
        LivestockEvent(
          id: 'event-completed',
          profileId: 'demo',
          eventType: 'health_check',
          eventDate: referenceNow.subtract(const Duration(days: 1)),
          details: <String, dynamic>{
            'status': 'completed',
            'animalIds': <String>['doe-002'],
          },
          notes: 'Controle effectue',
        ),
      ];

      final List<AnimalEventLink> links = <AnimalEventLink>[
        const AnimalEventLink(
          eventId: 'event-planned',
          animalId: 'doe-001',
          role: 'subject',
        ),
        const AnimalEventLink(
          eventId: 'event-completed',
          animalId: 'doe-002',
          role: 'subject',
        ),
      ];

      final List<Animal> animals = <Animal>[
        Animal(
          id: 'doe-001',
          profileId: 'demo',
          speciesId: 1,
          tagId: 'F01',
          name: 'Fiona',
          birthDate: referenceNow.subtract(const Duration(days: 300)),
          sex: 'Femelle',
          status: 'Actif',
          category: 'Lapine',
        ),
        Animal(
          id: 'doe-002',
          profileId: 'demo',
          speciesId: 1,
          tagId: 'F02',
          name: 'Opale',
          birthDate: referenceNow.subtract(const Duration(days: 280)),
          sex: 'Femelle',
          status: 'Actif',
          category: 'Lapine',
        ),
      ];

      final List<BreedingRecord> records = <BreedingRecord>[
        BreedingRecord(
          id: 'breeding-01',
          profileId: 'demo',
          doeId: 'doe-001',
          buckId: 'buck-001',
          matingDate: referenceNow.subtract(const Duration(days: 12)),
        ),
      ];

      cubit = PlanningCubit(
        eventRepository: _StubEventRepository(events: events, links: links),
        breedingRepository: _StubBreedingRepository(records: records),
        animalRepository: _StubAnimalRepository(animals: animals),
        now: () => referenceNow,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('filters planned and completed tasks based on status chip', () async {
      await cubit.load();

      final List<String> initialIds = cubit.state.filteredTasks
          .map((ScheduleTask task) => task.id)
          .toList();
      expect(initialIds, contains('event-planned'));
      expect(initialIds, isNot(contains('event-completed')));

      cubit.toggleStatusFilter(ScheduleTaskStatus.planned);
      final List<String> withoutPlanned = cubit.state.filteredTasks
          .map((ScheduleTask task) => task.id)
          .toList();
      expect(withoutPlanned, isNot(contains('event-planned')));

      cubit.toggleStatusFilter(ScheduleTaskStatus.planned);
      final List<String> restored = cubit.state.filteredTasks
          .map((ScheduleTask task) => task.id)
          .toList();
      expect(restored, contains('event-planned'));

      cubit.toggleStatusFilter(ScheduleTaskStatus.completed);
      expect(
        cubit.state.filters.statuses.contains(ScheduleTaskStatus.completed),
        isTrue,
      );
    });

    test('search filters by subject name', () async {
      await cubit.load();
      cubit.updateSearch('Fiona');

      expect(cubit.state.filteredTasks, isNotEmpty);
      for (final ScheduleTask task in cubit.state.filteredTasks) {
        expect(task.subjects.join(' ').toLowerCase(), contains('fiona'));
      }
    });

    test('period filter keeps overdue tasks', () async {
      await cubit.load();
      cubit.setPeriodFilter(PlanningPeriod.today);

      final Iterable<String> taskIds = cubit.state.filteredTasks.map(
        (ScheduleTask task) => task.id,
      );
      expect(taskIds, contains('breeding:breeding-01:palpation'));
      expect(taskIds, isNot(contains('event-planned')));
    });
  });
}

class _StubEventRepository implements EventRepository {
  _StubEventRepository({required this.events, required this.links});

  final List<LivestockEvent> events;
  final List<AnimalEventLink> links;

  @override
  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    return events;
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    return links;
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEvent(String id) {
    throw UnimplementedError();
  }

  @override
  Future<LivestockEvent> updateEvent(LivestockEvent event) {
    throw UnimplementedError();
  }
}

class _StubBreedingRepository implements BreedingRepository {
  _StubBreedingRepository({required this.records});

  final List<BreedingRecord> records;

  @override
  Future<List<BreedingRecord>> fetchBreedingRecords() async {
    return records;
  }

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBreedingRecord(String id) {
    throw UnimplementedError();
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) {
    throw UnimplementedError();
  }
}

class _StubAnimalRepository implements AnimalRepository {
  _StubAnimalRepository({required this.animals});

  final List<Animal> animals;

  @override
  Future<List<Animal>> fetchAnimals({int? speciesId}) async {
    return animals;
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
