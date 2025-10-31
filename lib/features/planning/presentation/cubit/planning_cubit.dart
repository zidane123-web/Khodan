import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/models/sync_action.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../domain/models/planning_filters.dart';
import '../../domain/models/schedule_task.dart';
import 'planning_state.dart';

class PlanningCubit extends Cubit<PlanningState> {
  PlanningCubit({
    required EventRepository eventRepository,
    required BreedingRepository breedingRepository,
    required AnimalRepository animalRepository,
    OfflineSyncManager? offlineManager,
    DateTime Function()? now,
  }) : _eventRepository = eventRepository,
       _breedingRepository = breedingRepository,
       _animalRepository = animalRepository,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance,
       _now = now ?? DateTime.now,
       super(PlanningState.initial()) {
    _queueListener = _handleOfflineQueueChanged;
    _offlineListener = _handleOfflineQueueChanged;
    _offlineManager.pendingQueueNotifier.addListener(_queueListener);
    _offlineManager.isOffline.addListener(_offlineListener);
  }

  final EventRepository _eventRepository;
  final BreedingRepository _breedingRepository;
  final AnimalRepository _animalRepository;
  final OfflineSyncManager _offlineManager;
  final DateTime Function() _now;

  late final VoidCallback _queueListener;
  late final VoidCallback _offlineListener;

  Future<void> load() => _refreshData();

  Future<void> refreshSilently() => _refreshData(showLoadingIndicator: false);

  Future<void> markTaskDone(ScheduleTask task) async {
    if (task.source == ScheduleTaskSource.event && task.event != null) {
      final LivestockEvent event = task.event!;
      final Map<String, dynamic> details = Map<String, dynamic>.from(
        event.details,
      );
      details['status'] = 'completed';
      details['completedAt'] = _now().toIso8601String();
      final LivestockEvent updated = event.copyWith(
        details: details,
        eventDate: event.eventDate,
      );
      await _eventRepository.updateEvent(updated);
      await _refreshData(showLoadingIndicator: false);
      return;
    }

    if (task.source == ScheduleTaskSource.breeding && task.reminder != null) {
      await _completeBreedingReminder(task.reminder!);
      await _refreshData(showLoadingIndicator: false);
    }
  }

  Future<void> rescheduleTask(ScheduleTask task, DateTime newDateTime) async {
    if (task.source != ScheduleTaskSource.event || task.event == null) {
      return;
    }
    final LivestockEvent event = task.event!;
    final LivestockEvent updated = event.copyWith(eventDate: newDateTime);
    await _eventRepository.updateEvent(updated);
    await _refreshData(showLoadingIndicator: false);
  }

  Future<void> deleteTask(ScheduleTask task) async {
    if (task.source != ScheduleTaskSource.event) {
      return;
    }
    await _eventRepository.deleteEvent(task.id);
    await _refreshData(showLoadingIndicator: false);
  }

  Future<void> markBreedingStepDone(
    String recordId,
    BreedingTaskType type,
  ) async {
    final BreedingRecord? record = state.breedingRecordsById[recordId];
    if (record == null) {
      return;
    }
    final DateTime now = _now();
    BreedingRecord updated = record;
    switch (type) {
      case BreedingTaskType.palpation:
        updated = record.copyWith(
          palpationDate: now,
          palpationPositive: record.palpationPositive ?? true,
        );
        break;
      case BreedingTaskType.kindling:
        updated = record.copyWith(kindlingDate: now);
        break;
      case BreedingTaskType.weaning:
        updated = record.copyWith(weaningDate: now);
        break;
    }
    await _breedingRepository.updateBreedingRecord(updated);
    await _refreshData(showLoadingIndicator: false);
  }

  void updateSearch(String query) {
    final String cleaned = query.trim();
    if (cleaned == state.searchQuery) {
      return;
    }
    _recomputeFilteredTasks(filters: state.filters, searchQuery: cleaned);
  }

  void toggleStatusFilter(ScheduleTaskStatus status) {
    final Set<ScheduleTaskStatus> next = Set<ScheduleTaskStatus>.from(
      state.filters.statuses,
    );
    if (!next.add(status)) {
      next.remove(status);
    }
    if (next.isEmpty) {
      next.addAll(<ScheduleTaskStatus>{
        ScheduleTaskStatus.planned,
        ScheduleTaskStatus.overdue,
      });
    }
    _recomputeFilteredTasks(
      filters: state.filters.copyWith(statuses: next),
      searchQuery: state.searchQuery,
    );
  }

