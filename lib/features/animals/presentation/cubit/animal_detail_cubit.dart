import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';

enum AnimalDetailStatus { initial, loading, success, failure }

class AnimalDetailState extends Equatable {
  const AnimalDetailState({
    required this.animal,
    this.status = AnimalDetailStatus.initial,
    this.timeline = const <AnimalTimelineEntry>[],
    this.performance,
    this.gallery = const <String>[],
    this.errorMessage,
  });

  final Animal animal;
  final AnimalDetailStatus status;
  final List<AnimalTimelineEntry> timeline;
  final AnimalPerformanceStats? performance;
  final List<String> gallery;
  final String? errorMessage;

  AnimalDetailState copyWith({
    Animal? animal,
    AnimalDetailStatus? status,
    List<AnimalTimelineEntry>? timeline,
    AnimalPerformanceStats? performance,
    List<String>? gallery,
    String? errorMessage,
  }) {
    return AnimalDetailState(
      animal: animal ?? this.animal,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      performance: performance ?? this.performance,
      gallery: gallery ?? this.gallery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        animal,
        status,
        timeline,
        performance,
        gallery,
        errorMessage,
      ];
}

class AnimalDetailCubit extends Cubit<AnimalDetailState> {
  AnimalDetailCubit(
    Animal animal,
    this._animalRepository,
    this._breedingRepository,
    this._eventRepository,
  ) : super(AnimalDetailState(animal: animal));

  final AnimalRepository _animalRepository;
  final BreedingRepository _breedingRepository;
  final EventRepository _eventRepository;

