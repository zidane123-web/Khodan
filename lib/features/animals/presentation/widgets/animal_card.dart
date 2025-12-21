import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import 'animal_status_indicators.dart';

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
    final int ageInDays = animal.ageInDays;
    final String ageLabel = ageInDays ~/ 30 > 0
        ? '${ageInDays ~/ 30} mois'
        : '$ageInDays jours';
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final bool isFemale = animal.isFemale;

    void handleSelection() {
      if (selectionEnabled && onSelectionChanged != null) {
        onSelectionChanged!(!isSelected);
      } else {
        onTap?.call();
      }
    }

    final List<AnimalStatusIndicator> indicators =
        statusIndicatorsForAnimal(animal, theme);

    final Widget leadingWidget = selectionEnabled
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
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Text(
              animal.tagId,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    return Card(
      child: InkWell(
        onTap: handleSelection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: leadingWidget,
            title: Text(
              animal.name ?? animal.tagId,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        <String>[
                          animal.sex,
                          ageLabel,
                          if (animal.cageNumber != null)
                            'Cage ${animal.cageNumber!}',
                        ].join(' · '),
                      ),
                    ),
                    if (indicators.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 6,
                        children: indicators
                            .map(
                              (AnimalStatusIndicator indicator) => Tooltip(
                                message: indicator.tooltip,
                                child: Icon(
                                  indicator.icon,
                                  color: indicator.color,
                                  size: 18,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
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
        ),
      ),
    );
  }
}
