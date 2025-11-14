import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/subscription_plan.dart';
import 'package:khodan/data/models/user_subscription.dart';
import 'package:khodan/data/services/subscription_service.dart';

void main() {
  group('InMemorySubscriptionService', () {
    late InMemorySubscriptionService service;
    late SubscriptionPlan defaultPlan;

    setUp(() async {
      service = InMemorySubscriptionService();
      defaultPlan = (await service.fetchPlans()).first;
      await service.bootstrapFreePlan('profile-1', defaultPlan);
    });

    test('requestManualPlanChange flags subscription as pending manual payment',
        () async {
      final SubscriptionPlan targetPlan = (await service.fetchPlans()).last;
      final UserSubscription updated = await service.requestManualPlanChange(
        profileId: 'profile-1',
        plan: targetPlan,
        usageSnapshot: const <String, dynamic>{'breeders_used': 5},
      );

      expect(updated.status, SubscriptionStatus.pendingManualPayment);
      expect(updated.manualPaymentReference, isNotEmpty);
      expect(updated.plan?.code, equals(targetPlan.code));
    });

    test('updateUsage synchronizes counters', () async {
      final UserSubscription result = await service.updateUsage(
        profileId: 'profile-1',
        breedersUsed: 3,
        membersUsed: 1,
        storageUsedMb: 120,
      );

      expect(result.quotaBreedersUsed, equals(3));
      expect(result.quotaMembersUsed, equals(1));
      expect(result.quotaStorageUsedMb, equals(120));
    });
  });
}

