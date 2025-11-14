import 'package:equatable/equatable.dart';

class FarmMember extends Equatable {
  FarmMember({
    required this.id,
    required this.profileId,
    required this.email,
    this.planId,
    this.subscriptionId,
    this.memberProfileId,
    this.displayName,
    this.role = 'viewer',
    this.status = 'invited',
    this.invitedBy,
    required this.invitedAt,
    this.startAt,
    this.endAt,
    this.notes,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(metadata ?? const <String, dynamic>{}),
        );

  final String id;
  final String profileId;
  final String? planId;
  final String? subscriptionId;
  final String? memberProfileId;
  final String email;
  final String? displayName;
  final String role;
  final String status;
  final String? invitedBy;
  final DateTime invitedAt;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? notes;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == 'active';

  FarmMember copyWith({
    String? role,
    String? status,
    DateTime? startAt,
    DateTime? endAt,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return FarmMember(
      id: id,
      profileId: profileId,
      planId: planId,
      subscriptionId: subscriptionId,
      memberProfileId: memberProfileId,
      email: email,
      displayName: displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy,
      invitedAt: invitedAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FarmMember.fromJson(Map<String, dynamic> json) {
    final dynamic rawMetadata = json['metadata'];
    return FarmMember(
      id: json['id'] as String,
      profileId: json['profile_id'] as String? ?? '',
      planId: json['plan_id'] as String?,
      subscriptionId: json['subscription_id'] as String?,
      memberProfileId: json['member_profile_id'] as String?,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'invited',
      invitedBy: json['invited_by'] as String?,
      invitedAt: _parseDate(json['invited_at']),
      startAt: _parseDateOrNull(json['start_at']),
      endAt: _parseDateOrNull(json['end_at']),
      notes: json['notes'] as String?,
      metadata: rawMetadata is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawMetadata)
          : const <String, dynamic>{},
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'plan_id': planId,
      'subscription_id': subscriptionId,
      'member_profile_id': memberProfileId,
      'email': email,
      'display_name': displayName,
      'role': role,
      'status': status,
      'invited_by': invitedBy,
      'invited_at': invitedAt.toIso8601String(),
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toLocal();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _parseDateOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toLocal();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        planId,
        subscriptionId,
        memberProfileId,
        email,
        displayName,
        role,
        status,
        invitedBy,
        invitedAt,
        startAt,
        endAt,
        notes,
        metadata,
        createdAt,
        updatedAt,
      ];
}
