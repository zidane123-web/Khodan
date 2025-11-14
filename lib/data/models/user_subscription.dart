import 'package:equatable/equatable.dart';

import 'subscription_plan.dart';

enum SubscriptionStatus {
  trialing,
  active,
  pastDue,
  grace,
  cancelled,
  expired,
  pendingManualPayment,
  pendingStripe,
}

extension SubscriptionStatusX on SubscriptionStatus {
  String get key {
    switch (this) {
      case SubscriptionStatus.trialing:
        return 'trialing';
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.pastDue:
        return 'past_due';
      case SubscriptionStatus.grace:
        return 'grace';
      case SubscriptionStatus.cancelled:
        return 'cancelled';
      case SubscriptionStatus.expired:
        return 'expired';
      case SubscriptionStatus.pendingManualPayment:
        return 'pending_manual_payment';
      case SubscriptionStatus.pendingStripe:
        return 'pending_stripe';
    }
  }

  bool get isActive =>
      this == SubscriptionStatus.active ||
      this == SubscriptionStatus.trialing ||
      this == SubscriptionStatus.grace;

  static SubscriptionStatus fromKey(String? value) {
    switch (value) {
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'grace':
        return SubscriptionStatus.grace;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'pending_manual_payment':
        return SubscriptionStatus.pendingManualPayment;
      case 'pending_stripe':
        return SubscriptionStatus.pendingStripe;
      case 'trialing':
      default:
        return SubscriptionStatus.trialing;
    }
  }
}

class UserSubscription extends Equatable {
  UserSubscription({
    required this.id,
    required this.profileId,
    required this.planId,
    required this.status,
    required this.startAt,
    this.endAt,
    this.renewalAt,
    this.invoiceUrl,
    this.manualPaymentReference,
    this.paymentChannel,
    required this.quotaBreedersUsed,
    required this.quotaMembersUsed,
    required this.quotaStorageUsedMb,
    Map<String, dynamic>? metadata,
    this.plan,
    required this.createdAt,
    required this.updatedAt,
  }) : metadata = Map<String, dynamic>.unmodifiable(
          Map<String, dynamic>.from(metadata ?? const <String, dynamic>{}),
        );

  final String id;
  final String profileId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startAt;
  final DateTime? endAt;
  final DateTime? renewalAt;
  final String? invoiceUrl;
  final String? manualPaymentReference;
  final String? paymentChannel;
  final int quotaBreedersUsed;
  final int quotaMembersUsed;
  final int quotaStorageUsedMb;
  final Map<String, dynamic> metadata;
  final SubscriptionPlan? plan;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status.isActive;

  bool get requiresAttention =>
      status == SubscriptionStatus.pastDue ||
      status == SubscriptionStatus.pendingManualPayment ||
      status == SubscriptionStatus.pendingStripe;

  int? get maxBreeders => plan?.maxBreeders ?? _metadataInt('max_breeders_snapshot');

  int? get maxMembers => plan?.maxMembers ?? _metadataInt('max_members_snapshot');

  int? get storageLimitMb =>
      plan?.storageLimitMb ?? _metadataInt('storage_limit_snapshot');

  UserSubscription copyWith({
    SubscriptionStatus? status,
    SubscriptionPlan? plan,
    bool clearPlan = false,
    int? quotaBreedersUsed,
    int? quotaMembersUsed,
    int? quotaStorageUsedMb,
    String? manualPaymentReference,
    String? paymentChannel,
    String? invoiceUrl,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      id: id,
      profileId: profileId,
      planId: planId,
      status: status ?? this.status,
      startAt: startAt,
      endAt: endAt,
      renewalAt: renewalAt,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      manualPaymentReference:
          manualPaymentReference ?? this.manualPaymentReference,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      quotaBreedersUsed: quotaBreedersUsed ?? this.quotaBreedersUsed,
      quotaMembersUsed: quotaMembersUsed ?? this.quotaMembersUsed,
      quotaStorageUsedMb: quotaStorageUsedMb ?? this.quotaStorageUsedMb,
      metadata: metadata ?? this.metadata,
      plan: clearPlan ? null : (plan ?? this.plan),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    final dynamic rawMetadata = json['metadata'];
    return UserSubscription(
      id: json['id'] as String,
      profileId: json['profile_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      status: SubscriptionStatusX.fromKey(json['status'] as String?),
      startAt: _parseDate(json['start_at']),
      endAt: _parseDateOrNull(json['end_at']),
      renewalAt: _parseDateOrNull(json['renewal_at']),
      invoiceUrl: json['invoice_url'] as String?,
      manualPaymentReference: json['manual_payment_reference'] as String?,
      paymentChannel: json['payment_channel'] as String?,
      quotaBreedersUsed: (json['quota_breeders_used'] as num?)?.toInt() ?? 0,
      quotaMembersUsed: (json['quota_members_used'] as num?)?.toInt() ?? 0,
      quotaStorageUsedMb:
          (json['quota_storage_used_mb'] as num?)?.toInt() ?? 0,
      metadata: rawMetadata is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawMetadata)
          : const <String, dynamic>{},
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(
              json['plan'] as Map<String, dynamic>,
            )
          : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'profile_id': profileId,
      'plan_id': planId,
      'status': status.key,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'renewal_at': renewalAt?.toIso8601String(),
      'invoice_url': invoiceUrl,
      'manual_payment_reference': manualPaymentReference,
      'payment_channel': paymentChannel,
      'quota_breeders_used': quotaBreedersUsed,
      'quota_members_used': quotaMembersUsed,
      'quota_storage_used_mb': quotaStorageUsedMb,
      'metadata': metadata,
      'plan': plan?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int? _metadataInt(String key) {
    final Object? value = metadata[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
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
        status,
        startAt,
        endAt,
        renewalAt,
        invoiceUrl,
        manualPaymentReference,
        paymentChannel,
        quotaBreedersUsed,
        quotaMembersUsed,
        quotaStorageUsedMb,
        metadata,
        plan,
        createdAt,
        updatedAt,
      ];
}
