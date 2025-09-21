import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class AnimalStatusIndicator {
  const AnimalStatusIndicator({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
}

List<AnimalStatusIndicator> statusIndicatorsForAnimal(
  Animal animal,
  ThemeData theme,
) {
  final List<AnimalStatusIndicator> indicators = <AnimalStatusIndicator>[];
  final String normalizedStatus = animal.status.toLowerCase();

  if (normalizedStatus.contains('gest') ||
      normalizedStatus.contains('repro') ||
      normalizedStatus.contains('mère')) {
    indicators.add(
      AnimalStatusIndicator(
        icon: Icons.favorite,
        color: theme.colorScheme.primary,
        tooltip: 'En reproduction',
      ),
    );
  }

  if (normalizedStatus.contains('trait') ||
      normalizedStatus.contains('soin') ||
      normalizedStatus.contains('sant')) {
    indicators.add(
      AnimalStatusIndicator(
        icon: Icons.medical_services,
        color: theme.colorScheme.error,
        tooltip: 'Sous traitement',
      ),
    );
  }

  if (normalizedStatus.contains('vend') ||
      normalizedStatus.contains('vente') ||
      normalizedStatus.contains('à vendre')) {
    indicators.add(
      AnimalStatusIndicator(
        icon: Icons.sell,
        color: theme.colorScheme.tertiary,
        tooltip: 'À vendre',
      ),
    );
  }

  return indicators;
}
