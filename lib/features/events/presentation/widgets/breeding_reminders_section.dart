import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';

class BreedingRemindersSection extends StatelessWidget {
  const BreedingRemindersSection({
    required this.reminders,
    required this.animalsById,
    super.key,
  });

  final List<BreedingReminder> reminders;
  final Map<String, Animal> animalsById;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (reminders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Rappels à venir', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Aucun rappel programmé pour l’instant.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Rappels à venir', style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 16),
          ...reminders.map((BreedingReminder reminder) {
            final Animal? doe = animalsById[reminder.doeId];
            final Animal? buck = animalsById[reminder.buckId];
            final String doeLabel = _formatAnimal(doe, reminder.doeId);
            final String buckLabel = _formatAnimal(buck, reminder.buckId);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: reminder.isOverdue
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,
                child: Icon(
                  _iconForType(reminder.type),
                  color: reminder.isOverdue
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(_titleForReminder(reminder.type)),
              subtitle: Text('$doeLabel × $buckLabel'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(reminder.dueDate),
                  ),
                  if (reminder.isOverdue)
                    Text(
                      'En retard',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _iconForType(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return Icons.monitor_heart;
      case BreedingTaskType.kindling:
        return Icons.nest_cam_wired_stand;
      case BreedingTaskType.weaning:
        return Icons.child_care_outlined;
    }
  }

  String _titleForReminder(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return 'Palpation à planifier';
      case BreedingTaskType.kindling:
        return 'Mise-bas à surveiller';
      case BreedingTaskType.weaning:
        return 'Sevrage à réaliser';
    }
  }

  String _formatAnimal(Animal? animal, String fallbackId) {
    if (animal == null) {
      return fallbackId;
    }
    return animal.name != null && animal.name!.isNotEmpty
        ? '${animal.tagId} · ${animal.name}'
        : animal.tagId;
  }
}
