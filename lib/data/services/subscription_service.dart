import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/farm_member.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import 'api_client.dart';
import 'notification_hooks.dart';

abstract class SubscriptionService {
  Future<List<SubscriptionPlan>> fetchPlans();

  Future<UserSubscription?> fetchCurrent(String profileId);

  Future<UserSubscription> bootstrapFreePlan(
    String profileId,
    SubscriptionPlan plan,
  );

  Future<UserSubscription> requestManualPlanChange({
    required String profileId,
    required SubscriptionPlan plan,
    Map<String, dynamic>? usageSnapshot,
  });

  Future<UserSubscription> updateUsage({
    required String profileId,
    int? breedersUsed,
    int? membersUsed,
    int? storageUsedMb,
  });

  Future<List<FarmMember>> fetchMembers(String profileId);

  Future<FarmMember> addMember({
    required String profileId,
    required String email,
    String? displayName,
    String role,
  });

  Future<void> removeMember(String memberId);
}

class SupabaseSubscriptionService implements SubscriptionService {
  SupabaseSubscriptionService({
    ApiExecutor? apiClient,
    List<NotificationHook>? notificationHooks,
    DateTime Function()? clock,
  })  : _api = apiClient ?? ApiClient(),
        _explicitHooks = notificationHooks,
        _clock = clock ?? DateTime.now;

  final ApiExecutor _api;
  final List<NotificationHook>? _explicitHooks;
  final DateTime Function() _clock;

