import 'package:equatable/equatable.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../domain/models/planning_filters.dart';
import '../../domain/models/schedule_task.dart';

enum PlanningStatus { initial, loading, success, failure }

enum PlanningCalendarView { month, week }

class PlanningBreedingChain extends Equatable {
  const PlanningBreedingChain({required this.record, required this.tasks});

  final BreedingRecord record;
  final List<BreedingTask> tasks;

  @override
  List<Object?> get props => <Object?>[record, tasks];
}

class PlanningState extends Equatable {
  const PlanningState({
    this.status = PlanningStatus.initial,
    this.tasks = const <ScheduleTask>[],
    this.filteredTasks = const <ScheduleTask>[],
    this.calendarBuckets = const <DateTime, List<ScheduleTask>>{},
    this.filters = const PlanningFilters(
      statuses: <ScheduleTaskStatus>{},
      period: PlanningPeriod.all,
      types: <String>{},
    ),
    this.searchQuery = '',
    this.calendarView = PlanningCalendarView.month,
    this.calendarAnchor,
    this.selectedDay,
    this.selectedTaskIds = const <String>{},
    this.breedingChains = const <PlanningBreedingChain>[],
    this.breedingRecordsById = const <String, BreedingRecord>{},
    this.animalsById = const <String, Animal>{},
    this.isOfflineMode = false,
    this.offlinePendingActions = 0,
    this.errorMessage,
  });

  factory PlanningState.initial() {
    final DateTime now = DateTime.now();
    final DateTime dayOnly = DateTime(now.year, now.month, now.day);
    return PlanningState(
      filters: PlanningFilters.initial(),
      calendarAnchor: DateTime(dayOnly.year, dayOnly.month, 1),
      selectedDay: dayOnly,
    );
  }

  final PlanningStatus status;
  final List<ScheduleTask> tasks;
  final List<ScheduleTask> filteredTasks;
  final Map<DateTime, List<ScheduleTask>> calendarBuckets;
  final PlanningFilters filters;
  final String searchQuery;
  final PlanningCalendarView calendarView;
  final DateTime? calendarAnchor;
  final DateTime? selectedDay;
  final Set<String> selectedTaskIds;
  final List<PlanningBreedingChain> breedingChains;
  final Map<String, BreedingRecord> breedingRecordsById;
  final Map<String, Animal> animalsById;
  final bool isOfflineMode;
  final int offlinePendingActions;
  final String? errorMessage;

  PlanningState copyWith({
    PlanningStatus? status,
    List<ScheduleTask>? tasks,
    List<ScheduleTask>? filteredTasks,
    Map<DateTime, List<ScheduleTask>>? calendarBuckets,
    PlanningFilters? filters,
    String? searchQuery,
    PlanningCalendarView? calendarView,
    DateTime? calendarAnchor,
    bool clearCalendarAnchor = false,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
    Set<String>? selectedTaskIds,
    List<PlanningBreedingChain>? breedingChains,
    Map<String, BreedingRecord>? breedingRecordsById,
    Map<String, Animal>? animalsById,
    bool? isOfflineMode,
    int? offlinePendingActions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlanningState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      calendarBuckets: calendarBuckets ?? this.calendarBuckets,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      calendarView: calendarView ?? this.calendarView,
      calendarAnchor: clearCalendarAnchor
          ? null
          : (calendarAnchor ?? this.calendarAnchor),
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      breedingChains: breedingChains ?? this.breedingChains,
      breedingRecordsById: breedingRecordsById ?? this.breedingRecordsById,
      animalsById: animalsById ?? this.animalsById,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      offlinePendingActions:
          offlinePendingActions ?? this.offlinePendingActions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    tasks,
    filteredTasks,
    calendarBuckets,
    filters,
    searchQuery,
    calendarView,
    calendarAnchor,
    selectedDay,
    selectedTaskIds,
    breedingChains,
    breedingRecordsById,
    animalsById,
    isOfflineMode,
    offlinePendingActions,
    errorMessage,
  ];
}
