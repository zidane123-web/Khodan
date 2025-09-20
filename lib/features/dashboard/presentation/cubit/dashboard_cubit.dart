import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../domain/models/breeding_performance_stats.dart';

enum DashboardStatus { initial, loading, success, failure }

enum DashboardModuleType {
  kpis,
  alerts,
  calendar,
  tasksToday,
  tasksUpcoming,
  performance,
  weightTracking,
  healthAlerts,
  feedInventory,
}

class DashboardKpiFilter extends Equatable {
  const DashboardKpiFilter({
    required this.label,
    this.sex,
    this.statusQuery,
    this.includeIds,
  });

  final String label;
  final String? sex;
  final String? statusQuery;
  final Set<String>? includeIds;

  @override
  List<Object?> get props => <Object?>[label, sex, statusQuery, includeIds];
}

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalAnimals = 0,
    this.activeAnimals = 0,
    this.doesInGestation = 0,
    this.plannedBreedings = 0,
    this.activeLitters = 0,
    this.breedingSuccessRate,
    this.breedingEvaluatedCount = 0,
    this.todayTasks = const <DashboardTask>[],
    this.upcomingTasks = const <DashboardTask>[],
    this.alerts = const <DashboardAlert>[],
    this.calendarEvents = const <DashboardCalendarEvent>[],
    this.kpiOrder = const <DashboardKpiType>[
      DashboardKpiType.totalAnimals,
      DashboardKpiType.gestatingDoes,
      DashboardKpiType.plannedBreedings,
      DashboardKpiType.breedingSuccessRate,
    ],
    this.moduleOrder = const <DashboardModuleType>[
      DashboardModuleType.kpis,
      DashboardModuleType.alerts,
      DashboardModuleType.calendar,
      DashboardModuleType.tasksToday,
      DashboardModuleType.tasksUpcoming,
      DashboardModuleType.performance,
    ],
    this.hiddenModules = const <DashboardModuleType>{
      DashboardModuleType.weightTracking,
      DashboardModuleType.healthAlerts,
      DashboardModuleType.feedInventory,
    },
    this.kpiFilters = const <DashboardKpiType, DashboardKpiFilter>{},
    this.performance = const BreedingPerformanceStats(),
    this.errorMessage,
  });

  final DashboardStatus status;
  final int totalAnimals;
  final int activeAnimals;
  final int doesInGestation;
  final int plannedBreedings;
  final int activeLitters;
  final double? breedingSuccessRate;
  final int breedingEvaluatedCount;
  final List<DashboardTask> todayTasks;
  final List<DashboardTask> upcomingTasks;
  final List<DashboardAlert> alerts;
  final List<DashboardCalendarEvent> calendarEvents;
  final List<DashboardKpiType> kpiOrder;
  final List<DashboardModuleType> moduleOrder;
  final Set<DashboardModuleType> hiddenModules;
  final Map<DashboardKpiType, DashboardKpiFilter> kpiFilters;
  final BreedingPerformanceStats performance;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    int? totalAnimals,
    int? activeAnimals,
    int? doesInGestation,
    int? plannedBreedings,
    int? activeLitters,
    double? breedingSuccessRate,
    bool clearBreedingSuccessRate = false,
    int? breedingEvaluatedCount,
    List<DashboardTask>? todayTasks,
    List<DashboardTask>? upcomingTasks,
    List<DashboardAlert>? alerts,
    List<DashboardCalendarEvent>? calendarEvents,
    List<DashboardKpiType>? kpiOrder,
    List<DashboardModuleType>? moduleOrder,
    Set<DashboardModuleType>? hiddenModules,
    Map<DashboardKpiType, DashboardKpiFilter>? kpiFilters,
    BreedingPerformanceStats? performance,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalAnimals: totalAnimals ?? this.totalAnimals,
      activeAnimals: activeAnimals ?? this.activeAnimals,
      doesInGestation: doesInGestation ?? this.doesInGestation,
      plannedBreedings: plannedBreedings ?? this.plannedBreedings,
      activeLitters: activeLitters ?? this.activeLitters,
      breedingSuccessRate: clearBreedingSuccessRate
          ? null
          : (breedingSuccessRate ?? this.breedingSuccessRate),
      breedingEvaluatedCount:
          breedingEvaluatedCount ?? this.breedingEvaluatedCount,
      todayTasks: todayTasks ?? this.todayTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      alerts: alerts ?? this.alerts,
      calendarEvents: calendarEvents ?? this.calendarEvents,
      kpiOrder: kpiOrder ?? this.kpiOrder,
      moduleOrder: moduleOrder ?? this.moduleOrder,
      hiddenModules: hiddenModules ?? this.hiddenModules,
      kpiFilters: kpiFilters ?? this.kpiFilters,
      performance: performance ?? this.performance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        totalAnimals,
        activeAnimals,
        doesInGestation,
        plannedBreedings,
        activeLitters,
        breedingSuccessRate,
        breedingEvaluatedCount,
        todayTasks,
        upcomingTasks,
        alerts,
        calendarEvents,
        kpiOrder,
        moduleOrder,
        hiddenModules,
        kpiFilters,
        performance,
        errorMessage,
      ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._animalRepository,
    this._breedingRepository,
    this._eventRepository,
  ) : super(const DashboardState());

  final AnimalRepository _animalRepository;
  final BreedingRepository _breedingRepository;
  final EventRepository _eventRepository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final List<Animal> animals = await _animalRepository.fetchAnimals();
      final List<BreedingRecord> records =
          await _breedingRepository.fetchBreedingRecords();
      final DateTime now = DateTime.now();
      final DateTime startOfToday =
          DateTime(now.year, now.month, now.day);

      final List<LivestockEvent> events = await _eventRepository.fetchEvents(
        start: startOfToday.subtract(const Duration(days: 60)),
        end: startOfToday.add(const Duration(days: 60)),
      );
      final List<AnimalEventLink> links =
          await _eventRepository.fetchEventLinks();

      final Map<String, Animal> animalsById = <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };

      final Set<String> allAnimalIds = animalsById.keys.toSet();
      final Set<String> activeAnimalIds = <String>{};
      for (final Animal animal in animals) {
        if (animal.status.toLowerCase().contains('viv')) {
          activeAnimalIds.add(animal.id);
        }
      }

      final Set<String> plannedBreedingAnimalIds = <String>{};
      final Set<String> activeLitterDoeIds = <String>{};
      final Set<String> evaluatedAnimalIds = <String>{};
      final Set<String> litterParticipantIds = <String>{};

      final Map<String, List<String>> eventAnimalMap =
          <String, List<String>>{};
      for (final AnimalEventLink link in links) {
        eventAnimalMap.update(
          link.eventId,
          (List<String> value) => <String>[...value, link.animalId],
          ifAbsent: () => <String>[link.animalId],
        );
      }

      final int activeAnimals = activeAnimalIds.length;

      final Set<String> gestatingDoeIds = <String>{};
      int plannedBreedings = 0;
      int activeLitters = 0;
      for (final BreedingRecord record in records) {
        final bool hasMatingOccurred = record.matingDate.isBefore(now);
        final bool alreadyKindled = record.kindlingDate != null;
        final bool confirmedNegative = record.palpationPositive == false;
        if (hasMatingOccurred && !alreadyKindled && !confirmedNegative) {
          gestatingDoeIds.add(record.doeId);
        }
        if (record.matingDate.isAfter(now)) {
          plannedBreedings += 1;
          plannedBreedingAnimalIds
            ..add(record.doeId)
            ..add(record.buckId);
        }
        final bool hasActiveLitter = record.kindlingDate != null &&
            (record.weaningDate == null || record.weaningDate!.isAfter(now));
        if (hasActiveLitter) {
          activeLitters += 1;
          activeLitterDoeIds.add(record.doeId);
        }
        if (record.kindlingDate != null) {
          litterParticipantIds
            ..add(record.doeId)
            ..add(record.buckId);
        }
        if (record.palpationPositive != null) {
          evaluatedAnimalIds
            ..add(record.doeId)
            ..add(record.buckId);
        }
      }

      final Iterable<BreedingRecord> evaluatedRecords = records.where(
        (BreedingRecord record) => record.palpationPositive != null,
      );
      final int evaluatedCount = evaluatedRecords.length;
      final double? breedingSuccessRate = evaluatedCount == 0
          ? null
          : evaluatedRecords
                  .where(
                    (BreedingRecord record) =>
                        record.palpationPositive == true,
                  )
                  .length /
              evaluatedCount;

      final List<BreedingReminder> reminders =
          BreedingReminder.build(records);
      final _TasksBreakdown breakdown = _buildTasks(
        reminders,
        records,
        animalsById,
        startOfToday,
      );

      final BreedingPerformanceStats performance =
          _buildPerformanceStats(records, animalsById);

      final List<DashboardAlert> alerts =
          _buildAlerts(records, animalsById);

      final List<DashboardCalendarEvent> calendarEvents =
          _buildCalendarEvents(
        breakdown.calendarEvents,
        events,
        eventAnimalMap,
        animalsById,
        startOfToday,
      );

      final Map<DashboardKpiType, DashboardKpiFilter> kpiFilters =
          <DashboardKpiType, DashboardKpiFilter>{
        DashboardKpiType.totalAnimals: DashboardKpiFilter(
          label: 'Tous les animaux',
          includeIds: allAnimalIds,
        ),
        DashboardKpiType.activeAnimals: DashboardKpiFilter(
          label: 'Animaux actifs',
          statusQuery: 'viv',
          includeIds: activeAnimalIds,
        ),
        DashboardKpiType.gestatingDoes: DashboardKpiFilter(
          label: 'Femelles en gestation',
          sex: 'Femelle',
          statusQuery: 'gest',
          includeIds: gestatingDoeIds,
        ),
        DashboardKpiType.plannedBreedings: DashboardKpiFilter(
          label: 'Paires programmées',
          includeIds: plannedBreedingAnimalIds,
        ),
        DashboardKpiType.activeLitters: DashboardKpiFilter(
          label: 'Portées en cours',
          includeIds: activeLitterDoeIds,
        ),
        DashboardKpiType.breedingSuccessRate: DashboardKpiFilter(
          label: 'Saillies évaluées',
          includeIds: evaluatedAnimalIds,
        ),
        DashboardKpiType.averageKitsBornAlive: DashboardKpiFilter(
          label: 'Historiques de portées',
          includeIds: litterParticipantIds,
        ),
        DashboardKpiType.averageKitsWeaned: DashboardKpiFilter(
          label: 'Sevrages réalisés',
          includeIds: litterParticipantIds,
        ),
        DashboardKpiType.totalKitsWeaned: DashboardKpiFilter(
          label: 'Total sevrés',
          includeIds: litterParticipantIds,
        ),
      };

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalAnimals: animals.length,
          activeAnimals: activeAnimals,
          doesInGestation: gestatingDoeIds.length,
          plannedBreedings: plannedBreedings,
          activeLitters: activeLitters,
          breedingSuccessRate: breedingSuccessRate,
          breedingEvaluatedCount: evaluatedCount,
          todayTasks: breakdown.today,
          upcomingTasks: breakdown.upcoming,
          alerts: alerts,
          calendarEvents: calendarEvents,
          kpiFilters: kpiFilters,
          performance: performance,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
          clearBreedingSuccessRate: true,
        ),
      );
    }
  }

  void updateKpiOrder(List<DashboardKpiType> order) {
    if (order.isEmpty) {
      return;
    }
    final List<DashboardKpiType> sanitized = <DashboardKpiType>[];
    for (final DashboardKpiType type in order) {
      if (!sanitized.contains(type)) {
        sanitized.add(type);
      }
    }
    for (final DashboardKpiType type in state.kpiOrder) {
      if (!sanitized.contains(type)) {
        sanitized.add(type);
      }
    }
    emit(state.copyWith(kpiOrder: sanitized));
  }

  void updateModulePreferences({
    required List<DashboardModuleType> order,
    required Set<DashboardModuleType> hidden,
  }) {
    final List<DashboardModuleType> sanitized = <DashboardModuleType>[];
    for (final DashboardModuleType type in order) {
      if (!sanitized.contains(type)) {
        sanitized.add(type);
      }
    }
    for (final DashboardModuleType type in DashboardModuleType.values) {
      if (!sanitized.contains(type)) {
        sanitized.add(type);
      }
    }
    final Set<DashboardModuleType> filteredHidden = hidden
        .where(DashboardModuleType.values.contains)
        .toSet();
    emit(
      state.copyWith(
        moduleOrder: sanitized,
        hiddenModules: filteredHidden,
      ),
    );
  }

  _TasksBreakdown _buildTasks(
    List<BreedingReminder> reminders,
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
    DateTime startOfToday,
  ) {
    final List<DashboardTask> todayTasks = <DashboardTask>[];
    final List<DashboardTask> upcomingTasks = <DashboardTask>[];
    final List<DashboardCalendarEvent> calendarEvents =
        <DashboardCalendarEvent>[];

    void addTask({
      required DateTime dueDate,
      required DashboardTaskKind kind,
      required String title,
      required String contextLabel,
    }) {
      final DateTime dateOnly =
          DateTime(dueDate.year, dueDate.month, dueDate.day);
      final int diffDays = dateOnly.difference(startOfToday).inDays;
      final bool isOverdue = diffDays < 0;

      final String relativeLabel;
      if (diffDays < 0) {
        final int overdueDays = -diffDays;
        relativeLabel = 'En retard depuis $overdueDays j';
      } else if (diffDays == 0) {
        relativeLabel = 'Aujourd’hui';
      } else if (diffDays == 1) {
        relativeLabel = 'Demain';
      } else {
        relativeLabel = 'Dans $diffDays jours';
      }

      final DashboardTask task = DashboardTask(
        title: title,
        contextLabel: contextLabel,
        dueDate: dateOnly,
        kind: kind,
        relativeLabel: relativeLabel,
        isOverdue: isOverdue,
      );

      if (diffDays <= 0) {
        todayTasks.add(task);
      } else if (diffDays <= 7) {
        upcomingTasks.add(task);
      }

      if (diffDays >= -3 && diffDays <= 30) {
        calendarEvents.add(
          DashboardCalendarEvent(
            date: dateOnly,
            title: '$title · $contextLabel',
            subtitle: relativeLabel,
            category: _mapTaskKindToCategory(kind),
          ),
        );
      }
    }

    for (final BreedingReminder reminder in reminders) {
      final String contextLabel =
          _animalLabel(animalsById[reminder.doeId], reminder.doeId);
      addTask(
        dueDate: reminder.dueDate,
        kind: _mapReminderType(reminder.type),
        title: _labelForTask(reminder.type),
        contextLabel: contextLabel,
      );
    }

    for (final BreedingRecord record in records) {
      if (!record.matingDate.isAfter(startOfToday)) {
        continue;
      }
      final Animal? doe = animalsById[record.doeId];
      final Animal? buck = animalsById[record.buckId];
      final String pairLabel =
          '${_animalLabel(doe, record.doeId)} × ${_animalLabel(buck, record.buckId)}';
      addTask(
        dueDate: record.matingDate,
        kind: DashboardTaskKind.mating,
        title: 'Saillie planifiée',
        contextLabel: pairLabel,
      );
    }

    todayTasks.sort(
      (DashboardTask a, DashboardTask b) => a.dueDate.compareTo(b.dueDate),
    );
    upcomingTasks.sort(
      (DashboardTask a, DashboardTask b) => a.dueDate.compareTo(b.dueDate),
    );

    return _TasksBreakdown(
      today: todayTasks,
      upcoming: upcomingTasks,
      calendarEvents: calendarEvents,
    );
  }

  List<DashboardAlert> _buildAlerts(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final DateTime now = DateTime.now();
    final List<DashboardAlert> alerts = <DashboardAlert>[];

    for (final BreedingRecord record in records) {
      if (record.kindlingDate != null) {
        final Duration diff = now.difference(record.kindlingDate!);
        if (diff.inDays <= 2) {
          final Animal? doe = animalsById[record.doeId];
          final String doeLabel = _animalLabel(doe, record.doeId);
          final String detail = record.kitsBornAlive != null
              ? '${record.kitsBornAlive} nés vivants.'
              : 'Surveillez la portée.';
          alerts.add(
            DashboardAlert(
              title: 'Mise-bas effectuée',
              message:
                  '$doeLabel a mis bas ${_formatRelativeTime(record.kindlingDate!)}.',
              detail: detail,
              timestamp: record.kindlingDate!,
              type: DashboardAlertType.success,
            ),
          );
        }
      }

      if (record.palpationPositive == false) {
        final Animal? doe = animalsById[record.doeId];
        final DateTime referenceDate =
            record.palpationDate ?? record.plannedPalpationDate;
        alerts.add(
          DashboardAlert(
            title: 'Palpation négative',
            message:
                '${_animalLabel(doe, record.doeId)} n’est pas gestante.',
            detail: 'Planifiez une nouvelle saillie.',
            timestamp: referenceDate,
            type: DashboardAlertType.warning,
          ),
        );
      }
    }

    alerts.sort(
      (DashboardAlert a, DashboardAlert b) =>
          b.timestamp.compareTo(a.timestamp),
    );
    return alerts;
  }

  List<DashboardCalendarEvent> _buildCalendarEvents(
    List<DashboardCalendarEvent> taskEvents,
    List<LivestockEvent> events,
    Map<String, List<String>> eventAnimalMap,
    Map<String, Animal> animalsById,
    DateTime startOfToday,
  ) {
    final List<DashboardCalendarEvent> calendar =
        List<DashboardCalendarEvent>.from(taskEvents);

    for (final LivestockEvent event in events) {
      final DateTime dateOnly = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      );
      final int diffDays = dateOnly.difference(startOfToday).inDays;
      if (diffDays < -7 || diffDays > 60) {
        continue;
      }

      final DashboardCalendarCategory category =
          _mapEventTypeToCategory(event.eventType);

      final List<String> linkedAnimalIds = eventAnimalMap[event.id] ??
          _animalIdsFromEvent(event);
      final String? animalsLabel = linkedAnimalIds.isEmpty
          ? null
          : linkedAnimalIds
              .map((String id) => _animalLabel(animalsById[id], id))
              .join(', ');

      final String? description = event.details['description'] as String?;
      final String? subtitle;
      if (animalsLabel != null && animalsLabel.isNotEmpty) {
        subtitle = animalsLabel;
      } else if (description != null && description.isNotEmpty) {
        subtitle = description;
      } else {
        subtitle = event.notes;
      }

      calendar.add(
        DashboardCalendarEvent(
          date: dateOnly,
          title: _labelForEvent(event.eventType),
          subtitle: subtitle,
          category: category,
        ),
      );
    }

    calendar.sort(
      (DashboardCalendarEvent a, DashboardCalendarEvent b) =>
          a.date.compareTo(b.date),
    );
    return calendar;
  }

  BreedingPerformanceStats _buildPerformanceStats(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final Iterable<BreedingRecord> litters = records.where(
      (BreedingRecord record) => record.kindlingDate != null,
    );

    int totalKitsBornAlive = 0;
    int totalKitsWeaned = 0;
    final Map<String, int> weanedByDoe = <String, int>{};
    final Map<String, int> weanedByBuck = <String, int>{};

    for (final BreedingRecord record in litters) {
      totalKitsBornAlive += record.kitsBornAlive ?? 0;
      totalKitsWeaned += record.kitsWeaned ?? 0;

      if (record.kitsWeaned != null) {
        weanedByDoe.update(
          record.doeId,
          (int value) => value + record.kitsWeaned!,
          ifAbsent: () => record.kitsWeaned!,
        );
        weanedByBuck.update(
          record.buckId,
          (int value) => value + record.kitsWeaned!,
          ifAbsent: () => record.kitsWeaned!,
        );
      }
    }

    final int littersCount = litters.length;
    final double? avgBornAlive = littersCount == 0
        ? null
        : totalKitsBornAlive / littersCount;
    final double? avgWeaned = littersCount == 0
        ? null
        : totalKitsWeaned / littersCount;

    String? topDoeLabel;
    if (weanedByDoe.isNotEmpty) {
      final MapEntry<String, int> topDoe = weanedByDoe.entries.reduce(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.value >= b.value ? a : b,
      );
      final Animal? doe = animalsById[topDoe.key];
      topDoeLabel =
          '${_animalLabel(doe, topDoe.key)} (${topDoe.value} sevrés)';
    }

    String? topBuckLabel;
    if (weanedByBuck.isNotEmpty) {
      final MapEntry<String, int> topBuck = weanedByBuck.entries.reduce(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.value >= b.value ? a : b,
      );
      final Animal? buck = animalsById[topBuck.key];
      topBuckLabel =
          '${_animalLabel(buck, topBuck.key)} (${topBuck.value} sevrés)';
    }

    return BreedingPerformanceStats(
      totalLitters: littersCount,
      averageKitsBornAlive: avgBornAlive,
      averageKitsWeaned: avgWeaned,
      totalKitsWeaned: totalKitsWeaned,
      topDoeLabel: topDoeLabel,
      topBuckLabel: topBuckLabel,
    );
  }

  String _labelForTask(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return 'Palpation';
      case BreedingTaskType.kindling:
        return 'Mise-bas';
      case BreedingTaskType.weaning:
        return 'Sevrage';
    }
  }

  DashboardTaskKind _mapReminderType(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return DashboardTaskKind.palpation;
      case BreedingTaskType.kindling:
        return DashboardTaskKind.kindling;
      case BreedingTaskType.weaning:
        return DashboardTaskKind.weaning;
    }
  }

  DashboardCalendarCategory _mapTaskKindToCategory(
    DashboardTaskKind kind,
  ) {
    switch (kind) {
      case DashboardTaskKind.palpation:
        return DashboardCalendarCategory.taskPalpation;
      case DashboardTaskKind.kindling:
        return DashboardCalendarCategory.taskKindling;
      case DashboardTaskKind.weaning:
        return DashboardCalendarCategory.taskWeaning;
      case DashboardTaskKind.mating:
        return DashboardCalendarCategory.scheduledMating;
    }
  }

  DashboardCalendarCategory _mapEventTypeToCategory(String eventType) {
    switch (eventType) {
      case 'health_check':
        return DashboardCalendarCategory.health;
      case 'treatment':
        return DashboardCalendarCategory.treatment;
      case 'weight':
        return DashboardCalendarCategory.weight;
      case 'cage_change':
        return DashboardCalendarCategory.housing;
      default:
        return DashboardCalendarCategory.general;
    }
  }

  String _labelForEvent(String eventType) {
    switch (eventType) {
      case 'health_check':
        return 'Visite vétérinaire';
      case 'treatment':
        return 'Traitement';
      case 'weight':
        return 'Pesée';
      case 'cage_change':
        return 'Changement de cage';
      case 'inventory':
        return 'Inventaire';
      default:
        if (eventType.isEmpty) {
          return 'Événement';
        }
        final String normalized = eventType.replaceAll('_', ' ');
        return normalized[0].toUpperCase() + normalized.substring(1);
    }
  }

  List<String> _animalIdsFromEvent(LivestockEvent event) {
    final dynamic ids = event.details['animalIds'];
    if (ids is List) {
      return ids.whereType<String>().toList();
    }
    return <String>[];
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

  String _formatRelativeTime(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays.abs() >= 1) {
      final int days = diff.inDays.abs();
      if (diff.isNegative) {
        return 'dans $days j';
      }
      return 'il y a $days j';
    }
    final int hours = diff.inHours.abs().clamp(1, 23);
    if (diff.isNegative) {
      return 'dans $hours h';
    }
    return 'il y a $hours h';
  }
}

