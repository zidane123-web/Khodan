import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class GenealogyView extends StatelessWidget {
  const GenealogyView({
    required this.animal,
    super.key,
  });

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Généalogie',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _GenealogyRow(label: 'Père', value: animal.sireId ?? 'Inconnu'),
            _GenealogyRow(label: 'Mère', value: animal.damId ?? 'Inconnue'),
            const SizedBox(height: 12),
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
