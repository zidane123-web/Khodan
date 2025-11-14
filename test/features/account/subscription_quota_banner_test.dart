import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/subscription_plan.dart';
import 'package:khodan/data/models/user_subscription.dart';
import 'package:khodan/features/account/presentation/cubit/subscription_cubit.dart';
import 'package:khodan/features/account/presentation/widgets/subscription_quota_banner.dart';

void main() {
  testWidgets('SubscriptionQuotaBanner displays alert when limit reached',
      (WidgetTester tester) async {
    final SubscriptionPlan plan = SubscriptionPlan(
      id: 'plan-free',
      code: 'free',
      label: 'Gratuit',
      monthlyPriceCents: 0,
      currency: 'XOF',
      maxBreeders: 5,
      maxMembers: 1,
      storageLimitMb: 100,
    );

    final UserSubscription subscription = UserSubscription(
      id: 'sub-1',
      profileId: 'profile-1',
      planId: plan.id,
      status: SubscriptionStatus.active,
      startAt: DateTime.now(),
      invoiceUrl: null,
      manualPaymentReference: null,
      paymentChannel: null,
      quotaBreedersUsed: 5,
      quotaMembersUsed: 1,
      quotaStorageUsedMb: 50,
      metadata: const <String, dynamic>{},
      plan: plan,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final SubscriptionState state = SubscriptionState(
      current: subscription,
      breedersUsed: 5,
      membersUsed: 1,
    );

    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SubscriptionQuotaBanner(
          state: state,
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(
      find.textContaining('Limite atteinte'),
      findsOneWidget,
    );

    await tester.tap(find.text('Changer de plan'));
    expect(tapped, isTrue);
  });
}
