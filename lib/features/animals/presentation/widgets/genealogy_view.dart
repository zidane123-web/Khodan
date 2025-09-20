import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../domain/genealogy_analyzer.dart';

class GenealogyView extends StatelessWidget {
  const GenealogyView({
    required this.animal,
    this.analysis,
    super.key,
  });

  final Animal animal;
  final GenealogyAnalysis? analysis;

  static const List<String> _generationLabels = <String>[
    'Parents',
    'Grands-parents',
    'Arrière-grands-parents',
  ];

  String _ancestorLabel(Animal? ancestor) {
    if (ancestor == null) {
      return 'Inconnu';
    }
    if (ancestor.name != null && ancestor.name!.isNotEmpty) {
      return '${ancestor.tagId} · ${ancestor.name}';
    }
    return ancestor.tagId;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? coefficient = analysis?.inbreedingCoefficient;
    final Map<String, int> occurrences = analysis?.ancestorOccurrences ??
        <String, int>{};
    final List<List<Animal?>> generations = analysis?.generations ??
        <List<Animal?>>[
          <Animal?>[animal],
          <Animal?>[null, null],
        ];

    Color? chipColor(Animal? ancestor) {
      if (ancestor == null) {
        return theme.colorScheme.surfaceVariant;
      }
      final int count = occurrences[ancestor.id] ?? 0;
      if (count > 1) {
        return theme.colorScheme.errorContainer;
      }
      return theme.colorScheme.secondaryContainer;
    }

    final List<Widget> generationWidgets = <Widget>[];
    for (int i = 1; i < generations.length; i++) {
      final List<Animal?> ancestors = generations[i];
      final String label =
          i - 1 < _generationLabels.length ? _generationLabels[i - 1] : 'Génération +$i';
      generationWidgets
        ..add(
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
        )
        ..add(const SizedBox(height: 8))
        ..add(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final Animal? ancestor in ancestors)
                Chip(
                  backgroundColor: chipColor(ancestor),
                  avatar: const Icon(Icons.pets_outlined, size: 18),
                  label: Text(_ancestorLabel(ancestor)),
                ),
            ],
          ),
        )
        ..add(const SizedBox(height: 16));
    }

    final bool showRisk = analysis?.hasRisk ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Généalogie',
                  style: theme.textTheme.titleLarge,
                ),
                if (coefficient != null)
                  Chip(
                    backgroundColor: showRisk
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    avatar: Icon(
                      showRisk ? Icons.warning_amber : Icons.family_restroom,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    label: Text(
                      'Coeff. ${coefficient.toStringAsFixed(3)}',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _GenealogyRow(label: 'Père', value: animal.sireId ?? 'Inconnu'),
            _GenealogyRow(label: 'Mère', value: animal.damId ?? 'Inconnue'),
            if (showRisk) ...<Widget>[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.priority_high,
                          color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ascendance consanguine détectée. Surveillez les croisements futurs.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...generationWidgets,
            Text(
              'Ajoutez les ascendants supplémentaires pour visualiser les 3 générations.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenealogyRow extends StatelessWidget {
  const _GenealogyRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
