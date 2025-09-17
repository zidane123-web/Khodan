import 'package:equatable/equatable.dart';

class AnimalEventLink extends Equatable {
  const AnimalEventLink({
    required this.eventId,
    required this.animalId,
    required this.role,
  });

  final String eventId;
  final String animalId;
  final String role;

  AnimalEventLink copyWith({
    String? eventId,
    String? animalId,
    String? role,
  }) {
    return AnimalEventLink(
      eventId: eventId ?? this.eventId,
      animalId: animalId ?? this.animalId,
      role: role ?? this.role,
    );
  }

  factory AnimalEventLink.fromJson(Map<String, dynamic> json) {
    return AnimalEventLink(
      eventId: json['event_id'] as String,
      animalId: json['animal_id'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'event_id': eventId,
      'animal_id': animalId,
      'role': role,
    };
  }

  @override
  List<Object> get props => <Object>[eventId, animalId, role];
}
