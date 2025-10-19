import 'package:equatable/equatable.dart';

import '../../features/dashboard/domain/models/breeding_performance_stats.dart';
import '../repositories/food_inventory_repository.dart';
import 'dashboard_kpi_row.dart';

/// Remote snapshot returned by the dashboard aggregation RPC.
class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.totalAnimals,
    required this.activeAnimals,
    required this.doesInGestation,
    required this.plannedBreedings,
    required this.activeLitters,
    required this.breedingEvaluatedCount,
    this.breedingSuccessRate,
    this.todayTasks = const <DashboardSnapshotTask>[],
    this.upcomingTasks = const <DashboardSnapshotTask>[],
    this.alerts = const <DashboardSnapshotAlert>[],
    this.healthAlerts = const <DashboardSnapshotAlert>[],
    this.calendarEvents = const <DashboardSnapshotCalendarEvent>[],
    this.kpiFilters = const <String, DashboardSnapshotFilter>{},
    this.inventorySummary,
    this.performance,
    this.kpiRows,
  });

  final int totalAnimals;
  final int activeAnimals;
  final int doesInGestation;
  final int plannedBreedings;
  final int activeLitters;
  final int breedingEvaluatedCount;
  final double? breedingSuccessRate;
  final List<DashboardSnapshotTask> todayTasks;
  final List<DashboardSnapshotTask> upcomingTasks;
  final List<DashboardSnapshotAlert> alerts;
  final List<DashboardSnapshotAlert> healthAlerts;
  final List<DashboardSnapshotCalendarEvent> calendarEvents;
  final Map<String, DashboardSnapshotFilter> kpiFilters;
  final InventorySummary? inventorySummary;
  final BreedingPerformanceStats? performance;
  final List<DashboardKpiRow>? kpiRows;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshot(
      totalAnimals: (json['total_animals'] as num?)?.toInt() ?? 0,
      activeAnimals: (json['active_animals'] as num?)?.toInt() ?? 0,
      doesInGestation: (json['does_in_gestation'] as num?)?.toInt() ?? 0,
      plannedBreedings: (json['planned_breedings'] as num?)?.toInt() ?? 0,
      activeLitters: (json['active_litters'] as num?)?.toInt() ?? 0,
      breedingEvaluatedCount:
          (json['breeding_evaluated_count'] as num?)?.toInt() ?? 0,
      breedingSuccessRate:
          (json['breeding_success_rate'] as num?)?.toDouble(),
      todayTasks: _parseList(
        json['today_tasks'],
        DashboardSnapshotTask.fromJson,
      ),
      upcomingTasks: _parseList(
        json['upcoming_tasks'],
        DashboardSnapshotTask.fromJson,
      ),
      alerts: _parseList(json['alerts'], DashboardSnapshotAlert.fromJson),
      healthAlerts:
          _parseList(json['health_alerts'], DashboardSnapshotAlert.fromJson),
      calendarEvents: _parseList(
        json['calendar_events'],
        DashboardSnapshotCalendarEvent.fromJson,
      ),
      kpiFilters: _parseFilters(json['kpi_filters']),
      inventorySummary: json['inventory_summary'] == null
          ? null
          : InventorySummary.fromJson(
              Map<String, dynamic>.from(
                json['inventory_summary'] as Map<dynamic, dynamic>,
              ),
            ),
      performance: json['performance'] == null
          ? null
          : BreedingPerformanceStats.fromJson(
              Map<String, dynamic>.from(
                json['performance'] as Map<dynamic, dynamic>,
              ),
            ),
      kpiRows: json['kpi_rows'] == null
          ? null
          : _parseList(
              json['kpi_rows'],
              (Map<String, dynamic> row) => DashboardKpiRow.fromJson(row),
            ),
    );
  }

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> map) builder,
  ) {
    if (raw == null) {
      return <T>[];
    }
    return List<dynamic>.from(raw as Iterable<dynamic>)
        .map(
          (dynamic item) =>
              builder(Map<String, dynamic>.from(item as Map<dynamic, dynamic>)),
        )
        .toList();
  }

  static Map<String, DashboardSnapshotFilter> _parseFilters(dynamic raw) {
    if (raw == null) {
      return <String, DashboardSnapshotFilter>{};
    }
    final Map<String, DashboardSnapshotFilter> filters =
        <String, DashboardSnapshotFilter>{};
    final Map<String, dynamic> source =
        Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
    for (final MapEntry<String, dynamic> entry in source.entries) {
      filters[entry.key] = DashboardSnapshotFilter.fromJson(
        Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic>),
      );
    }
    return filters;
  }

  @override
  List<Object?> get props => <Object?>[
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
        kpiFilters,
        inventorySummary,
        performance,
        kpiRows,
      ];
}

class DashboardSnapshotTask extends Equatable {
  const DashboardSnapshotTask({
    required this.title,
    required this.contextLabel,
    required this.dueDate,
    required this.kind,
    this.relativeLabel,
    this.isOverdue = false,
  });

  final String title;
  final String contextLabel;
  final DateTime dueDate;
  final String kind;
  final String? relativeLabel;
  final bool isOverdue;

  factory DashboardSnapshotTask.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshotTask(
      title: json['title'] as String? ?? '',
      contextLabel: json['context_label'] as String? ?? '',
      dueDate: DateTime.parse(json['due_date'] as String),
      kind: json['kind'] as String? ?? 'general',
      relativeLabel: json['relative_label'] as String?,
      isOverdue: json['is_overdue'] as bool? ?? false,
    );
  }

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

class DashboardSnapshotAlert extends Equatable {
  const DashboardSnapshotAlert({
    required this.title,
    required this.message,
    required this.timestamp,
    this.detail,
    this.type = 'info',
  });

  final String title;
  final String message;
  final DateTime timestamp;
  final String? detail;
  final String type;

  factory DashboardSnapshotAlert.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshotAlert(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      detail: json['detail'] as String?,
      type: (json['type'] as String?)?.toLowerCase() ?? 'info',
    );
  }

  @override
  List<Object?> get props => <Object?>[title, message, timestamp, detail, type];
}

class DashboardSnapshotCalendarEvent extends Equatable {
  const DashboardSnapshotCalendarEvent({
    required this.date,
    required this.title,
    required this.category,
    this.subtitle,
  });

  final DateTime date;
  final String title;
  final String category;
  final String? subtitle;

  factory DashboardSnapshotCalendarEvent.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshotCalendarEvent(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      subtitle: json['subtitle'] as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[date, title, category, subtitle];
}

class DashboardSnapshotFilter extends Equatable {
  const DashboardSnapshotFilter({
    required this.label,
    this.sex,
    this.statusQuery,
    this.includeIds,
  });

  final String label;
  final String? sex;
  final String? statusQuery;
  final Set<String>? includeIds;

  factory DashboardSnapshotFilter.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshotFilter(
      label: json['label'] as String? ?? '',
      sex: json['sex'] as String?,
      statusQuery: json['status_query'] as String?,
      includeIds: json['include_ids'] == null
          ? null
          : Set<String>.from(List<dynamic>.from(json['include_ids'] as List)
              .map((dynamic id) => id.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      if (sex != null) 'sex': sex,
      if (statusQuery != null) 'status_query': statusQuery,
      if (includeIds != null) 'include_ids': includeIds!.toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[label, sex, statusQuery, includeIds];
}
