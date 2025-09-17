import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/animal_event.dart';
import '../models/event.dart';

abstract class EventRepository {
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end});

  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links,
  });
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