  void setPeriodFilter(PlanningPeriod period) {
    if (state.filters.period == period) {
      return;
    }
    _recomputeFilteredTasks(
      filters: state.filters.copyWith(period: period),
      searchQuery: state.searchQuery,
    );
  }

  void toggleTypeFilter(String type) {
    final String normalized = type.toLowerCase();
    final Set<String> next = Set<String>.from(state.filters.types);
    if (!next.add(normalized)) {
      next.remove(normalized);
    }
    _recomputeFilteredTasks(
      filters: state.filters.copyWith(types: next),
      searchQuery: state.searchQuery,
    );
  }

  void setTypeFilters(Set<String> types) {
    _recomputeFilteredTasks(
      filters: state.filters.copyWith(types: types),
      searchQuery: state.searchQuery,
    );
  }

  void resetFilters() {
    _recomputeFilteredTasks(
      filters: PlanningFilters.initial(),
      searchQuery: '',
      clearSelection: true,
    );
  }

  void setCalendarView(PlanningCalendarView view) {
    if (view == state.calendarView) {
      return;
    }
    emit(state.copyWith(calendarView: view));
  }

  void goToAdjacentMonth(int offset) {
    final DateTime anchor = state.calendarAnchor ?? DateTime.now();
    final DateTime next = DateTime(anchor.year, anchor.month + offset, 1);
    emit(state.copyWith(calendarAnchor: next));
  }

  void selectDay(DateTime day) {
    final DateTime normalized = _normalizeDay(day);
    emit(
      state.copyWith(
        selectedDay: normalized,
        calendarAnchor: DateTime(normalized.year, normalized.month, 1),
      ),
    );
  }

  void toggleTaskSelection(String taskId) {
    final Set<String> next = Set<String>.from(state.selectedTaskIds);
    if (!next.add(taskId)) {
      next.remove(taskId);
    }
    emit(state.copyWith(selectedTaskIds: next));
  }

