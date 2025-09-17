import 'package:equatable/equatable.dart';

class LivestockEvent extends Equatable {
  const LivestockEvent({
    required this.id,
    required this.profileId,
    required this.eventType,
    required this.eventDate,
    required this.details,
    this.notes,
  });

  final String id;
  final String profileId;
  final String eventType;
  final DateTime eventDate;
  final Map<String, dynamic> details;
  final String? notes;

  LivestockEvent copyWith({
    String? id,
    String? profileId,
    String? eventType,
    DateTime? eventDate,
    Map<String, dynamic>? details,
    String? notes,
  }) {
    return LivestockEvent(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      details: details ?? this.details,
      notes: notes ?? this.notes,
    );
  }

  factory LivestockEvent.fromJson(Map<String, dynamic> json) {
    return LivestockEvent(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      eventType: json['event_type'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      details: Map<String, dynamic>.from(
        (json['details'] as Map?) ?? <String, dynamic>{},
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'details': details,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        eventType,
        eventDate,
        details,
        notes,
      ];
}
