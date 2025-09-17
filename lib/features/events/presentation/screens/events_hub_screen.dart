import 'package:flutter/material.dart';

import '../../../../data/models/event.dart';
import '../widgets/event_timeline.dart';

class EventsHubScreen extends StatelessWidget {
  const EventsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Événements'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Reproduction'),
              Tab(text: 'Santé'),
              Tab(text: 'Autres'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _EventsTab(category: 'Reproduction'),
            _EventsTab(category: 'Santé'),
            _EventsTab(category: 'Autres'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Nouvel événement'),
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({
    required this.category,
  });

  final String category;

  List<LivestockEvent> _demoEventsForCategory() {
    return <LivestockEvent>[
      LivestockEvent(
        id: 'demo-$category-1',
        profileId: 'demo',
        eventType: category == 'Reproduction' ? 'Mise bas' : 'Vaccin',
        eventDate: DateTime.now().subtract(const Duration(days: 2)),
        details: const <String, dynamic>{},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return EventTimeline(events: _demoEventsForCategory());
  }
}
