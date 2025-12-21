import 'package:flutter/material.dart';

import '../cubit/dashboard_cubit.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    required this.title,
    required this.tasks,
    super.key,
  });

  final String title;
  final List<DashboardTask> tasks;

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
              title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Text(
                'Aucune tâche à afficher',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...tasks.map((DashboardTask task) {
                final Color color = _colorForKind(task.kind, theme);
                final IconData icon = _iconForKind(task.kind);
                final TextStyle? subtitleStyle = theme.textTheme.bodySmall?.copyWith(
                  color: task.isOverdue
                      ? theme.colorScheme.error
                      : theme.textTheme.bodySmall?.color,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withAlpha((255 * 0.15).round()),
                    foregroundColor: color,
                    child: Icon(icon),
                  ),
                  title: Text('${task.title} · ${task.contextLabel}'),
                  subtitle: Text(task.relativeLabel, style: subtitleStyle),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _iconForKind(DashboardTaskKind kind) {
    switch (kind) {
      case DashboardTaskKind.palpation:
        return Icons.monitor_heart;
      case DashboardTaskKind.nestBox:
        return Icons.inventory_2_outlined;
      case DashboardTaskKind.kindling:
        return Icons.baby_changing_station;
      case DashboardTaskKind.weaning:
        return Icons.restaurant_menu;
      case DashboardTaskKind.mating:
        return Icons.favorite_border;
    }
  }

  Color _colorForKind(DashboardTaskKind kind, ThemeData theme) {
    switch (kind) {
      case DashboardTaskKind.palpation:
        return theme.colorScheme.primary;
      case DashboardTaskKind.nestBox:
        return Colors.orange;
      case DashboardTaskKind.kindling:
        return theme.colorScheme.secondary;
      case DashboardTaskKind.weaning:
        return theme.colorScheme.tertiary;
      case DashboardTaskKind.mating:
        return theme.colorScheme.primary;
    }
  }
}