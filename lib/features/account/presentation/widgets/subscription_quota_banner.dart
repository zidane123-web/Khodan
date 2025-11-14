import 'package:flutter/material.dart';

import '../cubit/subscription_cubit.dart';

class SubscriptionQuotaBanner extends StatelessWidget {
  const SubscriptionQuotaBanner({
    super.key,
    required this.state,
    this.onAction,
  });

  final SubscriptionState state;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool limitReached = state.breedersLimitReached || state.membersLimitReached;
    final String headline;
    if (state.breedersLimitReached) {
      headline = 'Limite atteinte : ${state.breedersUsed}/${state.maxBreeders} éleveurs actifs.';
    } else if (state.membersLimitReached) {
      headline = 'Limite équipe atteinte : ${state.membersUsed}/${state.maxMembers} membres.';
    } else {
      headline = 'Abonnement à surveiller.';
    }

    final List<Widget> subtitleLines = <Widget>[];
    final Color subtitleColor = limitReached
        ? colors.onErrorContainer
        : colors.onSecondaryContainer;

    if (state.hasPendingPayment && state.current?.manualPaymentReference != null) {
      subtitleLines.add(
        Text(
          'Paiement en attente (référence ${state.current!.manualPaymentReference}).',
          style: TextStyle(color: subtitleColor),
        ),
      );
    } else if (!limitReached && state.current?.requiresAttention == true) {
      subtitleLines.add(
        Text(
          'Votre dernier paiement doit être confirmé pour garder l’accès complet.',
          style: TextStyle(color: subtitleColor),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: limitReached ? colors.errorContainer : colors.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              limitReached ? Icons.warning_amber_rounded : Icons.info_outline,
              color: limitReached
                  ? colors.onErrorContainer
                  : colors.onSecondaryContainer,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    headline,
                    style: TextStyle(
                      color: limitReached
                          ? colors.onErrorContainer
                          : colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleLines.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    ...subtitleLines,
                  ],
                ],
              ),
            ),
            if (onAction != null)
              TextButton(
                onPressed: onAction,
                child: const Text('Changer de plan'),
              ),
          ],
        ),
      ),
    );
  }
}
