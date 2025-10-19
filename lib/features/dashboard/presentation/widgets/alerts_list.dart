import 'package:flutter/material.dart';

import 'package:khodan/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class AlertsList extends StatelessWidget {
  const AlertsList({
    required this.alerts,
    this.title = 'Alertes importantes',
    super.key,
  });

  final List<DashboardAlert> alerts;
  final String title;

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
            if (alerts.isEmpty)
              Text(
                'Aucune alerte en cours',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...alerts.map((DashboardAlert alert) {
                final Color color = _colorForType(alert.type, theme);
                final IconData icon = _iconForType(alert.type);
                final String relativeTime = _formatRelative(alert.timestamp);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha((255 * 0.12).round()),
                      foregroundColor: color,
                      child: Icon(icon),
                    ),
                    title: Text(alert.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(alert.message),
                        if (alert.detail != null && alert.detail!.isNotEmpty)
                          Text(
                            alert.detail!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: Text(
                      relativeTime,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(DashboardAlertType type) {
    switch (type) {
      case DashboardAlertType.info:
        return Icons.info_outline;
      case DashboardAlertType.warning:
        return Icons.warning_amber_rounded;
      case DashboardAlertType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _colorForType(DashboardAlertType type, ThemeData theme) {
    switch (type) {
      case DashboardAlertType.info:
        return theme.colorScheme.primary;
      case DashboardAlertType.warning:
        return theme.colorScheme.error;
      case DashboardAlertType.success:
        return theme.colorScheme.secondary;
    }
  }

  String _formatRelative(DateTime timestamp) {
    final Duration difference = DateTime.now().difference(timestamp);
    if (difference.inDays.abs() >= 1) {
      final int days = difference.inDays.abs();
      if (difference.isNegative) {
        return 'dans $days j';
      }
      return 'il y a $days j';
    }
    final int hours = difference.inHours.abs().clamp(1, 23);
    if (difference.isNegative) {
      return 'dans $hours h';
    }
    return 'il y a $hours h';
  }
}