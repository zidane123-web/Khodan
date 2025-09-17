import 'package:flutter/material.dart';

import '../../../../data/models/event.dart';

class EventTimeline extends StatelessWidget {
  const EventTimeline({
    required this.events,
    super.key,
  });

  final List<LivestockEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucun événement pour le moment.'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        final LivestockEvent event = events[index];
        return ListTile(
          leading: const Icon(Icons.event_note),
          title: Text(event.eventType),
          subtitle: Text(
            MaterialLocalizations.of(context).formatMediumDate(event.eventDate),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: events.length,
    );
  }
}
