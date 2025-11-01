import 'package:equatable/equatable.dart';

enum HealthTreatmentType {
  medication('medication'),
  procedure('procedure'),
  care('care'),
  dietAdjustment('diet_adjustment');

  const HealthTreatmentType(this.key);

  final String key;

  static HealthTreatmentType fromKey(String value) {
    return HealthTreatmentType.values.firstWhere(
      (HealthTreatmentType type) => type.key == value,
      orElse: () => HealthTreatmentType.medication,
    );
  }
}

class HealthTreatment extends Equatable {
  const HealthTreatment({
    required this.id,
    required this.recordId,
    required this.profileId,
    required this.title,
    required this.treatmentType,
    this.dosage,
    this.frequency,
    required this.startAt,
    this.endAt,
    this.completedAt,
    this.notes,
    this.taskId,
    this.reminderMinutes = const <int>[],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String recordId;
  final String profileId;
  final String title;
  final HealthTreatmentType treatmentType;
  final String? dosage;
  final String? frequency;
  final DateTime startAt;
  final DateTime? endAt;
  final DateTime? completedAt;
  final String? notes;
  final String? taskId;
  final List<int> reminderMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => completedAt != null;

  HealthTreatment copyWith({
    String? id,
    String? recordId,
    String? profileId,
    String? title,
    HealthTreatmentType? treatmentType,
    String? dosage,
    String? frequency,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? notes,
    String? taskId,
    bool clearTaskId = false,
    List<int>? reminderMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthTreatment(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      treatmentType: treatmentType ?? this.treatmentType,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : endAt ?? this.endAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      taskId: clearTaskId ? null : taskId ?? this.taskId,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HealthTreatment.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawReminders =
        (json['reminder_minutes'] as List<dynamic>? ?? <dynamic>[]);
    return HealthTreatment(
      id: json['id'] as String,
      recordId: json['record_id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      treatmentType:
          HealthTreatmentType.fromKey(json['treatment_type'] as String? ??
              HealthTreatmentType.medication.key),
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] == null
          ? null
          : DateTime.parse(json['end_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      notes: json['notes'] as String?,
      taskId: json['task_id'] as String?,
      reminderMinutes: rawReminders
          .map((dynamic value) => (value as num).toInt())
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'record_id': recordId,
      'profile_id': profileId,
      'title': title,
      'treatment_type': treatmentType.key,
      'dosage': dosage,
      'frequency': frequency,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'task_id': taskId,
      'reminder_minutes': reminderMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        recordId,
        profileId,
        title,
        treatmentType,
        dosage,
        frequency,
        startAt,
        endAt,
        completedAt,
        notes,
        taskId,
        reminderMinutes,
        createdAt,
        updatedAt,
      ];
}
