import 'package:equatable/equatable.dart';

class SupportRequest extends Equatable {
  const SupportRequest({
    required this.profileId,
    required this.subject,
    required this.message,
    required this.contactEmail,
    this.channel = 'app',
    this.priority = 'normal',
    required this.createdAt,
  });

  final String profileId;
  final String subject;
  final String message;
  final String contactEmail;
  final String channel;
  final String priority;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'profile_id': profileId,
      'subject': subject,
      'message': message,
      'contact_email': contactEmail,
      'channel': channel,
      'priority': priority,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      profileId: json['profile_id'] as String,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      channel: json['channel'] as String? ?? 'app',
      priority: json['priority'] as String? ?? 'normal',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        profileId,
        subject,
        message,
        contactEmail,
        channel,
        priority,
        createdAt,
      ];
}
