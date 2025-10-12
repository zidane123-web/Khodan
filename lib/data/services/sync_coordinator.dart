import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class SyncCoordinator {
  SyncCoordinator({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = <String, RealtimeChannel>{};
  final Map<String, StreamController<RealtimeMessage>> _controllers =
      <String, StreamController<RealtimeMessage>>{};

  Stream<RealtimeMessage> subscribeToTable(String table, {String schema = 'public'}) {
    final String key = ':';
    final StreamController<RealtimeMessage>? existingController = _controllers[key];
    if (existingController != null) {
      return existingController.stream;
    }

    final StreamController<RealtimeMessage> controller = StreamController<RealtimeMessage>.broadcast();
    _controllers[key] = controller;

    final RealtimeChannel channel = _client.channel('sync:');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: schema,
      table: table,
      callback: (PostgresChangePayload payload) {
        controller.add(RealtimeMessage(payload));
      },
    );
    channel.subscribe();
    _channels[key] = channel;

    return controller.stream;
  }

  Future<void> dispose() async {
    for (final RealtimeChannel channel in _channels.values) {
      await channel.unsubscribe();
    }
    for (final StreamController<RealtimeMessage> controller in _controllers.values) {
      await controller.close();
    }
    _channels.clear();
    _controllers.clear();
  }
}

class RealtimeMessage {
  const RealtimeMessage(this.payload);

  final PostgresChangePayload payload;
}
