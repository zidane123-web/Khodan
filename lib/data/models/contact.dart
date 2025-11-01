import 'package:equatable/equatable.dart';

enum ContactType {
  breeder('breeder'),
  supplier('supplier'),
  client('client'),
  staff('staff'),
  other('other');

  const ContactType(this.key);

  final String key;

  static ContactType fromKey(String value) {
    return ContactType.values.firstWhere(
      (ContactType type) => type.key == value,
      orElse: () => ContactType.other,
    );
  }
}

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.profileId,
    required this.displayName,
    required this.type,
    this.email,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    final String typeRaw = (json['type'] ?? 'other') as String;
    return Contact(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      type: ContactType.fromKey(typeRaw),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  final String id;
  final String profileId;
  final String displayName;
  final ContactType type;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact copyWith({
    String? id,
    String? profileId,
    String? displayName,
    ContactType? type,
    String? email,
    String? phone,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'display_name': displayName,
      'type': type.key,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertPayload() {
    return <String, dynamic>{
      'profile_id': profileId,
      'display_name': displayName,
      'type': type.key,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return <String, dynamic>{
      'display_name': displayName,
      'type': type.key,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }

  static Contact empty(String profileId) {
    final DateTime now = DateTime.now();
    return Contact(
      id: '',
      profileId: profileId,
      displayName: '',
      type: ContactType.other,
      email: null,
      phone: null,
      address: null,
      notes: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  static DateTime _parseDate(dynamic input) {
    if (input is DateTime) {
      return input;
    }
    if (input is String && input.isNotEmpty) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        profileId,
        displayName,
        type,
        email,
        phone,
        address,
        notes,
        createdAt,
        updatedAt,
      ];
}
