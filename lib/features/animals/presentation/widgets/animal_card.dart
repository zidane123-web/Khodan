import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    required this.animal,
    this.onTap,
    super.key,
  });

  final Animal animal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int ageInDays = animal.ageInDays;
    final String ageLabel = ageInDays ~/ 30 > 0
        ? '${ageInDays ~/ 30} mois'
        : '$ageInDays jours';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(animal.tagId),
        ),
        title: Text(animal.name ?? animal.tagId),
        subtitle: Text('${animal.sex} · $ageLabel'),
        trailing: Chip(
          label: Text(animal.status),
          backgroundColor: theme.colorScheme.secondaryContainer,
        ),
      ),
    );
  }
}
