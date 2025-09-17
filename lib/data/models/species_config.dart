import 'package:equatable/equatable.dart';

class SpeciesConfig extends Equatable {
  const SpeciesConfig({
    required this.id,
    required this.profileId,
    required this.speciesName,
    required this.gestationDays,
    required this.weaningDays,
    required this.eventsSchema,
  });

  final int id;
  final String profileId;
  final String speciesName;
  final int gestationDays;
  final int weaningDays;
  final List<String> eventsSchema;

  SpeciesConfig copyWith({
    int? id,
    String? profileId,
    String? speciesName,
    int? gestationDays,
    int? weaningDays,
    List<String>? eventsSchema,
  }) {
    return SpeciesConfig(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      speciesName: speciesName ?? this.speciesName,
      gestationDays: gestationDays ?? this.gestationDays,
      weaningDays: weaningDays ?? this.weaningDays,
      eventsSchema: eventsSchema ?? this.eventsSchema,
    );
  }

  factory SpeciesConfig.fromJson(Map<String, dynamic> json) {
    return SpeciesConfig(
      id: json['id'] as int,
      profileId: json['profile_id'] as String,
      speciesName: json['species_name'] as String,
      gestationDays: json['gestation_days'] as int,
      weaningDays: json['weaning_days'] as int,
      eventsSchema: List<String>.from(json['events_schema'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'species_name': speciesName,
      'gestation_days': gestationDays,
      'weaning_days': weaningDays,
      'events_schema': eventsSchema,
    };
  }

  @override
  List<Object> get props => <Object>[
        id,
        profileId,
        speciesName,
        gestationDays,
        weaningDays,
        eventsSchema,
      ];
}