  Future<void> load() async {
    emit(state.copyWith(status: AnimalDetailStatus.loading));
    try {
      final List<Animal> animals = await _animalRepository.fetchAnimals();
      final Map<String, Animal> animalsById = <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };

      final List<BreedingRecord> records =
          await _breedingRepository.fetchBreedingRecords();
      final List<LivestockEvent> events = await _eventRepository.fetchEvents();
      final List<AnimalEventLink> links =
          await _eventRepository.fetchEventLinks();

      final Map<String, List<String>> eventAnimalMap =
          <String, List<String>>{};
      for (final AnimalEventLink link in links) {
        eventAnimalMap.update(
          link.eventId,
          (List<String> value) => <String>[...value, link.animalId],
          ifAbsent: () => <String>[link.animalId],
        );
      }

      final List<AnimalTimelineEntry> timeline = _buildTimeline(
        animal: state.animal,
        animalsById: animalsById,
        records: records,
        events: events,
        eventAnimalMap: eventAnimalMap,
      );

      final AnimalPerformanceStats performance = _buildPerformance(
        state.animal,
        records,
      );

      final List<String> gallery = _buildInitialGallery(state.animal);

      emit(
        state.copyWith(
          status: AnimalDetailStatus.success,
          timeline: timeline,
          performance: performance,
          gallery: gallery,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AnimalDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void addPhoto(String url) {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final List<String> updated = List<String>.from(state.gallery)
      ..add(trimmed);
    emit(state.copyWith(gallery: updated));
  }

  void removePhoto(String url) {
    final List<String> updated = state.gallery
        .where((String photo) => photo != url)
        .toList();
    emit(state.copyWith(gallery: updated));
  }

  List<AnimalTimelineEntry> _buildTimeline({
    required Animal animal,
    required Map<String, Animal> animalsById,
    required List<BreedingRecord> records,
    required List<LivestockEvent> events,
    required Map<String, List<String>> eventAnimalMap,
  }) {
    final List<AnimalTimelineEntry> entries = <AnimalTimelineEntry>[];

    entries.add(
      AnimalTimelineEntry(
        date: animal.birthDate,
        title: 'Naissance',
        description:
            animal.origin != null ? 'Origine : ${animal.origin}' : null,
        category: AnimalTimelineCategory.birth,
      ),
    );

    if (animal.entryDate != null) {
      entries.add(
        AnimalTimelineEntry(
          date: animal.entryDate!,
          title: 'Entrée dans l’élevage',
          description: animal.cageNumber != null
              ? 'Installé en cage ${animal.cageNumber}'
              : null,
          category: AnimalTimelineCategory.general,
        ),
      );
    }

    if (animal.firstBreedingDate != null) {
      final int ageAtFirstBreeding =
          animal.firstBreedingDate!.difference(animal.birthDate).inDays;
      entries.add(
        AnimalTimelineEntry(
          date: animal.firstBreedingDate!,
          title: 'Première saillie',
          description: 'À ${ageAtFirstBreeding.clamp(0, 9999)} jours',
          category: AnimalTimelineCategory.breeding,
        ),
      );
    }

    final Iterable<BreedingRecord> relatedRecords = records.where(
      (BreedingRecord record) =>
          record.doeId == animal.id || record.buckId == animal.id,
    );

    for (final BreedingRecord record in relatedRecords) {
      final bool isDoe = record.doeId == animal.id;
      final Animal? partner =
          animalsById[isDoe ? record.buckId : record.doeId];
      final String partnerLabel =
          _animalLabel(partner, isDoe ? record.buckId : record.doeId);

      entries.add(
        AnimalTimelineEntry(
          date: record.matingDate,
          title: 'Saillie avec $partnerLabel',
          category: AnimalTimelineCategory.breeding,
        ),
      );

      if (record.palpationDate != null && isDoe) {
        final bool? result = record.palpationPositive;
        final String title = result == true
            ? 'Palpation positive'
            : result == false
                ? 'Palpation négative'
                : 'Palpation réalisée';
        final String? description = result == true
            ? 'Gestation confirmée.'
            : result == false
                ? 'Prévoir une nouvelle saillie.'
                : null;
        entries.add(
          AnimalTimelineEntry(
            date: record.palpationDate!,
            title: title,
            description: description,
            category: AnimalTimelineCategory.breeding,
          ),
        );
      }

      if (record.kindlingDate != null) {
        final String title = isDoe ? 'Mise-bas' : 'Portée née';
        final String? description = record.kitsBornAlive != null
            ? '${record.kitsBornAlive} nés vivants'
            : null;
        entries.add(
          AnimalTimelineEntry(
            date: record.kindlingDate!,
            title: title,
            description: description,
            category: AnimalTimelineCategory.breeding,
          ),
        );
      }

      if (record.weaningDate != null) {
        final String title = isDoe ? 'Sevrage' : 'Descendance sevrée';
        final String? description = record.kitsWeaned != null
            ? '${record.kitsWeaned} lapereaux sevrés'
            : null;
        entries.add(
          AnimalTimelineEntry(
            date: record.weaningDate!,
            title: title,
            description: description,
            category: AnimalTimelineCategory.breeding,
          ),
        );
      }
    }

    for (final LivestockEvent event in events) {
      final List<String> linked = eventAnimalMap[event.id] ??
          _animalIdsFromEvent(event);
      if (!linked.contains(animal.id)) {
        continue;
      }
      entries.add(
        AnimalTimelineEntry(
          date: event.eventDate,
          title: _labelForEvent(event.eventType),
          description: _descriptionForEvent(event),
          category: _categoryForEvent(event.eventType),
        ),
      );
    }

    entries.sort(
      (AnimalTimelineEntry a, AnimalTimelineEntry b) =>
          b.date.compareTo(a.date),
    );
    return entries;
  }

  AnimalPerformanceStats _buildPerformance(
    Animal animal,
    List<BreedingRecord> records,
  ) {
    final String sex = animal.sex.toLowerCase();
    final bool isDoe = sex.contains('fem');
    final bool isBuck = sex.contains('mâl') || sex.contains('mal');

    final Iterable<BreedingRecord> relevantRecords = records.where(
      (BreedingRecord record) =>
          isDoe ? record.doeId == animal.id : record.buckId == animal.id,
    );

    final int totalMatings = relevantRecords.length;
    final int successfulMatings = relevantRecords
        .where((BreedingRecord record) => record.palpationPositive == true)
        .length;
    final int littersCount = relevantRecords
        .where((BreedingRecord record) => record.kindlingDate != null)
        .length;

    final double? successRate = totalMatings == 0
        ? null
        : successfulMatings / totalMatings;

    int totalKitsWeaned = 0;
    int sumBorn = 0;
    int bornCount = 0;
    int sumWeaned = 0;
    int weanedCount = 0;

    for (final BreedingRecord record in relevantRecords) {
      if (record.kitsBornAlive != null) {
        sumBorn += record.kitsBornAlive!;
        bornCount += 1;
      }
      if (record.kitsWeaned != null) {
        sumWeaned += record.kitsWeaned!;
        weanedCount += 1;
        totalKitsWeaned += record.kitsWeaned!;
      }
    }

    final double? averageBorn = bornCount == 0 ? null : sumBorn / bornCount;
    final double? averageWeaned =
        weanedCount == 0 ? null : sumWeaned / weanedCount;

    final AnimalReproductiveRole role = isDoe
        ? AnimalReproductiveRole.doe
        : isBuck
            ? AnimalReproductiveRole.buck
            : AnimalReproductiveRole.unknown;

    return AnimalPerformanceStats(
      role: role,
      totalMatings: totalMatings,
      successfulMatings: successfulMatings,
      littersCount: littersCount,
      successRate: successRate,
      averageKitsBornAlive: averageBorn,
      averageKitsWeaned: averageWeaned,
      totalKitsWeaned: totalKitsWeaned,
    );
  }

  List<String> _buildInitialGallery(Animal animal) {
    final List<String> gallery = <String>[];
    if (animal.imageUrl != null && animal.imageUrl!.isNotEmpty) {
      gallery.add(animal.imageUrl!);
    }
    final List<String>? samples = _sampleGallery[animal.id];
    if (samples != null) {
      gallery.addAll(samples);
    }
    return gallery;
  }

  String _animalLabel(Animal? animal, String fallbackId) {
    if (animal == null) {
      return fallbackId;
    }
    if (animal.name != null && animal.name!.isNotEmpty) {
      return '${animal.tagId} · ${animal.name}';
    }
    return animal.tagId;
  }

  List<String> _animalIdsFromEvent(LivestockEvent event) {
    final dynamic ids = event.details['animalIds'];
    if (ids is List) {
      return ids.whereType<String>().toList();
    }
    return <String>[];
  }

  AnimalTimelineCategory _categoryForEvent(String eventType) {
    switch (eventType) {
      case 'weight':
        return AnimalTimelineCategory.weight;
      case 'treatment':
      case 'health_check':
        return AnimalTimelineCategory.health;
      case 'cage_change':
        return AnimalTimelineCategory.housing;
      default:
        return AnimalTimelineCategory.general;
    }
  }

  String _labelForEvent(String eventType) {
    switch (eventType) {
      case 'weight':
        return 'Pesée';
      case 'treatment':
        return 'Traitement';
      case 'health_check':
        return 'Contrôle sanitaire';
      case 'cage_change':
        return 'Changement de cage';
      default:
        if (eventType.isEmpty) {
          return 'Événement';
        }
        final String normalized = eventType.replaceAll('_', ' ');
        return normalized[0].toUpperCase() + normalized.substring(1);
    }
  }

  String? _descriptionForEvent(LivestockEvent event) {
    switch (event.eventType) {
      case 'weight':
        final dynamic weight = event.details['weightKg'] ?? event.details['weight'];
        if (weight is num) {
          return 'Poids : ${weight.toStringAsFixed(2)} kg';
        }
        return null;
      case 'treatment':
        final String? treatment = event.details['treatment'] as String?;
        return treatment != null ? 'Soin : $treatment' : event.notes;
      case 'health_check':
        final String? veterinarian = event.details['veterinarian'] as String?;
        return veterinarian != null
            ? 'Vétérinaire : $veterinarian'
            : event.notes;
      case 'cage_change':
        final String? from = event.details['from'] as String?;
        final String? to = event.details['to'] as String?;
        if (from != null && to != null) {
          return 'De $from vers $to';
        }
        return event.notes;
      default:
        final String? description = event.details['description'] as String?;
        return description ?? event.notes;
    }
  }

  static const Map<String, List<String>> _sampleGallery = <String, List<String>>{
    'doe-001': <String>[
      'https://picsum.photos/seed/doe001/600/400',
      'https://picsum.photos/seed/doe001b/600/400',
    ],
    'doe-002': <String>[
      'https://picsum.photos/seed/doe002/600/400',
    ],
    'buck-001': <String>[
      'https://picsum.photos/seed/buck001/600/400',
    ],
    'buck-002': <String>[
      'https://picsum.photos/seed/buck002/600/400',
    ],
  };
}

enum AnimalReproductiveRole { doe, buck, unknown }

class AnimalPerformanceStats extends Equatable {
  const AnimalPerformanceStats({
    required this.role,
    required this.totalMatings,
    required this.successfulMatings,
    required this.littersCount,
    required this.successRate,
    required this.averageKitsBornAlive,
    required this.averageKitsWeaned,
    required this.totalKitsWeaned,
  });

  final AnimalReproductiveRole role;
  final int totalMatings;
  final int successfulMatings;
  final int littersCount;
  final double? successRate;
  final double? averageKitsBornAlive;
  final double? averageKitsWeaned;
  final int totalKitsWeaned;

  @override
  List<Object?> get props => <Object?>[
        role,
        totalMatings,
        successfulMatings,
        littersCount,
        successRate,
        averageKitsBornAlive,
        averageKitsWeaned,
        totalKitsWeaned,
      ];
}

enum AnimalTimelineCategory { birth, breeding, health, housing, weight, general }

class AnimalTimelineEntry extends Equatable {
  const AnimalTimelineEntry({
    required this.date,
    required this.title,
    required this.category,
    this.description,
  });

  final DateTime date;
  final String title;
  final String? description;
  final AnimalTimelineCategory category;

  @override
  List<Object?> get props => <Object?>[date, title, description, category];
}
