import 'package:flutter/material.dart';

import '../../domain/models/breeding_performance_stats.dart';

class BreedingPerformanceCard extends StatelessWidget {
  const BreedingPerformanceCard({
    required this.stats,
    super.key,
  });

  final BreedingPerformanceStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Performances des reproducteurs',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _StatRow(
              label: 'Portées enregistrées',
              value: stats.totalLitters.toString(),
            ),
            _StatRow(
              label: 'Moy. nés vivants',
              value: _formatAverage(stats.averageKitsBornAlive),
            ),
            _StatRow(
              label: 'Moy. sevrés',
              value: _formatAverage(stats.averageKitsWeaned),
            ),
            _StatRow(
              label: 'Lapereaux sevrés',
              value: stats.totalKitsWeaned.toString(),
            ),
            if (stats.topDoeLabel != null) ...<Widget>[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Femelle la plus performante',
                value: stats.topDoeLabel!,
              ),
            ],
            if (stats.topBuckLabel != null) ...<Widget>[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Mâle le plus performant',
                value: stats.topBuckLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAverage(double? value) {
    if (value == null) {
      return '--';
    }
    return value.toStringAsFixed(1);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