  void clearSelection() {
    if (state.selectedTaskIds.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedTaskIds: <String>{}));
  }

  List<ScheduleTask> collectSelection() {
    final Set<String> ids = state.selectedTaskIds;
    if (ids.isEmpty) {
      return state.filteredTasks;
    }
    final Map<String, ScheduleTask> byId = <String, ScheduleTask>{
      for (final ScheduleTask task in state.tasks) task.id: task,
    };
    return <ScheduleTask>[
      for (final String id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  @override
  Future<void> close() {
    _offlineManager.pendingQueueNotifier.removeListener(_queueListener);
    _offlineManager.isOffline.removeListener(_offlineListener);
    return super.close();
  }

  Future<void> _refreshData({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      emit(state.copyWith(status: PlanningStatus.loading, clearError: true));
    }
    try {
      final DateTime now = _now();
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _eventRepository.fetchEvents(),
            _eventRepository.fetchEventLinks(),
            _animalRepository.fetchAnimals(),
            _breedingRepository.fetchBreedingRecords(),
          ]);

      final List<LivestockEvent> events = results[0] as List<LivestockEvent>;
      final List<AnimalEventLink> links = results[1] as List<AnimalEventLink>;
      final List<Animal> animals = results[2] as List<Animal>;
      final List<BreedingRecord> records = results[3] as List<BreedingRecord>;

      final Map<String, Animal> animalsById = <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };
      final Map<String, List<String>> eventAnimals = _mapEventAnimals(links);
      final Set<String> pendingIds = _pendingEventIds();

      final List<ScheduleTask> eventTasks = <ScheduleTask>[
        for (final LivestockEvent event in events)
          _mapEventToTask(
            event,
            eventAnimals[event.id] ?? const <String>[],
            animalsById,
            now,
            pendingIds.contains(event.id),
          ),
      ];

      final List<ScheduleTask> breedingTasks = <ScheduleTask>[
        for (final BreedingReminder reminder in BreedingReminder.build(records))
          _mapReminderToTask(reminder, animalsById, now),
      ];

      final List<ScheduleTask> allTasks =
          <ScheduleTask>[...eventTasks, ...breedingTasks]
            ..sort((ScheduleTask a, ScheduleTask b) {
              return a.scheduledAt.compareTo(b.scheduledAt);
            });

      final PlanningFilters filters =
          state.filters.statuses.isEmpty && state.filters.types.isEmpty
          ? PlanningFilters.initial()
          : state.filters;
      final String search = state.searchQuery;

      final List<ScheduleTask> filtered = _applyFilters(
        tasks: allTasks,
        filters: filters,
        searchQuery: search,
      );
      final Map<DateTime, List<ScheduleTask>> buckets = _buildCalendarBuckets(
        filtered,
      );

      final DateTime selectedDay = _normalizeDay(state.selectedDay ?? now);
      final DateTime anchor =
          state.calendarAnchor ??
          DateTime(selectedDay.year, selectedDay.month, 1);

      final List<PlanningBreedingChain> chains = _buildBreedingChains(records);

      final Set<String> selection = state.selectedTaskIds
          .where(
            (String id) => allTasks.any((ScheduleTask task) => task.id == id),
          )
          .toSet();

      emit(
        state.copyWith(
          status: PlanningStatus.success,
          tasks: allTasks,
          filteredTasks: filtered,
          calendarBuckets: buckets,
          filters: filters,
          searchQuery: search,
          selectedDay: selectedDay,
          calendarAnchor: anchor,
          breedingChains: chains,
          breedingRecordsById: <String, BreedingRecord>{
            for (final BreedingRecord record in records) record.id: record,
          },
          animalsById: animalsById,
          selectedTaskIds: selection,
          isOfflineMode: _offlineManager.isOffline.value,
          offlinePendingActions: _offlineManager.pendingActions.value,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PlanningStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _recomputeFilteredTasks({
    required PlanningFilters filters,
    required String searchQuery,
    bool clearSelection = false,
  }) {
    final List<ScheduleTask> filtered = _applyFilters(
      tasks: state.tasks,
      filters: filters,
      searchQuery: searchQuery,
    );
    final Map<DateTime, List<ScheduleTask>> buckets = _buildCalendarBuckets(
      filtered,
    );
    emit(
      state.copyWith(
        filters: filters,
        searchQuery: searchQuery,
        filteredTasks: filtered,
        calendarBuckets: buckets,
        selectedTaskIds: clearSelection ? <String>{} : state.selectedTaskIds,
      ),
    );
  }

  Map<String, List<String>> _mapEventAnimals(List<AnimalEventLink> links) {
    final Map<String, List<String>> map = <String, List<String>>{};
    for (final AnimalEventLink link in links) {
      map.putIfAbsent(link.eventId, () => <String>[]);
      map[link.eventId]!.add(link.animalId);
    }
    return map;
  }

  ScheduleTask _mapEventToTask(
    LivestockEvent event,
    List<String> linkedAnimalIds,
    Map<String, Animal> animalsById,
    DateTime now,
    bool isPending,
  ) {
    final Map<String, dynamic> details = Map<String, dynamic>.from(
      event.details,
    );
    final String? rawStatus =
        (details['status'] as String?) ?? (details['taskStatus'] as String?);
    final DateTime scheduledAt = event.eventDate;
    final DateTime? completedAt = _parseDate(
      details['completedAt'] ?? details['completed_at'],
    );
    final ScheduleTaskStatus status = completedAt != null
        ? ScheduleTaskStatus.completed
        : _deriveStatus(rawStatus, scheduledAt, now);
    final ScheduleTaskCategory category = _mapEventTypeToCategory(
      event.eventType,
    );
    final ScheduleTaskPriority priority = _mapPriority(
      details['priority'] as String?,
    );
    final List<String> ids = _animalIdsFromDetails(
      details,
      fallback: linkedAnimalIds,
    );
    final List<String> subjects = ids
        .map((String id) => _formatAnimal(animalsById[id], id))
        .where((String label) => label.isNotEmpty)
        .toList();
    final String? description =
        (details['description'] as String?)?.trim().isNotEmpty == true
        ? (details['description'] as String)
        : event.notes;
    final String? litterId =
        (details['litterId'] as String?) ?? (details['litter_id'] as String?);
    final String? origin = details['origin'] as String?;

    return ScheduleTask(
      id: event.id,
      source: ScheduleTaskSource.event,
      status: status,
      category: category,
      type: event.eventType,
      scheduledAt: scheduledAt,
      description: description,
      priority: priority,
      origin: origin,
      subjects: subjects,
      animalIds: ids,
      completedAt: completedAt,
      litterId: litterId,
      isOfflinePending: isPending,
      event: event,
    );
  }

  ScheduleTask _mapReminderToTask(
    BreedingReminder reminder,
    Map<String, Animal> animalsById,
    DateTime now,
  ) {
    final List<String> subjects = <String>[
      _formatAnimal(animalsById[reminder.doeId], reminder.doeId),
      _formatAnimal(animalsById[reminder.buckId], reminder.buckId),
    ].where((String label) => label.isNotEmpty).toList();

    final ScheduleTaskStatus status = reminder.completedDate != null
        ? ScheduleTaskStatus.completed
        : reminder.dueDate.isBefore(now)
        ? ScheduleTaskStatus.overdue
        : ScheduleTaskStatus.planned;

    return ScheduleTask(
      id: 'breeding:${reminder.recordId}:${reminder.type.name}',
      source: ScheduleTaskSource.breeding,
      status: status,
      category: ScheduleTaskCategory.reproduction,
      type: 'breeding_${reminder.type.name}',
      scheduledAt: reminder.dueDate,
      subjects: subjects,
      animalIds: <String>[reminder.doeId, reminder.buckId],
      completedAt: reminder.completedDate,
      origin: 'breeding',
      isOfflinePending: false,
      reminder: reminder,
    );
  }

  List<PlanningBreedingChain> _buildBreedingChains(
    List<BreedingRecord> records,
  ) {
    final List<PlanningBreedingChain> chains = <PlanningBreedingChain>[
      for (final BreedingRecord record in records)
        PlanningBreedingChain(record: record, tasks: record.tasks),
    ];
    chains.sort(
      (PlanningBreedingChain a, PlanningBreedingChain b) =>
          a.record.matingDate.compareTo(b.record.matingDate),
    );
    return chains;
  }

  List<ScheduleTask> _applyFilters({
    required List<ScheduleTask> tasks,
    required PlanningFilters filters,
    required String searchQuery,
  }) {
    final DateTime now = _now();
    final String query = searchQuery.toLowerCase();
    final bool hasQuery = query.isNotEmpty;
    final Set<ScheduleTaskStatus> statuses = filters.statuses;
    final Set<String> types = filters.types
        .map((String type) => type.toLowerCase())
        .toSet();

    final List<ScheduleTask> filtered = <ScheduleTask>[];
    for (final ScheduleTask task in tasks) {
      if (statuses.isNotEmpty && !statuses.contains(task.status)) {
        continue;
      }
      if (!_matchesPeriod(task, filters.period, now)) {
        continue;
      }
      if (types.isNotEmpty && !types.contains(task.type.toLowerCase())) {
        continue;
      }
      if (hasQuery && !_matchesQuery(task, query)) {
        continue;
      }
      filtered.add(task);
    }

    filtered.sort(
      (ScheduleTask a, ScheduleTask b) =>
          a.scheduledAt.compareTo(b.scheduledAt),
    );
    return filtered;
  }

  Map<DateTime, List<ScheduleTask>> _buildCalendarBuckets(
    List<ScheduleTask> tasks,
  ) {
    final Map<DateTime, List<ScheduleTask>> buckets =
        SplayTreeMap<DateTime, List<ScheduleTask>>();
    for (final ScheduleTask task in tasks) {
      final DateTime day = task.day;
      buckets.putIfAbsent(day, () => <ScheduleTask>[]);
      buckets[day]!.add(task);
    }
    for (final List<ScheduleTask> list in buckets.values) {
      list.sort(
        (ScheduleTask a, ScheduleTask b) =>
            a.scheduledAt.compareTo(b.scheduledAt),
      );
    }
    return buckets;
  }

  bool _matchesPeriod(ScheduleTask task, PlanningPeriod period, DateTime now) {
    if (period == PlanningPeriod.all) {
      return true;
    }
    if (task.isOverdue) {
      return true;
    }
    final DateTime today = _normalizeDay(now);
    final DateTime day = task.day;
    switch (period) {
      case PlanningPeriod.all:
        return true;
      case PlanningPeriod.today:
        return day == today;
      case PlanningPeriod.week:
        return !day.isBefore(today) &&
            day.isBefore(today.add(const Duration(days: 7)));
      case PlanningPeriod.month:
        return !day.isBefore(today) &&
            day.isBefore(today.add(const Duration(days: 30)));
    }
  }

  bool _matchesQuery(ScheduleTask task, String query) {
    final String haystack = <String>[
      task.type,
      task.description ?? '',
      ...task.subjects,
      ...task.animalIds,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  Set<String> _pendingEventIds() {
    final Iterable<QueuedSyncAction> queue = _offlineManager.pendingQueue;
    final Set<String> ids = <String>{};
    for (final QueuedSyncAction action in queue) {
      switch (action.type) {
        case SyncActionType.createEvent:
        case SyncActionType.updateEvent:
          final Map<String, dynamic>? raw =
              action.payload['event'] as Map<String, dynamic>?;
          final String? id = raw?['id'] as String?;
          if (id != null) {
            ids.add(id);
          }
          break;
        case SyncActionType.deleteEvent:
          final String? id = action.payload['event_id'] as String?;
          if (id != null) {
            ids.add(id);
          }
          break;
        default:
          break;
      }
    }
    return ids;
  }

  Future<void> _completeBreedingReminder(BreedingReminder reminder) async {
    final BreedingRecord? record = state.breedingRecordsById[reminder.recordId];
    if (record == null) {
      return;
    }
    await markBreedingStepDone(reminder.recordId, reminder.type);
  }

  List<String> _animalIdsFromDetails(
    Map<String, dynamic> details, {
    List<String> fallback = const <String>[],
  }) {
    final dynamic raw = details['animalIds'] ?? details['animal_ids'];
    if (raw is List) {
      return raw.whereType<String>().toSet().toList();
    }
    return fallback.toSet().toList();
  }

  ScheduleTaskStatus _deriveStatus(
    String? rawStatus,
    DateTime scheduledAt,
    DateTime now,
  ) {
    final String normalized = rawStatus?.toLowerCase() ?? '';
    switch (normalized) {
      case 'completed':
      case 'done':
        return ScheduleTaskStatus.completed;
      case 'skipped':
      case 'ignored':
      case 'cancelled':
      case 'canceled':
        return ScheduleTaskStatus.skipped;
      default:
        return scheduledAt.isBefore(now)
            ? ScheduleTaskStatus.overdue
            : ScheduleTaskStatus.planned;
    }
  }

  ScheduleTaskCategory _mapEventTypeToCategory(String type) {
    final String normalized = type.toLowerCase();
    if (normalized == 'mating' ||
        normalized == 'palpation' ||
        normalized == 'kindling' ||
        normalized == 'weaning' ||
        normalized == 'breeding') {
      return ScheduleTaskCategory.reproduction;
    }
    if (normalized == 'treatment' ||
        normalized == 'health_check' ||
        normalized == 'vaccination' ||
        normalized == 'weight') {
      return ScheduleTaskCategory.health;
    }
    if (normalized == 'inventory' ||
        normalized == 'cleaning' ||
        normalized == 'cage_change' ||
        normalized == 'feeding') {
      return ScheduleTaskCategory.logistics;
    }
    return ScheduleTaskCategory.monitoring;
  }

  ScheduleTaskPriority _mapPriority(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'important':
      case 'high':
        return ScheduleTaskPriority.important;
      case 'critical':
      case 'urgent':
        return ScheduleTaskPriority.critical;
      default:
        return ScheduleTaskPriority.normal;
    }
  }

  String _formatAnimal(Animal? animal, String fallback) {
    if (animal == null) {
      return fallback;
    }
    final String tag = animal.tagId.isNotEmpty ? animal.tagId : fallback;
    if (animal.name != null && animal.name!.isNotEmpty) {
      return '$tag ${animal.name}';
    }
    return tag;
  }

  DateTime _normalizeDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  void _handleOfflineQueueChanged() {
    if (state.status != PlanningStatus.success) {
      emit(
        state.copyWith(
          isOfflineMode: _offlineManager.isOffline.value,
          offlinePendingActions: _offlineManager.pendingActions.value,
        ),
      );
      return;
    }
    final Set<String> pendingIds = _pendingEventIds();
    final List<ScheduleTask> updatedTasks = <ScheduleTask>[
      for (final ScheduleTask task in state.tasks)
        task.source == ScheduleTaskSource.event
            ? task.copyWith(isOfflinePending: pendingIds.contains(task.id))
            : task,
    ];
    final List<ScheduleTask> filtered = _applyFilters(
      tasks: updatedTasks,
      filters: state.filters,
      searchQuery: state.searchQuery,
    );
    final Map<DateTime, List<ScheduleTask>> buckets = _buildCalendarBuckets(
      filtered,
    );
    emit(
      state.copyWith(
        tasks: updatedTasks,
        filteredTasks: filtered,
        calendarBuckets: buckets,
        offlinePendingActions: _offlineManager.pendingActions.value,
        isOfflineMode: _offlineManager.isOffline.value,
      ),
    );
  }
}
