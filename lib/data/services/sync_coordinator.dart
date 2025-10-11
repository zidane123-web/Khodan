import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Coordinates realtime subscriptions and offline sync queues.
class SyncCoordinator {
  SyncCoordinator({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = <String, RealtimeChannel>{};
  final StreamController<RealtimeMessage> _controller = StreamController<RealtimeMessage>.broadcast();

  Stream<RealtimeMessage> subscribeToTable(String table, {String schema = 'public'}) {
    final String key = '$schema:$table';
    final RealtimeChannel? existing = _channels[key];
    if (existing != null) {
      return _controller.stream;
    }

    final RealtimeChannel channel = _client.channel('sync:$key');
    channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(event: '*', schema: schema, table: table),
        (dynamic payload, [RealtimeChannel? _]) {
          _controller.add(RealtimeMessage(payload: Map<String, dynamic>.from(payload as Map)));
        },
      )
      .subscribe();
    _channels[key] = channel;

    return _controller.stream;
  }

  Future<void> dispose() async {
    for (final RealtimeChannel channel in _channels.values) {
      await channel.unsubscribe();
    }
    _channels.clear();
    await _controller.close();
  }
}

class RealtimeMessage {
  const RealtimeMessage({required this.payload});

  final Map<String, dynamic> payload;
}