  List<NotificationHook> get _hooks =>
      _explicitHooks ?? NotificationServiceRegistry.instance.hooks;

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      return client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('sort_order');
    }, label: 'subscriptions.plans');
    return rows
        .map((dynamic row) =>
            SubscriptionPlan.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<UserSubscription?> fetchCurrent(String profileId) async {
    final Map<String, dynamic>? row = await _api.run((SupabaseClient client) {
      return client
          .from('user_subscriptions')
          .select('*, plan:plan_id(*)')
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
    }, label: 'subscriptions.current');
    if (row == null) {
      return null;
    }
    return UserSubscription.fromJson(row);
  }

  @override
  Future<UserSubscription> bootstrapFreePlan(
    String profileId,
    SubscriptionPlan plan,
  ) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'profile_id': profileId,
      'plan_id': plan.id,
      'status': plan.isFree ? 'active' : 'trialing',
      'metadata': <String, dynamic>{
        'max_breeders_snapshot': plan.maxBreeders,
        'max_members_snapshot': plan.maxMembers,
        'storage_limit_snapshot': plan.storageLimitMb,
      },
    };
    final Map<String, dynamic> row = await _api.run((SupabaseClient client) {
      return client
          .from('user_subscriptions')
          .upsert(
            payload,
            onConflict: 'profile_id',
            ignoreDuplicates: false,
          )
          .select('*, plan:plan_id(*)')
          .single();
    }, label: 'subscriptions.bootstrap');
    return UserSubscription.fromJson(row);
  }

  @override
  Future<UserSubscription> requestManualPlanChange({
    required String profileId,
    required SubscriptionPlan plan,
    Map<String, dynamic>? usageSnapshot,
  }) async {
    final DateTime now = _clock().toUtc();
    final String reference =
        'PLAN-${plan.code.toUpperCase()}-${now.millisecondsSinceEpoch}';
    final Map<String, dynamic> metadata = <String, dynamic>{
      'max_breeders_snapshot': plan.maxBreeders,
      'max_members_snapshot': plan.maxMembers,
      'storage_limit_snapshot': plan.storageLimitMb,
      'payment': <String, dynamic>{
        'reference': reference,
        'method': 'manual_mobile_money',
      },
      if (usageSnapshot != null && usageSnapshot.isNotEmpty)
        'usage_snapshot': usageSnapshot,
    };

    final Map<String, dynamic> row = await _api.run((SupabaseClient client) {
      return client
          .from('user_subscriptions')
          .upsert(
            <String, dynamic>{
              'profile_id': profileId,
              'plan_id': plan.id,
              'status': 'pending_manual_payment',
              'manual_payment_reference': reference,
              'payment_channel': 'mobile_money',
              'metadata': metadata,
              'start_at': now.toIso8601String(),
              'end_at': null,
            },
            onConflict: 'profile_id',
            ignoreDuplicates: false,
          )
          .select('*, plan:plan_id(*)')
          .single();
    }, label: 'subscriptions.planchange');

    await _dispatchNotification(
      profileId: profileId,
      event: 'subscription.payment.requested',
      reference: reference,
      plan: plan,
    );

    return UserSubscription.fromJson(row);
  }

  @override
  Future<UserSubscription> updateUsage({
    required String profileId,
    int? breedersUsed,
    int? membersUsed,
    int? storageUsedMb,
  }) async {
    final Map<String, dynamic> updates = <String, dynamic>{};
    if (breedersUsed != null) {
      updates['quota_breeders_used'] = breedersUsed;
    }
    if (membersUsed != null) {
      updates['quota_members_used'] = membersUsed;
    }
    if (storageUsedMb != null) {
      updates['quota_storage_used_mb'] = storageUsedMb;
    }
    if (updates.isEmpty) {
      final UserSubscription? current = await fetchCurrent(profileId);
      if (current == null) {
        throw StateError('Aucun abonnement actif pour $profileId');
      }
      return current;
    }

    final Map<String, dynamic>? row = await _api.run((SupabaseClient client) {
      return client
          .from('user_subscriptions')
          .update(updates)
          .eq('profile_id', profileId)
          .select('*, plan:plan_id(*)')
          .maybeSingle();
    }, label: 'subscriptions.usage');

    if (row == null) {
      final UserSubscription? fallback = await fetchCurrent(profileId);
      if (fallback != null) {
        return fallback;
      }
      throw StateError('Aucun abonnement actif pour $profileId');
    }

    return UserSubscription.fromJson(row);
  }

  @override
  Future<List<FarmMember>> fetchMembers(String profileId) async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      return client
          .from('farm_members')
          .select()
          .eq('profile_id', profileId)
          .order('created_at');
    }, label: 'subscriptions.members');
    return rows
        .map((dynamic row) =>
            FarmMember.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<FarmMember> addMember({
    required String profileId,
    required String email,
    String? displayName,
    String role = 'viewer',
  }) async {
    final Map<String, dynamic> row = await _api.run((SupabaseClient client) {
      return client
          .from('farm_members')
          .insert(<String, dynamic>{
            'profile_id': profileId,
            'email': email,
            'display_name': displayName,
            'role': role,
            'status': 'invited',
            'invited_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select()
          .single();
    }, label: 'subscriptions.members.add');
    return FarmMember.fromJson(row);
  }

  @override
  Future<void> removeMember(String memberId) async {
    await _api.run((SupabaseClient client) {
      return client
          .from('farm_members')
          .update(<String, dynamic>{
            'status': 'removed',
            'end_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', memberId)
          .select('id')
          .maybeSingle();
    }, label: 'subscriptions.members.remove');
  }

  Future<void> _dispatchNotification({
    required String profileId,
    required String event,
    required String reference,
    required SubscriptionPlan plan,
  }) async {
    if (_hooks.isEmpty) {
      return;
    }
    final NotificationPayload payload = NotificationPayload(
      taskId: 'subscription:$reference',
      triggerAt: DateTime.now(),
      profileId: profileId,
      title: 'Nouveau paiement requis',
      body: 'Plan ${plan.label} - référence $reference',
      metadata: <String, dynamic>{
        'event': event,
        'plan_code': plan.code,
        'reference': reference,
      },
    );
    for (final NotificationHook hook in _hooks) {
      try {
        await hook.dispatch(payload);
      } catch (_) {
        // Hooks best-effort.
      }
    }
  }
}

class InMemorySubscriptionService implements SubscriptionService {
  InMemorySubscriptionService()
      : _plans = <SubscriptionPlan>[
          SubscriptionPlan(
            id: 'plan-free',
            code: 'free',
            label: 'Gratuit',
            monthlyPriceCents: 0,
            currency: 'XOF',
            maxBreeders: 5,
            maxMembers: 1,
            storageLimitMb: 100,
            modules: <String>['dashboard', 'animals'],
          ),
          SubscriptionPlan(
            id: 'plan-standard',
            code: 'standard',
            label: 'Standard',
            monthlyPriceCents: 9900,
            currency: 'XOF',
            maxBreeders: 50,
            maxMembers: 3,
            storageLimitMb: 2048,
            modules: <String>['dashboard', 'animals', 'litters'],
          ),
        ];

  final List<SubscriptionPlan> _plans;
  final Map<String, UserSubscription> _subscriptions =
      <String, UserSubscription>{};
  final Map<String, List<FarmMember>> _membersByProfile =
      <String, List<FarmMember>>{};

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async => _plans;

  @override
  Future<UserSubscription?> fetchCurrent(String profileId) async {
    return _subscriptions[profileId];
  }

  @override
  Future<UserSubscription> bootstrapFreePlan(
    String profileId,
    SubscriptionPlan plan,
  ) async {
    final UserSubscription subscription = UserSubscription(
      id: 'sub-$profileId',
      profileId: profileId,
      planId: plan.id,
      status: SubscriptionStatus.active,
      startAt: DateTime.now(),
      endAt: null,
      renewalAt: null,
      invoiceUrl: null,
      manualPaymentReference: null,
      paymentChannel: null,
      quotaBreedersUsed: 0,
      quotaMembersUsed: 0,
      quotaStorageUsedMb: 0,
      metadata: <String, dynamic>{
        'max_breeders_snapshot': plan.maxBreeders,
        'max_members_snapshot': plan.maxMembers,
        'storage_limit_snapshot': plan.storageLimitMb,
      },
      plan: plan,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _subscriptions[profileId] = subscription;
    return subscription;
  }

  @override
  Future<UserSubscription> requestManualPlanChange({
    required String profileId,
    required SubscriptionPlan plan,
    Map<String, dynamic>? usageSnapshot,
  }) async {
    final UserSubscription subscription = UserSubscription(
      id: 'sub-$profileId',
      profileId: profileId,
      planId: plan.id,
      status: SubscriptionStatus.pendingManualPayment,
      startAt: DateTime.now(),
      endAt: null,
      renewalAt: null,
      invoiceUrl: null,
      manualPaymentReference: 'PLAN-${plan.code}-${DateTime.now().millisecondsSinceEpoch}',
      paymentChannel: 'mobile_money',
      quotaBreedersUsed:
          _subscriptions[profileId]?.quotaBreedersUsed ?? 0,
      quotaMembersUsed: _subscriptions[profileId]?.quotaMembersUsed ?? 0,
      quotaStorageUsedMb:
          _subscriptions[profileId]?.quotaStorageUsedMb ?? 0,
      metadata: <String, dynamic>{
        'max_breeders_snapshot': plan.maxBreeders,
        'max_members_snapshot': plan.maxMembers,
        'storage_limit_snapshot': plan.storageLimitMb,
        if (usageSnapshot != null) 'usage_snapshot': usageSnapshot,
      },
      plan: plan,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _subscriptions[profileId] = subscription;
    return subscription;
  }

  @override
  Future<UserSubscription> updateUsage({
    required String profileId,
    int? breedersUsed,
    int? membersUsed,
    int? storageUsedMb,
  }) async {
    final UserSubscription? current = _subscriptions[profileId];
    if (current == null) {
      throw StateError('Aucun abonnement actif pour $profileId');
    }
    final UserSubscription updated = current.copyWith(
      quotaBreedersUsed: breedersUsed ?? current.quotaBreedersUsed,
      quotaMembersUsed: membersUsed ?? current.quotaMembersUsed,
      quotaStorageUsedMb: storageUsedMb ?? current.quotaStorageUsedMb,
      updatedAt: DateTime.now(),
    );
    _subscriptions[profileId] = updated;
    return updated;
  }

  @override
  Future<List<FarmMember>> fetchMembers(String profileId) async {
    return _membersByProfile[profileId] ?? const <FarmMember>[];
  }

  @override
  Future<FarmMember> addMember({
    required String profileId,
    required String email,
    String? displayName,
    String role = 'viewer',
  }) async {
    final FarmMember member = FarmMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      profileId: profileId,
      planId: _subscriptions[profileId]?.planId,
      subscriptionId: _subscriptions[profileId]?.id,
      memberProfileId: null,
      email: email,
      displayName: displayName,
      role: role,
      status: 'invited',
      invitedBy: profileId,
      invitedAt: DateTime.now(),
      startAt: null,
      endAt: null,
      notes: null,
      metadata: const <String, dynamic>{},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final List<FarmMember> members =
        _membersByProfile.putIfAbsent(profileId, () => <FarmMember>[]);
    members.add(member);
    return member;
  }

  @override
  Future<void> removeMember(String memberId) async {
    for (final List<FarmMember> members in _membersByProfile.values) {
      final int index = members.indexWhere((FarmMember m) => m.id == memberId);
      if (index != -1) {
        members[index] = members[index].copyWith(
          status: 'removed',
          endAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return;
      }
    }
  }
}
