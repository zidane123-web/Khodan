import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import 'animal_status_indicators.dart';

class AnimalGridCard extends StatelessWidget {
  const AnimalGridCard({
    required this.animal,
    this.onTap,
    this.selectionEnabled = false,
    this.isSelected = false,
    this.onSelectionChanged,
    super.key,
  });

  final Animal animal;
  final VoidCallback? onTap;
  final bool selectionEnabled;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<AnimalStatusIndicator> indicators =
        statusIndicatorsForAnimal(animal, theme);
    final bool hasImage = animal.imageUrl != null && animal.imageUrl!.isNotEmpty;

    void handleTap() {
      if (selectionEnabled && onSelectionChanged != null) {
        onSelectionChanged!(!isSelected);
      } else {
        onTap?.call();
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: handleTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: hasImage
                      ? Image.network(
                          animal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child:
                                  const Icon(Icons.image_not_supported_outlined),
                            );
                          },
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Text(
                            animal.tagId,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        animal.tagId,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (animal.name != null && animal.name!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            animal.name!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${animal.sex} · ${localizations.formatShortDate(animal.birthDate)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (animal.cageNumber != null)
                        Text(
                          'Cage ${animal.cageNumber}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (indicators.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: indicators
                              .map(
                                (AnimalStatusIndicator indicator) => Tooltip(
                                  message: indicator.tooltip,
                                  child: Icon(
                                    indicator.icon,
                                    size: 18,
                                    color: indicator.color,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (selectionEnabled)
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface.withOpacity(0.75),
                foregroundColor: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                child: Icon(isSelected ? Icons.check : Icons.check_box_outline_blank),
              ),
            ),
          if (selectionEnabled && isSelected)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
