import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/animal_event.dart';
import '../models/event.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

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

  static InMemoryEventRepository _instance =
      InMemoryEventRepository._internal();

  static void reset() {
    _instance = InMemoryEventRepository._internal();
  }

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
    const AnimalEventLink(
      eventId: 'event-001',
      animalId: 'doe-001',
      role: 'subject',
    ),
    const AnimalEventLink(
      eventId: 'event-002',
      animalId: 'buck-001',
      role: 'subject',
    ),
    const AnimalEventLink(
      eventId: 'event-003',
      animalId: 'doe-002',
      role: 'subject',
    ),
    const AnimalEventLink(
      eventId: 'event-004',
      animalId: 'doe-001',
      role: 'subject',
    ),
    const AnimalEventLink(
      eventId: 'event-004',
      animalId: 'doe-002',
      role: 'subject',
    ),
  ];

  @override
  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    final List<LivestockEvent> filtered =
        _events.where((LivestockEvent event) {
          if (start != null && event.eventDate.isBefore(start)) {
            return false;
          }
          if (end != null && event.eventDate.isAfter(end)) {
            return false;
          }
          return true;
        }).toList()..sort(
          (LivestockEvent a, LivestockEvent b) =>
              a.eventDate.compareTo(b.eventDate),
        );
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
  SupabaseEventRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      dynamic query = client.from('events').select();
      if (start != null) {
        query = query.gte('event_date', start.toIso8601String());
      }
      if (end != null) {
        query = query.lte('event_date', end.toIso8601String());
      }
      return query.order('event_date');
    }, label: 'events.fetch');
    return data
        .map(
          (dynamic row) => LivestockEvent.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    final List<dynamic> data = await _api.run((SupabaseClient client) {
      return client.from('animal_events').select();
    }, label: 'events.fetchLinks');
    return data
        .map(
          (dynamic row) =>
              AnimalEventLink.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    return _api.run<LivestockEvent>((SupabaseClient client) async {
      final List<dynamic> response = await client
          .from('events')
          .insert(event.toJson())
          .select();
      final LivestockEvent createdEvent = LivestockEvent.fromJson(
        response.first as Map<String, dynamic>,
      );

      if (links.isNotEmpty) {
        await client.from('animal_events').insert(<Map<String, dynamic>>[
          for (final AnimalEventLink link in links)
            <String, dynamic>{...link.toJson(), 'event_id': createdEvent.id},
        ]);
      }

      return createdEvent;
    }, label: 'events.create');
  }
}

class SyncedEventRepository implements EventRepository {
  SyncedEventRepository({
    required EventRepository remote,
    required LocalEventDataSource local,
    OfflineSyncManager? offlineManager,
  }) : _remote = remote,
       _local = local,
       _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final EventRepository _remote;
  final LocalEventDataSource _local;
  final OfflineSyncManager _offlineManager;
  static bool _handlersRegistered = false;

  List<AnimalEventLink>? _cachedLinks;

  @override
  Future<List<LivestockEvent>> fetchEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    if (_offlineManager.isOffline.value) {
      return _local.fetchEvents(start: start, end: end);
    }

    try {
      final List<LivestockEvent> events = await _remote.fetchEvents(
        start: start,
        end: end,
      );
      List<AnimalEventLink>? links;
      try {
        links = await _remote.fetchEventLinks();
        _cachedLinks = links;
      } catch (_) {
        links = null;
      }
      if (links != null) {
        await _local.replaceEvents(events, links: links);
      } else {
        final List<AnimalEventLink> cachedLinks = await _local.fetchLinks();
        await _local.replaceEvents(events, links: cachedLinks);
      }
      return events;
    } catch (error) {
      final List<LivestockEvent> cached = await _local.fetchEvents(
        start: start,
        end: end,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async {
    if (_offlineManager.isOffline.value) {
      return _local.fetchLinks();
    }
    if (_cachedLinks != null) {
      final List<AnimalEventLink> snapshot = _cachedLinks!;
      _cachedLinks = null;
      await _local.replaceLinks(snapshot);
      return snapshot;
    }
    final List<AnimalEventLink> links = await _remote.fetchEventLinks();
    await _local.replaceLinks(links);
    return links;
  }

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertEvent(
        event,
        links: links,
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createEvent,
          rollbackType: SyncActionType.deleteEvent,
          description: 'Créer évènement ${event.eventType}',
          payload: <String, dynamic>{
            'event': event.toJson(),
            'links': <Map<String, dynamic>>[
              for (final AnimalEventLink link in links) link.toJson(),
            ],
          },
          rollbackPayload: <String, dynamic>{'event_id': event.id},
          priority: 75,
          execute: () async {
            final LivestockEvent created = await _remote.createEvent(
              event,
              links: links,
            );
            await _local.upsertEvent(created, links: links);
          },
        ),
      );
      return event;
    }

    final LivestockEvent created = await _remote.createEvent(
      event,
      links: links,
    );
    await _local.upsertEvent(created, links: links);
    return created;
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createEvent,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> rawEvent =
            action.payload['event'] as Map<String, dynamic>;
        final List<dynamic> rawLinks =
            action.payload['links'] as List<dynamic>? ?? <dynamic>[];
        final LivestockEvent event = LivestockEvent.fromJson(rawEvent);
        final List<AnimalEventLink> links = <AnimalEventLink>[
          for (final dynamic item in rawLinks)
            AnimalEventLink.fromJson(item as Map<String, dynamic>),
        ];
        final LivestockEvent created = await _remote.createEvent(
          event,
          links: links,
        );
        await _local.upsertEvent(created, links: links);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final String? eventId = action.rollbackPayload?['event_id'] as String?;
        if (eventId != null) {
          await _local.deleteEvent(eventId);
        }
      },
    );
  }
}
