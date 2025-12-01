import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/theme.dart';
import '../mvp_demo_controller.dart';

class MvpFinancesScreen extends StatelessWidget {
  const MvpFinancesScreen({super.key});

  String _formatAmount(double amount, bool isExpense) {
    final String formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return isExpense ? '-$formatted FCFA' : '+$formatted FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    final MvpDemoController store = MvpDemoScope.of(context);
    final bool positive = store.monthlyProfit >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bénéfice du mois',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${positive ? '+' : '-'}${store.monthlyProfit.abs().toStringAsFixed(0)} FCFA',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: positive
                                ? colors?.success ?? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          positive ? Icons.trending_up : Icons.trending_down,
                          color: positive
                              ? colors?.success ?? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Détails ci-dessous',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...store.transactions.map(
              (MvpTransaction tx) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (tx.isExpense
                            ? theme.colorScheme.error
                            : colors?.success ?? theme.colorScheme.primary)
                        .withOpacity(0.12),
                    child: Icon(
                      tx.isExpense ? Icons.trending_down : Icons.trending_up,
                      color: tx.isExpense
                          ? theme.colorScheme.error
                          : colors?.success ?? theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(tx.label),
                  subtitle: Text(
                    '${tx.type} • ${tx.date.day}/${tx.date.month}',
                  ),
                  trailing: Text(
                    _formatAmount(tx.amount, tx.isExpense),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tx.isExpense
                          ? theme.colorScheme.error
                          : colors?.success ?? theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export PDF lancé (simulation).'),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
