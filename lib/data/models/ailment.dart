import 'package:equatable/equatable.dart';

class HealthSymptom extends Equatable {
  const HealthSymptom({
    required this.code,
    required this.label,
    this.severity,
  });

  final String code;
  final String label;
  final String? severity;

  HealthSymptom copyWith({
    String? code,
    String? label,
    String? severity,
  }) {
    return HealthSymptom(
      code: code ?? this.code,
      label: label ?? this.label,
      severity: severity ?? this.severity,
    );
  }

  factory HealthSymptom.fromJson(Map<String, dynamic> json) {
    return HealthSymptom(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      severity: json['severity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'label': label,
      'severity': severity,
    };
  }

  @override
  List<Object?> get props => <Object?>[code, label, severity];
}

class TreatmentSuggestion extends Equatable {
  const TreatmentSuggestion({
    required this.name,
    this.description,
    this.defaultDurationDays,
    this.defaultDosage,
  });

  final String name;
  final String? description;
  final int? defaultDurationDays;
  final String? defaultDosage;

  TreatmentSuggestion copyWith({
    String? name,
    String? description,
    int? defaultDurationDays,
    String? defaultDosage,
  }) {
    return TreatmentSuggestion(
      name: name ?? this.name,
      description: description ?? this.description,
      defaultDurationDays:
          defaultDurationDays ?? this.defaultDurationDays,
      defaultDosage: defaultDosage ?? this.defaultDosage,
    );
  }

  factory TreatmentSuggestion.fromJson(Map<String, dynamic> json) {
    return TreatmentSuggestion(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      defaultDurationDays:
          (json['default_duration_days'] as num?)?.toInt(),
      defaultDosage: json['default_dosage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'default_duration_days': defaultDurationDays,
      'default_dosage': defaultDosage,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        name,
        description,
        defaultDurationDays,
        defaultDosage,
      ];
}

class Ailment extends Equatable {
  const Ailment({
    required this.id,
    required this.profileId,
    required this.name,
    this.slug,
    this.speciesId,
    this.symptoms = const <HealthSymptom>[],
    this.commonCauses,
    this.recommendedTreatments = const <TreatmentSuggestion>[],
    this.preventiveActions,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String profileId;
  final String name;
  final String? slug;
  final int? speciesId;
  final List<HealthSymptom> symptoms;
  final String? commonCauses;
  final List<TreatmentSuggestion> recommendedTreatments;
  final String? preventiveActions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  Ailment copyWith({
    String? id,
    String? profileId,
    String? name,
    String? slug,
    int? speciesId,
    List<HealthSymptom>? symptoms,
    String? commonCauses,
    List<TreatmentSuggestion>? recommendedTreatments,
    String? preventiveActions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return Ailment(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      speciesId: speciesId ?? this.speciesId,
      symptoms: symptoms ?? this.symptoms,
      commonCauses: commonCauses ?? this.commonCauses,
      recommendedTreatments:
          recommendedTreatments ?? this.recommendedTreatments,
      preventiveActions: preventiveActions ?? this.preventiveActions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  factory Ailment.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSymptoms =
        (json['symptoms'] as List<dynamic>? ?? <dynamic>[]);
    final List<dynamic> rawTreatments =
        (json['recommended_treatments'] as List<dynamic>? ??
            <dynamic>[]);
    return Ailment(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      speciesId: (json['species_id'] as num?)?.toInt(),
      symptoms: rawSymptoms
          .map((dynamic item) =>
              HealthSymptom.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      commonCauses: json['common_causes'] as String?,
      recommendedTreatments: rawTreatments
          .map(
            (dynamic item) =>
                TreatmentSuggestion.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      preventiveActions: json['preventive_actions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'name': name,
      'slug': slug,
      'species_id': speciesId,
      'symptoms': <Map<String, dynamic>>[
        for (final HealthSymptom symptom in symptoms) symptom.toJson(),
      ],
      'common_causes': commonCauses,
      'recommended_treatments': <Map<String, dynamic>>[
        for (final TreatmentSuggestion suggestion in recommendedTreatments)
          suggestion.toJson(),
      ],
      'preventive_actions': preventiveActions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        name,
        slug,
        speciesId,
        symptoms,
        commonCauses,
        recommendedTreatments,
        preventiveActions,
        createdAt,
        updatedAt,
        archivedAt,
      ];
}
