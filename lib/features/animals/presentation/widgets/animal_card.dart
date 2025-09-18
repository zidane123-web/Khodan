import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    required this.animal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Animal animal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int ageInDays = animal.ageInDays;
    final String ageLabel = ageInDays ~/ 30 > 0
        ? '${ageInDays ~/ 30} mois'
        : '$ageInDays jours';
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(animal.tagId),
        ),
        title: Text(animal.name ?? animal.tagId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              <String>[
                animal.sex,
                ageLabel,
                if (animal.cageNumber != null)
                  'Cage ${animal.cageNumber!}',
              ].join(' · '),
            ),
            if (animal.origin != null && animal.origin!.isNotEmpty)
              Text('Origine : ${animal.origin!}'),
            if (animal.entryDate != null)
              Text(
                'Entrée : ${localizations.formatMediumDate(animal.entryDate!)}',
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Chip(
                  label: Text(animal.status),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
                if (animal.firstBreedingDate != null)
                  Chip(
                    label: Text(
                      '1ère saillie : ${localizations.formatMediumDate(animal.firstBreedingDate!)}',
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: (onEdit != null || onDelete != null)
            ? PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (onEdit != null)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
