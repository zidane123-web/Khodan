import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/models/dashboard_kpi_row.dart';
import '../../../../data/models/dashboard_preferences.dart';
import '../../../../data/models/dashboard_snapshot.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../data/repositories/food_inventory_repository.dart';
import '../../../../data/services/api_client.dart';
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
    this.healthAlerts = const <DashboardAlert>[],
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
      DashboardModuleType.healthAlerts,
      DashboardModuleType.calendar,
      DashboardModuleType.tasksToday,
      DashboardModuleType.tasksUpcoming,
      DashboardModuleType.performance,
      DashboardModuleType.feedInventory,
    ],
    this.hiddenModules = const <DashboardModuleType>{
      DashboardModuleType.weightTracking,
    },
    this.kpiFilters = const <DashboardKpiType, DashboardKpiFilter>{},
    this.performance = const BreedingPerformanceStats(),
    this.inventorySummary,
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
  final List<DashboardAlert> healthAlerts;
  final List<DashboardCalendarEvent> calendarEvents;
  final List<DashboardKpiType> kpiOrder;
  final List<DashboardModuleType> moduleOrder;
  final Set<DashboardModuleType> hiddenModules;
  final Map<DashboardKpiType, DashboardKpiFilter> kpiFilters;
  final BreedingPerformanceStats performance;
  final InventorySummary? inventorySummary;
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
    List<DashboardAlert>? healthAlerts,
    List<DashboardCalendarEvent>? calendarEvents,
    List<DashboardKpiType>? kpiOrder,
    List<DashboardModuleType>? moduleOrder,
    Set<DashboardModuleType>? hiddenModules,
    Map<DashboardKpiType, DashboardKpiFilter>? kpiFilters,
    BreedingPerformanceStats? performance,
    InventorySummary? inventorySummary,
    bool clearInventorySummary = false,
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
      healthAlerts: healthAlerts ?? this.healthAlerts,
      calendarEvents: calendarEvents ?? this.calendarEvents,
      kpiOrder: kpiOrder ?? this.kpiOrder,
      moduleOrder: moduleOrder ?? this.moduleOrder,
      hiddenModules: hiddenModules ?? this.hiddenModules,
      kpiFilters: kpiFilters ?? this.kpiFilters,
      performance: performance ?? this.performance,
      inventorySummary: clearInventorySummary
          ? null
          : (inventorySummary ?? this.inventorySummary),
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
        healthAlerts,
        calendarEvents,
        kpiOrder,
        moduleOrder,
        hiddenModules,
        kpiFilters,
        performance,
        inventorySummary,
        errorMessage,
      ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._animalRepository,
    this._breedingRepository,
    this._eventRepository,
    this._dashboardRepository,
    this._foodInventoryRepository, {
    String? profileId,
  })  : _profileId = profileId,
        super(const DashboardState());

  final AnimalRepository _animalRepository;
  final BreedingRepository _breedingRepository;
  final EventRepository _eventRepository;
  final DashboardRepository _dashboardRepository;
  final FoodInventoryRepository _foodInventoryRepository;
  final String? _profileId;
  bool _preferencesLoaded = false;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _restorePreferences();

    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime windowStart =
        startOfToday.subtract(const Duration(days: 60));
    final DateTime windowEnd = startOfToday.add(const Duration(days: 60));

    DashboardSnapshot? snapshot;
    try {
      snapshot = await _dashboardRepository.fetchSnapshot(
        periodStart: windowStart,
        periodEnd: windowEnd,
      );
    } catch (_) {
      snapshot = null;
    }

    List<DashboardKpiRow> aggregates = snapshot?.kpiRows ?? <DashboardKpiRow>[];
    try {
      if (aggregates.isEmpty) {
        aggregates = await _dashboardRepository.fetchKpis(limit: 12);
      }
    } on DataLayerException {
      aggregates = <DashboardKpiRow>[];
    } catch (_) {
      aggregates = <DashboardKpiRow>[];
    }

    if (snapshot != null) {
      final DashboardState successState = _buildStateFromSnapshot(
        snapshot,
        aggregates,
        now,
      );
      emit(successState);
      return;
    }

    try {
      final DashboardState fallbackState = await _computeDashboardLocally(
        aggregates: aggregates,
        now: now,
        startOfToday: startOfToday,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );
      emit(fallbackState);
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
          clearBreedingSuccessRate: true,
          clearInventorySummary: true,
        ),
      );
    }
  }

  DashboardState _buildStateFromSnapshot(
    DashboardSnapshot snapshot,
    List<DashboardKpiRow> aggregates,
    DateTime now,
  ) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<DashboardTask> todayTasks =
        _mapSnapshotTasks(snapshot.todayTasks, today);
    final List<DashboardTask> upcomingTasks =
        _mapSnapshotTasks(snapshot.upcomingTasks, today);
    final List<DashboardAlert> alerts = _mapSnapshotAlerts(snapshot.alerts);
    final List<DashboardAlert> healthAlerts =
        _mapSnapshotAlerts(snapshot.healthAlerts);
    final List<DashboardCalendarEvent> calendarEvents =
        _mapSnapshotCalendarEvents(snapshot.calendarEvents);
    final Map<DashboardKpiType, DashboardKpiFilter> kpiFilters =
        _mapSnapshotFilters(snapshot.kpiFilters);
    final BreedingPerformanceStats performance =
        snapshot.performance ??
            (aggregates.isNotEmpty
                ? _performanceFromAggregates(aggregates)
                : const BreedingPerformanceStats());

    return state.copyWith(
      status: DashboardStatus.success,
      totalAnimals: snapshot.totalAnimals,
      activeAnimals: snapshot.activeAnimals,
      doesInGestation: snapshot.doesInGestation,
      plannedBreedings: snapshot.plannedBreedings,
      activeLitters: snapshot.activeLitters,
      breedingSuccessRate: snapshot.breedingSuccessRate,
      breedingEvaluatedCount: snapshot.breedingEvaluatedCount,
      todayTasks: todayTasks,
      upcomingTasks: upcomingTasks,
      alerts: alerts,
      healthAlerts: healthAlerts,
      calendarEvents: calendarEvents,
      kpiFilters: kpiFilters,
      performance: performance,
      inventorySummary: snapshot.inventorySummary,
      errorMessage: null,
    );
  }

  List<DashboardTask> _mapSnapshotTasks(
    List<DashboardSnapshotTask> snapshotTasks,
    DateTime today,
  ) {
    final List<DashboardTask> tasks = snapshotTasks
        .map((DashboardSnapshotTask task) {
          final DateTime dateOnly = DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
          );
          final DashboardTaskKind kind = _taskKindFromString(task.kind);
          final String relativeLabel =
              task.relativeLabel ?? _relativeLabelFor(dateOnly, today);
          return DashboardTask(
            title: task.title,
            contextLabel: task.contextLabel,
            dueDate: dateOnly,
            kind: kind,
            relativeLabel: relativeLabel,
            isOverdue: task.isOverdue,
          );
        })
        .toList()
      ..sort(
        (DashboardTask a, DashboardTask b) => a.dueDate.compareTo(b.dueDate),
      );
    return tasks;
  }

  List<DashboardAlert> _mapSnapshotAlerts(
    List<DashboardSnapshotAlert> snapshotAlerts,
  ) {
    final List<DashboardAlert> alerts = snapshotAlerts
        .map(
          (DashboardSnapshotAlert alert) => DashboardAlert(
            title: alert.title,
            message: alert.message,
            timestamp: alert.timestamp,
            detail: alert.detail,
            type: _alertTypeFromString(alert.type),
          ),
        )
        .toList()
      ..sort(
        (DashboardAlert a, DashboardAlert b) =>
            b.timestamp.compareTo(a.timestamp),
      );
    return alerts;
  }

  List<DashboardCalendarEvent> _mapSnapshotCalendarEvents(
    List<DashboardSnapshotCalendarEvent> snapshotEvents,
  ) {
    final List<DashboardCalendarEvent> events = snapshotEvents
        .map(
          (DashboardSnapshotCalendarEvent event) => DashboardCalendarEvent(
            date: event.date,
            title: event.title,
            subtitle: event.subtitle,
            category: _calendarCategoryFromString(event.category),
          ),
        )
        .toList()
      ..sort(
        (DashboardCalendarEvent a, DashboardCalendarEvent b) =>
            a.date.compareTo(b.date),
      );
    return events;
  }

  Map<DashboardKpiType, DashboardKpiFilter> _mapSnapshotFilters(
    Map<String, DashboardSnapshotFilter> raw,
  ) {
    final Map<DashboardKpiType, DashboardKpiFilter> filters =
        Map<DashboardKpiType, DashboardKpiFilter>.from(state.kpiFilters);
    for (final MapEntry<String, DashboardSnapshotFilter> entry in raw.entries) {
      try {
        final DashboardKpiType type =
            DashboardKpiType.values.byName(entry.key);
        final DashboardSnapshotFilter filter = entry.value;
        filters[type] = DashboardKpiFilter(
          label: filter.label,
          sex: filter.sex,
          statusQuery: filter.statusQuery,
          includeIds: filter.includeIds == null
              ? null
              : Set<String>.from(filter.includeIds!),
        );
      } catch (_) {
        // ignore unknown KPI keys
      }
    }
    return filters;
  }

  DashboardTaskKind _taskKindFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'palpation':
        return DashboardTaskKind.palpation;
      case 'kindling':
        return DashboardTaskKind.kindling;
      case 'weaning':
        return DashboardTaskKind.weaning;
      case 'mating':
      case 'breeding':
        return DashboardTaskKind.mating;
      case 'inventory_check':
      case 'inventory':
        return DashboardTaskKind.inventoryCheck;
      case 'health':
      case 'health_follow_up':
      case 'healthfollowup':
        return DashboardTaskKind.healthFollowUp;
      default:
        return DashboardTaskKind.healthFollowUp;
    }
  }

  DashboardAlertType _alertTypeFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'warning':
      case 'danger':
        return DashboardAlertType.warning;
      case 'success':
      case 'positive':
        return DashboardAlertType.success;
      default:
        return DashboardAlertType.info;
    }
  }

  DashboardCalendarCategory _calendarCategoryFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'task_palpation':
      case 'palpation':
        return DashboardCalendarCategory.taskPalpation;
      case 'task_kindling':
      case 'kindling':
        return DashboardCalendarCategory.taskKindling;
      case 'task_weaning':
      case 'weaning':
        return DashboardCalendarCategory.taskWeaning;
      case 'scheduled_mating':
      case 'mating':
        return DashboardCalendarCategory.scheduledMating;
      case 'health':
        return DashboardCalendarCategory.health;
      case 'treatment':
        return DashboardCalendarCategory.treatment;
      case 'weight':
        return DashboardCalendarCategory.weight;
      case 'housing':
        return DashboardCalendarCategory.housing;
      default:
        return DashboardCalendarCategory.general;
    }
  }

  String _relativeLabelFor(DateTime dueDate, DateTime today) {
    final int diffDays = dueDate.difference(today).inDays;
    if (diffDays < 0) {
      return 'En retard depuis ${-diffDays} j';
    }
    if (diffDays == 0) {
      return 'Aujourd\'hui';
    }
    if (diffDays == 1) {
      return 'Demain';
    }
    return 'Dans $diffDays jours';
  }

  Future<DashboardState> _computeDashboardLocally({
    required List<DashboardKpiRow> aggregates,
    required DateTime now,
    required DateTime startOfToday,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    final List<Animal> animals = await _animalRepository.fetchAnimals();
    final List<BreedingRecord> records =
        await _breedingRepository.fetchBreedingRecords();
    final List<LivestockEvent> events = await _eventRepository.fetchEvents(
      start: windowStart,
      end: windowEnd,
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
                  (BreedingRecord record) => record.palpationPositive == true,
                )
                .length /
            evaluatedCount;

    final List<BreedingReminder> reminders =
        BreedingReminder.build(records);
    final _TasksBreakdown breedingTasks = _buildBreedingTasks(
      reminders,
      records,
      animalsById,
      startOfToday,
    );

    final BreedingPerformanceStats performance = aggregates.isNotEmpty
        ? _performanceFromAggregates(aggregates)
        : _buildPerformanceStats(records, animalsById);

    final String? effectiveProfileId = _profileId ??
        (aggregates.isNotEmpty
            ? aggregates.first.profileId
            : (animals.isNotEmpty ? animals.first.profileId : null));
    InventorySummary? inventorySummary;
    if (effectiveProfileId != null) {
      try {
        inventorySummary =
            await _foodInventoryRepository.computeSummary(effectiveProfileId);
      } catch (_) {
        inventorySummary = null;
      }
    }

    final List<DashboardTask> healthTasks = _buildHealthTasks(
      events,
      eventAnimalMap,
      animalsById,
      startOfToday,
    );
    final List<DashboardTask> inventoryTasks = inventorySummary == null
        ? <DashboardTask>[]
        : _buildInventoryTasks(inventorySummary, now);

    final List<DashboardTask> combinedTasks = <DashboardTask>[
      ...breedingTasks.today,
      ...breedingTasks.upcoming,
      ...healthTasks,
      ...inventoryTasks,
    ]
      ..sort(
        (DashboardTask a, DashboardTask b) =>
            a.dueDate.compareTo(b.dueDate),
      );

    final DateTime endOfToday = startOfToday.add(const Duration(days: 1));
    final List<DashboardTask> todayTasks = combinedTasks
        .where((DashboardTask task) => !task.dueDate.isAfter(endOfToday))
        .toList();
    final List<DashboardTask> upcomingTasks = combinedTasks
        .where((DashboardTask task) => task.dueDate.isAfter(endOfToday))
        .toList();

    final List<DashboardAlert> breedingAlerts =
        _buildBreedingAlerts(records, animalsById);
    final List<DashboardAlert> healthAlerts =
        _buildHealthAlerts(healthTasks);
    final List<DashboardAlert> inventoryAlerts = inventorySummary == null
        ? <DashboardAlert>[]
        : _buildInventoryAlerts(inventorySummary);

    final List<DashboardAlert> alerts = <DashboardAlert>[
      ...inventoryAlerts,
      ...breedingAlerts,
    ]
      ..sort(
        (DashboardAlert a, DashboardAlert b) =>
            b.timestamp.compareTo(a.timestamp),
      );

    final List<DashboardCalendarEvent> calendarEvents =
        _buildCalendarEvents(
      <DashboardCalendarEvent>[
        ...breedingTasks.calendarEvents,
        ..._calendarEventsFromTasks(healthTasks),
        ..._calendarEventsFromTasks(inventoryTasks),
      ],
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
        label: 'Paires programmees',
        includeIds: plannedBreedingAnimalIds,
      ),
      DashboardKpiType.activeLitters: DashboardKpiFilter(
        label: 'Portees en cours',
        includeIds: activeLitterDoeIds,
      ),
      DashboardKpiType.breedingSuccessRate: DashboardKpiFilter(
        label: 'Saillies evaluees',
        includeIds: evaluatedAnimalIds,
      ),
      DashboardKpiType.averageKitsBornAlive: DashboardKpiFilter(
        label: 'Historiques de portees',
        includeIds: litterParticipantIds,
      ),
      DashboardKpiType.averageKitsWeaned: DashboardKpiFilter(
        label: 'Sevrages realises',
        includeIds: litterParticipantIds,
      ),
      DashboardKpiType.totalKitsWeaned: DashboardKpiFilter(
        label: 'Total sevres',
        includeIds: litterParticipantIds,
      ),
    };

    return state.copyWith(
      status: DashboardStatus.success,
      totalAnimals: animals.length,
      activeAnimals: activeAnimals,
      doesInGestation: gestatingDoeIds.length,
      plannedBreedings: plannedBreedings,
      activeLitters: activeLitters,
      breedingSuccessRate: breedingSuccessRate,
      breedingEvaluatedCount: evaluatedCount,
      todayTasks: todayTasks,
      upcomingTasks: upcomingTasks,
      alerts: alerts,
      healthAlerts: healthAlerts,
      calendarEvents: calendarEvents,
      kpiFilters: kpiFilters,
      performance: performance,
      inventorySummary: inventorySummary,
      errorMessage: null,
    );
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
    final DashboardState updated = state.copyWith(kpiOrder: sanitized);
    emit(updated);
    unawaited(_persistPreferences(updated));
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
    final DashboardState updated = state.copyWith(
      moduleOrder: sanitized,
      hiddenModules: filteredHidden,
    );
    emit(updated);
    unawaited(_persistPreferences(updated));
  }

  _TasksBreakdown _buildBreedingTasks(
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

      final String relativeLabel =
          _relativeLabelFor(dateOnly, startOfToday);

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
            title: '$title - $contextLabel',
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
          '${_animalLabel(doe, record.doeId)} x ${_animalLabel(buck, record.buckId)}';
      addTask(
        dueDate: record.matingDate,
        kind: DashboardTaskKind.mating,
        title: 'Saillie planifiee',
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

  List<DashboardAlert> _buildBreedingAlerts(
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
              ? '${record.kitsBornAlive} nes vivants.'
              : 'Surveillez la portee.';
          alerts.add(
            DashboardAlert(
              title: 'Mise-bas effectuee',
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
            title: 'Palpation negative',
            message:
                '${_animalLabel(doe, record.doeId)} n''est pas gestante.',
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
          '${_animalLabel(doe, topDoe.key)} (${topDoe.value} sevr├®s)';
    }

    String? topBuckLabel;
    if (weanedByBuck.isNotEmpty) {
      final MapEntry<String, int> topBuck = weanedByBuck.entries.reduce(
        (MapEntry<String, int> a, MapEntry<String, int> b) =>
            a.value >= b.value ? a : b,
      );
      final Animal? buck = animalsById[topBuck.key];
      topBuckLabel =
          '${_animalLabel(buck, topBuck.key)} (${topBuck.value} sevr├®s)';
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
      case DashboardTaskKind.healthFollowUp:
        return DashboardCalendarCategory.health;
      case DashboardTaskKind.inventoryCheck:
        return DashboardCalendarCategory.general;
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
        return 'Visite v├®t├®rinaire';
      case 'treatment':
        return 'Traitement';
      case 'weight':
        return 'Pes├®e';
      case 'cage_change':
        return 'Changement de cage';
      case 'inventory':
        return 'Inventaire';
      default:
        if (eventType.isEmpty) {
          return '├ëv├®nement';
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
      return '${animal.tagId} ┬À ${animal.name}';
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
  Future<void> _restorePreferences() async {
    if (_preferencesLoaded) {
      return;
    }
    _preferencesLoaded = true;
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    try {
      final DashboardPreferences? prefs =
          await _dashboardRepository.loadPreferences(profileId);
      if (prefs == null) {
        return;
      }
      final List<DashboardKpiType> decodedKpis =
          _mergeKpiOrder(_decodeKpiOrder(prefs.kpiOrder));
      final List<DashboardModuleType> decodedModules =
          _mergeModuleOrder(_decodeModuleOrder(prefs.moduleOrder));
      final Set<DashboardModuleType> decodedHidden =
          _decodeHiddenModules(prefs.hiddenModules);
      emit(
        state.copyWith(
          kpiOrder: decodedKpis,
          moduleOrder: decodedModules,
          hiddenModules: decodedHidden,
        ),
      );
    } catch (_) {
      // ignore persistence failures
    }
  }

  List<DashboardKpiType> _decodeKpiOrder(List<String> raw) {
    final List<DashboardKpiType> order = <DashboardKpiType>[];
    for (final String value in raw) {
      try {
        final DashboardKpiType type = DashboardKpiType.values.byName(value);
        if (!order.contains(type)) {
          order.add(type);
        }
      } catch (_) {
        // ignore unknown values
      }
    }
    return order;
  }

  List<DashboardKpiType> _mergeKpiOrder(List<DashboardKpiType> stored) {
    final List<DashboardKpiType> merged = <DashboardKpiType>[...stored];
    for (final DashboardKpiType type in state.kpiOrder) {
      if (!merged.contains(type)) {
        merged.add(type);
      }
    }
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!merged.contains(type)) {
        merged.add(type);
      }
    }
    return merged;
  }

  List<DashboardModuleType> _decodeModuleOrder(List<String> raw) {
    final List<DashboardModuleType> order = <DashboardModuleType>[];
    for (final String value in raw) {
      try {
        final DashboardModuleType type =
            DashboardModuleType.values.byName(value);
        if (!order.contains(type)) {
          order.add(type);
        }
      } catch (_) {
        // ignore
      }
    }
    return order;
  }

  List<DashboardModuleType> _mergeModuleOrder(
    List<DashboardModuleType> stored,
  ) {
    final List<DashboardModuleType> merged = <DashboardModuleType>[...stored];
    for (final DashboardModuleType type in state.moduleOrder) {
      if (!merged.contains(type)) {
        merged.add(type);
      }
    }
    for (final DashboardModuleType type in DashboardModuleType.values) {
      if (!merged.contains(type)) {
        merged.add(type);
      }
    }
    return merged;
  }

  Set<DashboardModuleType> _decodeHiddenModules(Set<String> raw) {
    final Set<DashboardModuleType> hidden = <DashboardModuleType>{};
    for (final String value in raw) {
      try {
        hidden.add(DashboardModuleType.values.byName(value));
      } catch (_) {
        // ignore
      }
    }
    return hidden;
  }

  Future<void> _persistPreferences([DashboardState? override]) async {
    final String? profileId = _profileId;
    if (profileId == null) {
      return;
    }
    final DashboardState source = override ?? state;
    final DashboardPreferences prefs = DashboardPreferences(
      profileId: profileId,
      kpiOrder:
          source.kpiOrder.map((DashboardKpiType type) => type.name).toList(),
      moduleOrder: source.moduleOrder
          .map((DashboardModuleType type) => type.name)
          .toList(),
      hiddenModules: source.hiddenModules
          .map((DashboardModuleType type) => type.name)
          .toSet(),
      updatedAt: DateTime.now(),
    );
    try {
      await _dashboardRepository.savePreferences(prefs);
    } catch (_) {
      // ignore persistence failures
    }
  }

  BreedingPerformanceStats _performanceFromAggregates(
    List<DashboardKpiRow> rows,
  ) {
    if (rows.isEmpty) {
      return const BreedingPerformanceStats();
    }
    final DashboardKpiRow latest = rows.first;
    return BreedingPerformanceStats(
      totalLitters: latest.totalLitters,
      averageKitsBornAlive: latest.averageKitsBornAlive,
      averageKitsWeaned: latest.averageKitsWeaned,
      totalKitsWeaned: latest.totalKitsWeaned,
      topDoeLabel: latest.topDoeLabel,
      topBuckLabel: latest.topBuckLabel,
    );
  }

  List<DashboardTask> _buildInventoryTasks(
    InventorySummary summary,
    DateTime reference,
  ) {
    final List<DashboardTask> tasks = <DashboardTask>[];
    final double monthlyConsumption = summary.estimatedMonthlyConsumptionKg;
    if (monthlyConsumption <= 0) {
      return tasks;
    }
    final double daysCoverage = summary.totalQuantityKg <= 0
        ? 0
        : summary.totalQuantityKg / (monthlyConsumption / 30);
    if (daysCoverage < 14) {
      final DateTime dueDate =
          reference.add(Duration(days: daysCoverage.clamp(0, 7).round()));
      tasks.add(
        _createTask(
          dueDate: dueDate,
          kind: DashboardTaskKind.inventoryCheck,
          title: 'Verifier le stock d\'aliments',
          contextLabel:
              'Stock actuel ${summary.totalQuantityKg.toStringAsFixed(1)} kg',
          today: DateTime(reference.year, reference.month, reference.day),
        ),
      );
    }
    return tasks;
  }

  List<DashboardAlert> _buildInventoryAlerts(InventorySummary summary) {
    final List<DashboardAlert> alerts = <DashboardAlert>[];
    final double monthlyConsumption = summary.estimatedMonthlyConsumptionKg;
    if (monthlyConsumption <= 0) {
      return alerts;
    }
    final double daysCoverage = summary.totalQuantityKg <= 0
        ? 0
        : summary.totalQuantityKg / (monthlyConsumption / 30);
    if (daysCoverage < 14) {
      final DashboardAlertType type =
          daysCoverage < 7 ? DashboardAlertType.warning : DashboardAlertType.info;
      final String message = daysCoverage < 7
          ? 'Moins d\'une semaine de stock disponible.'
          : 'Stock alimentaire a reconstituer prochainement.';
      alerts.add(
        DashboardAlert(
          title: 'Alerte inventaire',
          message: message,
          timestamp: DateTime.now(),
          detail:
              '${summary.totalQuantityKg.toStringAsFixed(1)} kg restants (conso ${monthlyConsumption.toStringAsFixed(1)} kg/mois).',
          type: type,
        ),
      );
    }
    return alerts;
  }

  List<DashboardTask> _buildHealthTasks(
    List<LivestockEvent> events,
    Map<String, List<String>> eventAnimalMap,
    Map<String, Animal> animalsById,
    DateTime startOfToday,
  ) {
    final List<DashboardTask> tasks = <DashboardTask>[];
    for (final LivestockEvent event in events) {
      final Object? rawNextDue =
          event.details['nextDueDate'] ?? event.details['nextMaintenance'];
      if (rawNextDue is! String) {
        continue;
      }
      final DateTime? parsed = DateTime.tryParse(rawNextDue);
      if (parsed == null) {
        continue;
      }
      final DateTime dueDate =
          DateTime(parsed.year, parsed.month, parsed.day);
      final int diffDays = dueDate.difference(startOfToday).inDays;
      if (diffDays < -14 || diffDays > 45) {
        continue;
      }
      final List<String> linkedIds =
          eventAnimalMap[event.id] ?? _animalIdsFromEvent(event);
      final String contextLabel = linkedIds.isEmpty
          ? 'Elevage'
          : linkedIds
              .map((String id) => _animalLabel(animalsById[id], id))
              .join(', ');
      tasks.add(
        _createTask(
          dueDate: dueDate,
          kind: DashboardTaskKind.healthFollowUp,
          title: _labelForEvent(event.eventType),
          contextLabel: contextLabel,
          today: startOfToday,
        ),
      );
    }
    return tasks;
  }

  List<DashboardAlert> _buildHealthAlerts(List<DashboardTask> tasks) {
    final List<DashboardAlert> alerts = <DashboardAlert>[];
    for (final DashboardTask task in tasks) {
      final DashboardAlertType type = task.isOverdue
          ? DashboardAlertType.warning
          : DashboardAlertType.info;
      alerts.add(
        DashboardAlert(
          title: task.title,
          message: task.contextLabel,
          timestamp: task.dueDate,
          detail: task.relativeLabel,
          type: type,
        ),
      );
    }
    alerts.sort(
      (DashboardAlert a, DashboardAlert b) =>
          b.timestamp.compareTo(a.timestamp),
    );
    return alerts;
  }

  List<DashboardCalendarEvent> _calendarEventsFromTasks(
    List<DashboardTask> tasks,
  ) {
    return tasks
        .map(
          (DashboardTask task) => DashboardCalendarEvent(
            date: task.dueDate,
            title: '${task.title} - ${task.contextLabel}',
            subtitle: task.relativeLabel,
            category: _mapTaskKindToCategory(task.kind),
          ),
        )
        .toList();
  }

  DashboardTask _createTask({
    required DateTime dueDate,
    required DashboardTaskKind kind,
    required String title,
    required String contextLabel,
    required DateTime today,
  }) {
    final DateTime dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final String relativeLabel = _relativeLabelFor(dateOnly, today);
    final bool isOverdue = dateOnly.isBefore(today);
    return DashboardTask(
      title: title,
      contextLabel: contextLabel,
      dueDate: dateOnly,
      kind: kind,
      relativeLabel: relativeLabel,
      isOverdue: isOverdue,
    );
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

enum DashboardTaskKind { palpation, kindling, weaning, mating, healthFollowUp, inventoryCheck }

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
