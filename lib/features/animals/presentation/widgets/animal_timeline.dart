import 'package:flutter/material.dart';

import '../cubit/animal_detail_cubit.dart';

class AnimalTimeline extends StatelessWidget {
  const AnimalTimeline({
    required this.entries,
    super.key,
  });

  final List<AnimalTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Historique complet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(
                'Aucun événement enregistré pour le moment.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...List<Widget>.generate(entries.length, (int index) {
                final AnimalTimelineEntry entry = entries[index];
                final bool isLast = index == entries.length - 1;
                return _TimelineItem(entry: entry, isLast: isLast);
              }),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.entry, required this.isLast});

  final AnimalTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = _colorForCategory(entry.category, theme);
    final IconData icon = _iconForCategory(entry.category);
    final String dateText =
        MaterialLocalizations.of(context).formatMediumDate(entry.date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withAlpha((255 * 0.15).round()),
                foregroundColor: color,
                child: Icon(icon, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.dividerColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(dateText, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(entry.title, style: theme.textTheme.titleMedium),
                  if (entry.description != null && entry.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(entry.description!,
                          style: theme.textTheme.bodyMedium),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(AnimalTimelineCategory category) {
    switch (category) {
      case AnimalTimelineCategory.birth:
        return Icons.cake_outlined;
      case AnimalTimelineCategory.breeding:
        return Icons.favorite_border;
      case AnimalTimelineCategory.health:
        return Icons.medical_services_outlined;
      case AnimalTimelineCategory.housing:
        return Icons.home_outlined;
      case AnimalTimelineCategory.weight:
        return Icons.monitor_weight;
      case AnimalTimelineCategory.general:
        return Icons.event_note_outlined;
    }
  }

  Color _colorForCategory(AnimalTimelineCategory category, ThemeData theme) {
    switch (category) {
      case AnimalTimelineCategory.birth:
        return theme.colorScheme.primary;
      case AnimalTimelineCategory.breeding:
        return theme.colorScheme.secondary;
      case AnimalTimelineCategory.health:
        return theme.colorScheme.error;
      case AnimalTimelineCategory.housing:
        return theme.colorScheme.primaryContainer;
      case AnimalTimelineCategory.weight:
        return theme.colorScheme.tertiary;
      case AnimalTimelineCategory.general:
        return theme.colorScheme.outline;
    }
  }
}