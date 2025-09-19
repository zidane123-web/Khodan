import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/animal_event.dart';
import '../models/event.dart';

abstract class EventRepository {
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end});

  Future<List<AnimalEventLink>> fetchEventLinks();

  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links,
  });
}

class InMemoryEventRepository implements EventRepository {
  factory InMemoryEventRepository() => _instance;

  InMemoryEventRepository._internal();

  static final InMemoryEventRepository _instance =
      InMemoryEventRepository._internal();

  final List<LivestockEvent> _events = <LivestockEvent>[
    LivestockEvent(
      id: 'event-001',
      profileId: 'demo-profile',
      eventType: 'weight',
      eventDate: DateTime.now().subtract(const Duration(days: 5)),
      details: <String, dynamic>{
        'animalIds': <String>['doe-001'],
        'weightKg': 4.3,
      },
      notes: 'Poids stable par rapport au mois dernier.',
    ),
    LivestockEvent(
      id: 'event-002',
      profileId: 'demo-profile',
      eventType: 'treatment',
      eventDate: DateTime.now().subtract(const Duration(days: 12)),
      details: <String, dynamic>{
        'animalIds': <String>['buck-001'],
        'treatment': 'Vermifuge',
      },
      notes: 'Rappel trimestriel effectué sans incident.',
    ),
    LivestockEvent(
      id: 'event-003',
      profileId: 'demo-profile',
      eventType: 'cage_change',
      eventDate: DateTime.now().subtract(const Duration(days: 2)),
      details: <String, dynamic>{
        'animalIds': <String>['doe-002'],
        'from': 'C-102',
        'to': 'C-108',
      },
      notes: 'Transfert vers cage maternité.',
    ),
    LivestockEvent(
      id: 'event-004',
      profileId: 'demo-profile',
      eventType: 'health_check',
      eventDate: DateTime.now().add(const Duration(days: 3)),
      details: <String, dynamic>{
        'animalIds': <String>['doe-001', 'doe-002'],
        'veterinarian': 'Dr. Lemoine',
      },
      notes: 'Contrôle post-mise-bas programmé.',
    ),
    LivestockEvent(
      id: 'event-005',
      profileId: 'demo-profile',
      eventType: 'inventory',
      eventDate: DateTime.now().add(const Duration(days: 10)),
      details: <String, dynamic>{
        'scope': 'farm',
        'description': 'Inventaire mensuel des aliments.',
      },
      notes: 'Prévoir vérification des stocks de granulés.',
    ),
  ];

  final List<AnimalEventLink> _links = <AnimalEventLink>[
    const AnimalEventLink(eventId: 'event-001', animalId: 'doe-001', role: 'subject'),
    const AnimalEventLink(eventId: 'event-002', animalId: 'buck-001', role: 'subject'),
    const AnimalEventLink(eventId: 'event-003', animalId: 'doe-002', role: 'subject'),
    const AnimalEventLink(eventId: 'event-004', animalId: 'doe-001', role: 'subject'),
    const AnimalEventLink(eventId: 'event-004', animalId: 'doe-002', role: 'subject'),
  ];

  @override
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end}) async {
    final List<LivestockEvent> filtered = _events.where((LivestockEvent event) {
      if (start != null && event.eventDate.isBefore(start)) {
        return false;
      }
      if (end != null && event.eventDate.isAfter(end)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((LivestockEvent a, LivestockEvent b) => a.eventDate.compareTo(b.eventDate));
    return filtered;
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    return List<AnimalEventLink>.from(_links);
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    final LivestockEvent created = event.copyWith(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}',
    );
    _events.add(created);
    if (links.isNotEmpty) {
      _links.addAll(<AnimalEventLink>[
        for (final AnimalEventLink link in links)
          link.copyWith(eventId: created.id),
      ]);
    }
    return created;
  }
}

class SupabaseEventRepository implements EventRepository {
  SupabaseEventRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end}) async {
    PostgrestFilterBuilder<dynamic> query = _client.from('events').select();

    if (start != null) {
      query = query.gte('event_date', start.toIso8601String());
    }
    if (end != null) {
      query = query.lte('event_date', end.toIso8601String());
    }

    final List<dynamic> data = await query.order('event_date');
    return data
        .map((dynamic row) => LivestockEvent.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    final List<dynamic> data = await _client.from('animal_events').select();
    return data
        .map((dynamic row) =>
            AnimalEventLink.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    final List<dynamic> response = await _client
        .from('events')
        .insert(event.toJson())
        .select();
    final LivestockEvent createdEvent =
        LivestockEvent.fromJson(response.first as Map<String, dynamic>);

    if (links.isNotEmpty) {
      await _client.from('animal_events').insert(<Map<String, dynamic>>[
        for (final AnimalEventLink link in links)
          <String, dynamic>{
            ...link.toJson(),
            'event_id': createdEvent.id,
          },
      ]);
    }

    return createdEvent;
  }
}
