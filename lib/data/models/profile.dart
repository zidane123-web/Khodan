import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  Profile({
    required this.id,
    required this.email,
    required this.farmName,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.locale,
    this.timeZone,
    this.farmLocation,
    Map<String, dynamic>? legalPreferences,
    this.billingStatus,
  }) : legalPreferences = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(
            legalPreferences ?? const <String, dynamic>{},
          ),
        );

  final String id;
  final String email;
  final String farmName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phone;
  final String? locale;
  final String? timeZone;
  final String? farmLocation;
  final Map<String, dynamic> legalPreferences;
  final String? billingStatus;

  bool get hasAcceptedTerms =>
      (legalPreferences['termsAccepted'] as bool?) ?? false;

  bool get hasAcceptedPrivacy =>
      (legalPreferences['privacyAccepted'] as bool?) ?? false;

  bool get marketingOptIn =>
      (legalPreferences['marketingOptIn'] as bool?) ?? false;

  Profile copyWith({
    String? id,
    String? email,
    String? farmName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? locale,
    String? timeZone,
    String? farmLocation,
    Map<String, dynamic>? legalPreferences,
    String? billingStatus,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      farmName: farmName ?? this.farmName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      locale: locale ?? this.locale,
      timeZone: timeZone ?? this.timeZone,
      farmLocation: farmLocation ?? this.farmLocation,
      legalPreferences: legalPreferences ?? this.legalPreferences,
      billingStatus: billingStatus ?? this.billingStatus,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final dynamic rawLegal = json['legal_preferences'];
    final Map<String, dynamic> legal = rawLegal is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawLegal)
        : const <String, dynamic>{};
    final String createdAtRaw = json['created_at'] as String? ?? '';
    final String? updatedAtRaw = json['updated_at'] as String?;
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      phone: json['phone'] as String?,
      locale: json['locale'] as String?,
      timeZone: json['time_zone'] as String?,
      farmLocation: json['farm_location'] as String?,
      legalPreferences: legal,
      billingStatus: json['billing_status'] as String?,
      createdAt: createdAtRaw.isEmpty
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(createdAtRaw),
      updatedAt: updatedAtRaw == null || updatedAtRaw.isEmpty
          ? (createdAtRaw.isEmpty
              ? DateTime.fromMillisecondsSinceEpoch(0)
              : DateTime.parse(createdAtRaw))
          : DateTime.parse(updatedAtRaw),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': id,
      'email': email,
      'farm_name': farmName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (phone != null) {
      json['phone'] = phone;
    }
    if (locale != null) {
      json['locale'] = locale;
    }
    if (timeZone != null) {
      json['time_zone'] = timeZone;
    }
    if (farmLocation != null) {
      json['farm_location'] = farmLocation;
    }
    if (legalPreferences.isNotEmpty) {
      json['legal_preferences'] = legalPreferences;
    }
    if (billingStatus != null) {
      json['billing_status'] = billingStatus;
    }
    return json;
  }

  Map<String, dynamic> toUpdatePayload() {
    final Map<String, dynamic> payload = <String, dynamic>{
      'farm_name': farmName,
      'updated_at': DateTime.now().toIso8601String(),
    };
    payload['phone'] = phone;
    payload['locale'] = locale;
    payload['time_zone'] = timeZone;
    payload['farm_location'] = farmLocation;
    payload['legal_preferences'] = legalPreferences;
    payload['billing_status'] = billingStatus;
    return payload;
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        email,
        farmName,
        createdAt,
        updatedAt,
        phone,
        locale,
        timeZone,
        farmLocation,
        legalPreferences,
        billingStatus,
      ];
}
