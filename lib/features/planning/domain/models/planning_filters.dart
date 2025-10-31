import 'package:equatable/equatable.dart';

import 'schedule_task.dart';

enum PlanningPeriod { all, today, week, month }

class PlanningFilters extends Equatable {
  const PlanningFilters({
    required this.statuses,
    required this.period,
    required this.types,
  });

  factory PlanningFilters.initial() {
    return PlanningFilters(
      statuses: <ScheduleTaskStatus>{
        ScheduleTaskStatus.planned,
        ScheduleTaskStatus.overdue,
      },
      period: PlanningPeriod.week,
      types: const <String>{},
    );
  }

  final Set<ScheduleTaskStatus> statuses;
  final PlanningPeriod period;
  final Set<String> types;

  PlanningFilters copyWith({
    Set<ScheduleTaskStatus>? statuses,
    PlanningPeriod? period,
    Set<String>? types,
  }) {
    return PlanningFilters(
      statuses: statuses ?? this.statuses,
      period: period ?? this.period,
      types: types ?? this.types,
    );
  }

  @override
  List<Object?> get props {
    final List<ScheduleTaskStatus> statusList = statuses.toList()
      ..sort(
        (ScheduleTaskStatus a, ScheduleTaskStatus b) =>
            a.index.compareTo(b.index),
      );
    final List<String> typeList = types.toList()..sort();
    return <Object?>[statusList, period, typeList];
  }
}
