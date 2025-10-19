import 'dart:async';

import 'package:equatable/equatable.dart';

import '../models/animal.dart';
import '../models/animal_event.dart';
import '../models/breeding_record.dart';
import '../models/event.dart';
import '../repositories/animal_repository.dart';
import '../repositories/breeding_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/food_inventory_repository.dart';

class ReportDataset extends Equatable {
  const ReportDataset({
    required this.profileId,
    required this.animals,
    required this.breedingRecords,
    required this.events,
    required this.eventAnimalIds,
    required this.inventorySummary,
    required this.animalLots,
    required this.animalLocations,
    required this.availableLots,
    required this.availableLocations,
    required this.fetchedAt,
  });

  final String? profileId;
  final List<Animal> animals;
  final List<BreedingRecord> breedingRecords;
  final List<LivestockEvent> events;
  final Map<String, List<String>> eventAnimalIds;
  final InventorySummary? inventorySummary;
  final Map<String, String> animalLots;
  final Map<String, String> animalLocations;
  final List<String> availableLots;
  final List<String> availableLocations;
  final DateTime fetchedAt;

  @override
  List<Object?> get props => <Object?>[
        profileId,
        animals,
        breedingRecords,
        events,
        eventAnimalIds,
        inventorySummary,
        animalLots,
        animalLocations,
        availableLots,
        availableLocations,
        fetchedAt,
      ];
}

class ReportingService {
  ReportingService({
    required BreedingRepository breedingRepository,
    required AnimalRepository animalRepository,
    required EventRepository eventRepository,
    required FoodInventoryRepository inventoryRepository,
  })  : _breedingRepository = breedingRepository,
        _animalRepository = animalRepository,
        _eventRepository = eventRepository,
        _inventoryRepository = inventoryRepository;

  final BreedingRepository _breedingRepository;
  final AnimalRepository _animalRepository;
  final EventRepository _eventRepository;
  final FoodInventoryRepository _inventoryRepository;

  final Map<String, _CachedDataset> _cache = <String, _CachedDataset>{};
  static const Duration _cacheTtl = Duration(minutes: 5);

  Future<ReportDataset> loadDataset({
    required String? profileId,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = profileId ?? '_anonymous';
    final _CachedDataset? cached = _cache[cacheKey];
    if (!forceRefresh && cached != null && !_isExpired(cached)) {
      return cached.dataset;
    }

    final DateTime eventsStart =
        DateTime.now().subtract(const Duration(days: 365));
    final DateTime eventsEnd = DateTime.now().add(const Duration(days: 1));

    final List<Animal> animals = await _animalRepository.fetchAnimals();
    final List<BreedingRecord> breedingRecords =
        await _breedingRepository.fetchBreedingRecords();
    final List<LivestockEvent> events = await _eventRepository.fetchEvents(
      start: eventsStart,
      end: eventsEnd,
    );
    final List<AnimalEventLink> eventLinks =
        await _eventRepository.fetchEventLinks();

    InventorySummary? summary;
    if (profileId != null && profileId.isNotEmpty) {
      try {
        summary = await _inventoryRepository.computeSummary(profileId);
      } catch (_) {
        summary = null;
      }
    }

    final List<Animal> filteredAnimals = animals
        .where(
          (Animal animal) =>
              profileId == null || animal.profileId == profileId,
        )
        .toList()
      ..sort((Animal a, Animal b) => a.tagId.compareTo(b.tagId));

    final Set<String>? allowedProfile =
        profileId == null ? null : <String>{profileId};

    final List<BreedingRecord> filteredRecords = breedingRecords
        .where(
          (BreedingRecord record) =>
              allowedProfile == null ||
              allowedProfile.contains(record.profileId),
        )
        .toList();

    final List<LivestockEvent> filteredEvents = events
        .where(
          (LivestockEvent event) =>
              allowedProfile == null ||
              allowedProfile.contains(event.profileId),
        )
        .toList()
      ..sort(
        (LivestockEvent a, LivestockEvent b) =>
            b.eventDate.compareTo(a.eventDate),
      );

    final Map<String, List<String>> animalsByEvent = <String, List<String>>{};
    for (final AnimalEventLink link in eventLinks) {
      animalsByEvent
          .putIfAbsent(link.eventId, () => <String>[])
          .add(link.animalId);
    }

    final Map<String, String> lotsByAnimal = <String, String>{};
    final Map<String, String> locationsByAnimal = <String, String>{
      for (final Animal animal in filteredAnimals)
        if (animal.origin != null && animal.origin!.isNotEmpty)
          animal.id: animal.origin!,
    };

    final Set<String> availableLots = <String>{};
    final Set<String> availableLocations = <String>{
      ...locationsByAnimal.values,
    };

    for (final LivestockEvent event in filteredEvents) {
      final List<String> linkedAnimals =
          animalsByEvent[event.id] ?? <String>[];
      if (linkedAnimals.isEmpty) {
        continue;
      }
      final Map<String, dynamic> details = event.details;
      final String? lot = _extractStringField(
        details,
        const <String>['lot', 'lotNumber', 'batch', 'batchNumber'],
      );
      final String? location = _extractStringField(
        details,
        const <String>[
          'location',
          'site',
          'geography',
          'region',
          'area',
        ],
      );

      if (lot != null && lot.isNotEmpty) {
        availableLots.add(lot);
        for (final String animalId in linkedAnimals) {
          lotsByAnimal.putIfAbsent(animalId, () => lot);
        }
      }
      if (location != null && location.isNotEmpty) {
        availableLocations.add(location);
        for (final String animalId in linkedAnimals) {
          locationsByAnimal.putIfAbsent(animalId, () => location);
        }
      }
    }

    final ReportDataset dataset = ReportDataset(
      profileId: profileId,
      animals: filteredAnimals,
      breedingRecords: filteredRecords,
      events: filteredEvents,
      eventAnimalIds: animalsByEvent,
      inventorySummary: summary,
      animalLots: lotsByAnimal,
      animalLocations: locationsByAnimal,
      availableLots: availableLots.toList()..sort(),
      availableLocations: availableLocations.toList()..sort(),
      fetchedAt: DateTime.now(),
    );
    _cache[cacheKey] = _CachedDataset(dataset);
    return dataset;
  }

  bool _isExpired(_CachedDataset cached) {
    return DateTime.now().difference(cached.dataset.fetchedAt) > _cacheTtl;
  }

  static String? _extractStringField(
    Map<String, dynamic> details,
    List<String> keys,
  ) {
    for (final String key in keys) {
      if (!details.containsKey(key)) {
        continue;
      }
      final dynamic value = details[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

class _CachedDataset {
  _CachedDataset(this.dataset);

  final ReportDataset dataset;
}
