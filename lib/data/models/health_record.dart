import 'package:equatable/equatable.dart';

import 'ailment.dart';
import 'health_treatment.dart';

enum HealthRecordStatus {
  draft('draft'),
  active('active'),
  resolved('resolved'),
  archived('archived');

  const HealthRecordStatus(this.key);

  final String key;

  static HealthRecordStatus fromKey(String value) {
    return HealthRecordStatus.values.firstWhere(
      (HealthRecordStatus status) => status.key == value,
      orElse: () => HealthRecordStatus.active,
    );
  }
}

enum HealthSeverity {
  low('low'),
  moderate('moderate'),
  high('high'),
  critical('critical');

  const HealthSeverity(this.key);

  final String key;

  static HealthSeverity fromKey(String value) {
    return HealthSeverity.values.firstWhere(
      (HealthSeverity severity) => severity.key == value,
      orElse: () => HealthSeverity.moderate,
    );
  }
}

class HealthRecord extends Equatable {
  const HealthRecord({
    required this.id,
    required this.profileId,
    required this.animalId,
    this.ailmentId,
    this.customDiagnosis,
    required this.status,
    required this.severity,
    this.symptoms = const <HealthSymptom>[],
    this.notes,
    required this.onsetDate,
    this.resolvedAt,
    this.nextCheckAt,
    this.offlineReference,
    required this.createdAt,
    required this.updatedAt,
    this.treatments = const <HealthTreatment>[],
  });

  final String id;
  final String profileId;
  final String animalId;
  final String? ailmentId;
  final String? customDiagnosis;
  final HealthRecordStatus status;
  final HealthSeverity severity;
  final List<HealthSymptom> symptoms;
  final String? notes;
  final DateTime onsetDate;
  final DateTime? resolvedAt;
  final DateTime? nextCheckAt;
  final String? offlineReference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<HealthTreatment> treatments;

  bool get isResolved => status == HealthRecordStatus.resolved;

  HealthRecord copyWith({
    String? id,
    String? profileId,
    String? animalId,
    String? ailmentId,
    bool clearAilment = false,
    String? customDiagnosis,
    bool clearCustomDiagnosis = false,
    HealthRecordStatus? status,
    HealthSeverity? severity,
    List<HealthSymptom>? symptoms,
    String? notes,
    bool clearNotes = false,
    DateTime? onsetDate,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    DateTime? nextCheckAt,
    bool clearNextCheckAt = false,
    String? offlineReference,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<HealthTreatment>? treatments,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      animalId: animalId ?? this.animalId,
      ailmentId: clearAilment ? null : ailmentId ?? this.ailmentId,
      customDiagnosis: clearCustomDiagnosis
          ? null
          : customDiagnosis ?? this.customDiagnosis,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      notes: clearNotes ? null : notes ?? this.notes,
      onsetDate: onsetDate ?? this.onsetDate,
      resolvedAt:
          clearResolvedAt ? null : resolvedAt ?? this.resolvedAt,
      nextCheckAt:
          clearNextCheckAt ? null : nextCheckAt ?? this.nextCheckAt,
      offlineReference: offlineReference ?? this.offlineReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      treatments: treatments ?? this.treatments,
    );
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSymptoms =
        (json['symptoms'] as List<dynamic>? ?? <dynamic>[]);
    final List<dynamic> rawTreatments =
        (json['health_treatments'] as List<dynamic>? ??
            json['treatments'] as List<dynamic>? ??
            <dynamic>[]);
    return HealthRecord(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      animalId: json['animal_id'] as String,
      ailmentId: json['ailment_id'] as String?,
      customDiagnosis: json['custom_diagnosis'] as String?,
      status: HealthRecordStatus.fromKey(
        json['status'] as String? ?? HealthRecordStatus.active.key,
      ),
      severity: HealthSeverity.fromKey(
        json['severity'] as String? ?? HealthSeverity.moderate.key,
      ),
      symptoms: rawSymptoms
          .map((dynamic item) =>
              HealthSymptom.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      notes: json['notes'] as String?,
      onsetDate: DateTime.parse(json['onset_date'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      nextCheckAt: json['next_check_at'] == null
          ? null
          : DateTime.parse(json['next_check_at'] as String),
      offlineReference: json['offline_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      treatments: rawTreatments
          .map(
            (dynamic item) =>
                HealthTreatment.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson({bool includeTreatments = false}) {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'animal_id': animalId,
      'ailment_id': ailmentId,
      'custom_diagnosis': customDiagnosis,
      'status': status.key,
      'severity': severity.key,
      'symptoms': <Map<String, dynamic>>[
        for (final HealthSymptom symptom in symptoms) symptom.toJson(),
      ],
      'notes': notes,
      'onset_date': onsetDate.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'next_check_at': nextCheckAt?.toIso8601String(),
      'offline_reference': offlineReference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (includeTreatments)
        'health_treatments': <Map<String, dynamic>>[
          for (final HealthTreatment treatment in treatments)
            treatment.toJson(),
        ],
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        animalId,
        ailmentId,
        customDiagnosis,
        status,
        severity,
        symptoms,
        notes,
        onsetDate,
        resolvedAt,
        nextCheckAt,
        offlineReference,
        createdAt,
        updatedAt,
        treatments,
      ];
}
