import 'package:equatable/equatable.dart';

class EventTemplate extends Equatable {
  const EventTemplate({
    required this.id,
    required this.userId,
    required this.templateName,
    required this.eventType,
    this.defaultDetails = const <String, dynamic>{},
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final int id;
  final String userId;
  final String templateName;
  final String eventType;
  final Map<String, dynamic> defaultDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventTemplate copyWith({
    int? id,
    String? userId,
    String? templateName,
    String? eventType,
    Map<String, dynamic>? defaultDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      templateName: templateName ?? this.templateName,
      eventType: eventType ?? this.eventType,
      defaultDetails: defaultDetails ?? this.defaultDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory EventTemplate.fromJson(Map<String, dynamic> json) {
    return EventTemplate(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      templateName: json['template_name'] as String,
      eventType: json['event_type'] as String,
      defaultDetails: json['default_details'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(
              json['default_details'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(
        (json['updated_at'] as String?) ?? json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'template_name': templateName,
      'event_type': eventType,
      'default_details': defaultDetails,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        templateName,
        eventType,
        defaultDetails,
        createdAt,
        updatedAt,
      ];
}
