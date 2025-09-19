import 'package:flutter/material.dart';

import '../cubit/animal_detail_cubit.dart';

class AnimalPerformanceOverview extends StatelessWidget {
  const AnimalPerformanceOverview({
    required this.performance,
    super.key,
  });

  final AnimalPerformanceStats performance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDoe = performance.role == AnimalReproductiveRole.doe;
    final bool isBuck = performance.role == AnimalReproductiveRole.buck;
    final String title = isDoe
        ? 'Performances de la femelle'
        : isBuck
            ? 'Performances du mâle'
            : 'Performances';

    final List<_PerformanceMetric> metrics = <_PerformanceMetric>[
      _PerformanceMetric(
        label: 'Saillies réalisées',
        value: performance.totalMatings.toString(),
      ),
      _PerformanceMetric(
        label: isDoe ? 'Saillies positives' : 'Saillies réussies',
        value: performance.successfulMatings.toString(),
      ),
      _PerformanceMetric(
        label: 'Taux de réussite',
        value: performance.successRate == null
            ? '--'
            : '${(performance.successRate! * 100).toStringAsFixed(0)}%',
      ),
      _PerformanceMetric(
        label: isDoe ? 'Portées mises bas' : 'Portées issues',
        value: performance.littersCount.toString(),
      ),
    ];

    if (isDoe) {
      metrics
        ..add(
          _PerformanceMetric(
            label: 'Moy. nés vivants',
            value: _formatAverage(performance.averageKitsBornAlive),
          ),
        )
        ..add(
          _PerformanceMetric(
            label: 'Moy. sevrés',
            value: _formatAverage(performance.averageKitsWeaned),
          ),
        )
        ..add(
          _PerformanceMetric(
            label: 'Lapereaux sevrés',
            value: performance.totalKitsWeaned.toString(),
          ),
        );
    } else if (isBuck) {
      metrics.add(
        _PerformanceMetric(
          label: 'Lapereaux sevrés',
          value: performance.totalKitsWeaned.toString(),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...metrics.map(
              (_PerformanceMetric metric) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(metric.label,
                          style: theme.textTheme.bodyMedium),
                    ),
                    const SizedBox(width: 12),
                    Text(metric.value, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
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

class _PerformanceMetric {
  const _PerformanceMetric({required this.label, required this.value});

  final String label;
  final String value;
}
