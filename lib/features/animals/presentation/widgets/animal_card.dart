
import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    required this.animal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onQuickBreed,
    this.selectionEnabled = false,
    this.isSelected = false,
    this.onSelectionChanged,
    super.key,
  });

  final Animal animal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onQuickBreed;
  final bool selectionEnabled;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final int ageInDays = animal.ageInDays;
    final String ageLabel = ageInDays ~/ 30 > 0
        ? '${ageInDays ~/ 30} mois'
        : '$ageInDays jours';
    final bool isFemale = animal.sex.toLowerCase().contains('fem');
    final String displaySex = animal.sex.toLowerCase() == 'male'
        ? 'Male'
        : animal.sex;
    final String cageLabel =
        (animal.cageNumber != null && animal.cageNumber!.isNotEmpty)
            ? 'Cage ${animal.cageNumber!}'
            : 'Cage non definie';
    final String? breed = (animal.breed != null && animal.breed!.trim().isNotEmpty)
        ? animal.breed!.trim()
        : null;
    final String? category =
        (animal.category != null && animal.category!.trim().isNotEmpty)
            ? animal.category!.trim()
            : null;
    final String? lastLitter = animal.lastLitterDate == null
        ? null
        : localizations.formatMediumDate(animal.lastLitterDate!);
    final String? nextTask = animal.nextTaskDate == null
        ? null
        : localizations.formatMediumDate(animal.nextTaskDate!);
    final String? firstBreeding = animal.firstBreedingDate == null
        ? null
        : localizations.formatMediumDate(animal.firstBreedingDate!);

    void handleSelection() {
      if (selectionEnabled && onSelectionChanged != null) {
        onSelectionChanged!(!isSelected);
      } else {
        onTap?.call();
      }
    }

    return Card(
      child: ListTile(
        onTap: handleSelection,
        leading: selectionEnabled
            ? Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  if (onSelectionChanged != null && value != null) {
                    onSelectionChanged!(value);
                  }
                },
              )
            : CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(animal.tagId),
              ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                animal.name ?? animal.tagId,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (category != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Chip(
                  label: Text(category),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                <String>[
                  'ID ${animal.tagId}',
                  displaySex,
                  ageLabel,
                  cageLabel,
                ].join(' - '),
              ),
              if (breed != null) Text('Race: $breed'),
              if (animal.origin != null && animal.origin!.isNotEmpty)
                Text('Origine: ${animal.origin}'),
              if (animal.entryDate != null)
                Text(
                  'Entree: ${localizations.formatMediumDate(animal.entryDate!)}',
                ),
              if (animal.notes != null && animal.notes!.isNotEmpty)
                Text('Note: ${animal.notes}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  Chip(
                    label: Text(animal.status),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                  if (breed != null)
                    Chip(
                      label: Text(breed),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  if (firstBreeding != null)
                    Chip(
                      label: Text('Premiere saillie: $firstBreeding'),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  if (lastLitter != null)
                    Chip(
                      label: Text('Derniere portee: $lastLitter'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  if (nextTask != null)
                    Chip(
                      label: Text('Prochaine action: $nextTask'),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: (onEdit != null || onDelete != null || onQuickBreed != null)
            ? PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                    case 'breed':
                      onQuickBreed?.call();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (onQuickBreed != null && isFemale)
                    const PopupMenuItem<String>(
                      value: 'breed',
                      child: Text('Nouvelle saillie'),
                    ),
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
