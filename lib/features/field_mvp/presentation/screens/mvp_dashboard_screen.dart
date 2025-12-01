import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/theme.dart';
import '../mvp_demo_controller.dart';

class MvpDashboardScreen extends StatelessWidget {
  const MvpDashboardScreen({super.key});

  Color _urgencyColor(TaskUrgency urgency, ThemeData theme) {
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    switch (urgency) {
      case TaskUrgency.urgent:
        return theme.colorScheme.error;
      case TaskUrgency.today:
        return colors?.info ?? theme.colorScheme.tertiary;
      case TaskUrgency.tomorrow:
        return colors?.success ?? theme.colorScheme.primary;
      case TaskUrgency.reminder:
        return colors?.warning ?? theme.colorScheme.secondary;
    }
  }

  String _urgencyLabel(TaskUrgency urgency) {
    switch (urgency) {
      case TaskUrgency.urgent:
        return 'Urgent';
      case TaskUrgency.today:
        return 'Aujourd’hui';
      case TaskUrgency.tomorrow:
        return 'Demain';
      case TaskUrgency.reminder:
        return 'Rappel';
    }
  }

  List<FlSpot> _buildMonthlySeries(
    List<MvpTransaction> transactions, {
    required bool expenses,
  }) {
    final DateTime now = DateTime.now();
    final Map<int, double> totalsByDay = <int, double>{};
    for (final MvpTransaction tx in transactions) {
      if (tx.date.month != now.month || tx.date.year != now.year) {
        continue;
      }
      if (tx.isExpense != expenses) {
        continue;
      }
      totalsByDay.update(tx.date.day, (double value) => value + tx.amount,
          ifAbsent: () => tx.amount);
    }

    if (totalsByDay.isEmpty) {
      return <FlSpot>[
        const FlSpot(1, 0),
        FlSpot(now.day.toDouble(), 0),
      ];
    }

    final List<int> days = totalsByDay.keys.toList()..sort();
    return days
        .map((int day) => FlSpot(day.toDouble(), totalsByDay[day]!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MvpDemoController store = MvpDemoScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: <Widget>[
            Text(
              'Ma journée',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _SummaryCard(
                  label: 'Total lapins',
                  value: store.totalRabbits.toString(),
                  icon: Icons.pets,
                  color: theme.colorScheme.primary,
                ),
                _SummaryCard(
                  label: 'À l’engraissement',
                  value: store.growOutCount.toString(),
                  icon: Icons.grass,
                  color: theme.colorScheme.secondary,
                ),
                _SummaryCard(
                  label: 'Reproducteurs',
                  value:
                      '${store.breederCount} (${store.maleBreeders} M / ${store.femaleBreeders} F)',
                  icon: Icons.favorite,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'À faire',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final MvpTask task = store.tasks[index];
                  final Color color = _urgencyColor(task.urgency, theme);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(
                        task.urgency == TaskUrgency.urgent
                            ? Icons.error
                            : Icons.event_available,
                        color: color,
                      ),
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      '${_urgencyLabel(task.urgency)} • ${task.detail}',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.outline,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemCount: store.tasks.length,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dépenses vs Revenus (mois en cours)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _FinanceChart(
              incomeSpots: _buildMonthlySeries(
                store.transactions,
                expenses: false,
              ),
              expenseSpots: _buildMonthlySeries(
                store.transactions,
                expenses: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(value, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceChart extends StatelessWidget {
  const _FinanceChart({
    required this.incomeSpots,
    required this.expenseSpots,
  });

  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    return Card(
      child: SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: theme.colorScheme.surface,
                  fitInsideHorizontally: true,
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: incomeSpots,
                  color: colors?.success ?? theme.colorScheme.primary,
                  barWidth: 3,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: expenseSpots,
                  color: theme.colorScheme.error,
                  barWidth: 3,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
