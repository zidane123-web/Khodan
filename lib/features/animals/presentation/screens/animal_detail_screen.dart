import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../widgets/genealogy_view.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({
    required this.animal,
    super.key,
  });

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name ?? animal.tagId),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Identité', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Tag', value: animal.tagId),
                  if (animal.name != null)
                    _InfoRow(label: 'Nom', value: animal.name!),
                  _InfoRow(label: 'Sexe', value: animal.sex),
                  _InfoRow(label: 'Statut', value: animal.status),
                  _InfoRow(
                    label: 'Date de naissance',
                    value:
                        MaterialLocalizations.of(context).formatMediumDate(animal.birthDate),
                  ),
                ],
              ),
            ),
          ),
          GenealogyView(animal: animal),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Historique', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text('Les événements liés à cet animal apparaîtront ici.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