class _TasksBreakdown {
  const _TasksBreakdown({
    required this.today,
    required this.upcoming,
    required this.calendarEvents,
  });

  final List<DashboardTask> today;
  final List<DashboardTask> upcoming;
  final List<DashboardCalendarEvent> calendarEvents;
}

enum DashboardTaskKind { palpation, kindling, weaning, mating }

class DashboardTask extends Equatable {
  const DashboardTask({
    required this.title,
    required this.contextLabel,
    required this.dueDate,
    required this.kind,
    required this.relativeLabel,
    this.isOverdue = false,
  });

  final String title;
  final String contextLabel;
  final DateTime dueDate;
  final DashboardTaskKind kind;
  final String relativeLabel;
  final bool isOverdue;

  @override
  List<Object?> get props => <Object?>[
        title,
        contextLabel,
        dueDate,
        kind,
        relativeLabel,
        isOverdue,
      ];
}

enum DashboardAlertType { info, warning, success }

class DashboardAlert extends Equatable {
  const DashboardAlert({
    required this.title,
    required this.message,
    required this.timestamp,
    this.detail,
    this.type = DashboardAlertType.info,
  });

  final String title;
  final String message;
  final DateTime timestamp;
  final String? detail;
  final DashboardAlertType type;

  @override
  List<Object?> get props => <Object?>[title, message, timestamp, detail, type];
}

enum DashboardCalendarCategory {
  taskPalpation,
  taskKindling,
  taskWeaning,
  scheduledMating,
  health,
  treatment,
  weight,
  housing,
  general,
}

class DashboardCalendarEvent extends Equatable {
  const DashboardCalendarEvent({
    required this.date,
    required this.title,
    required this.category,
    this.subtitle,
  });

  final DateTime date;
  final String title;
  final String? subtitle;
  final DashboardCalendarCategory category;

  @override
  List<Object?> get props => <Object?>[date, title, subtitle, category];
}

enum DashboardKpiType {
  totalAnimals,
  activeAnimals,
  gestatingDoes,
  plannedBreedings,
  activeLitters,
  breedingSuccessRate,
  averageKitsBornAlive,
  averageKitsWeaned,
  totalKitsWeaned,
}