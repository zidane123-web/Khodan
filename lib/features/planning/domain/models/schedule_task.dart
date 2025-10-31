import 'package:equatable/equatable.dart';

import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';

enum ScheduleTaskSource { event, breeding }

enum ScheduleTaskStatus { planned, overdue, completed, skipped, cancelled }

enum ScheduleTaskPriority { normal, important, critical }

enum ScheduleTaskCategory { reproduction, health, logistics, monitoring }

class ScheduleTask extends Equatable {
  const ScheduleTask({
    required this.id,
    required this.source,
    required this.status,
    required this.category,
    required this.type,
    required this.scheduledAt,
    this.description,
    this.priority = ScheduleTaskPriority.normal,
    this.origin,
    this.subjects = const <String>[],
    this.animalIds = const <String>[],
    this.completedAt,
    this.litterId,
    this.isOfflinePending = false,
    this.event,
    this.reminder,
  });

  final String id;
  final ScheduleTaskSource source;
  final ScheduleTaskStatus status;
  final ScheduleTaskCategory category;
  final String type;
  final DateTime scheduledAt;
  final String? description;
  final ScheduleTaskPriority priority;
  final String? origin;
  final List<String> subjects;
  final List<String> animalIds;
  final DateTime? completedAt;
  final String? litterId;
  final bool isOfflinePending;
  final LivestockEvent? event;
  final BreedingReminder? reminder;

  DateTime get day =>
      DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);

  bool get hasSpecificTime =>
      scheduledAt.hour != 0 ||
      scheduledAt.minute != 0 ||
      scheduledAt.second != 0;

  bool get isCompleted => status == ScheduleTaskStatus.completed;

  bool get isOverdue => status == ScheduleTaskStatus.overdue;

  ScheduleTask copyWith({
    ScheduleTaskStatus? status,
    DateTime? scheduledAt,
    String? description,
    ScheduleTaskPriority? priority,
    String? origin,
    List<String>? subjects,
    List<String>? animalIds,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? isOfflinePending,
    LivestockEvent? event,
    BreedingReminder? reminder,
  }) {
    return ScheduleTask(
      id: id,
      source: source,
      status: status ?? this.status,
      category: category,
      type: type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      origin: origin ?? this.origin,
      subjects: subjects ?? this.subjects,
      animalIds: animalIds ?? this.animalIds,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      litterId: litterId,
      isOfflinePending: isOfflinePending ?? this.isOfflinePending,
      event: event ?? this.event,
      reminder: reminder ?? this.reminder,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    source,
    status,
    category,
    type,
    scheduledAt,
    description,
    priority,
    origin,
    subjects,
    animalIds,
    completedAt,
    litterId,
    isOfflinePending,
    event,
    reminder,
  ];
}
