import 'package:flutter/material.dart';

import '../../../../data/models/event.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    required this.event,
    super.key,
  });

  final LivestockEvent event;

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'treatment':
        return Icons.medical_services_outlined;
      case 'sale':
        return Icons.point_of_sale;
      case 'weight':
        return Icons.monitor_weight_outlined;
      case 'mise bas':
      case 'mise-bas':
        return Icons.nest_cam_wired_stand;
      default:
        return Icons.event_note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations l10n = MaterialLocalizations.of(context);
    final Map<String, dynamic> details = event.details;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details de l'evenement"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(_iconForType(event.eventType)),
              title: Text(event.eventType),
              subtitle: Text(l10n.formatMediumDate(event.eventDate)),
            ),
          ),
          const SizedBox(height: 12),
          if (event.notes != null && event.notes!.trim().isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Notes", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(event.notes!),
                  ],
                ),
              ),
            ),
          if (details.isNotEmpty) ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Details", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...details.entries.map((MapEntry<String, dynamic> e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 140,
                              child: Text(
                                e.key,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${e.value}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

