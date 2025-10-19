import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/event_template.dart';
import '../models/sync_action.dart';
import '../services/api_client.dart';
import '../services/offline_sync_manager.dart';

abstract class EventTemplateRepository {
  Future<List<EventTemplate>> fetchTemplates(String profileId);

  Future<EventTemplate> createTemplate(EventTemplate template);

  Future<EventTemplate> updateTemplate(EventTemplate template);

  Future<void> deleteTemplate(int id);
}

class SupabaseEventTemplateRepository implements EventTemplateRepository {
  SupabaseEventTemplateRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<EventTemplate>> fetchTemplates(String profileId) async {
    final List<dynamic> data = await _api.run(
      (SupabaseClient client) {
        return client
            .from('event_templates')
            .select()
            .eq('user_id', profileId)
            .order('template_name');
      },
      label: 'eventTemplates.fetch',
    );
    return data
        .map((dynamic row) =>
            EventTemplate.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<EventTemplate> createTemplate(EventTemplate template) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'user_id': template.userId,
      'template_name': template.templateName,
      'event_type': template.eventType,
      'default_details': template.defaultDetails,
    };
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('event_templates')
            .insert(payload)
            .select();
      },
      label: 'eventTemplates.create',
    );
    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response.first as Map);
    return EventTemplate.fromJson(json);
  }

  @override
  Future<EventTemplate> updateTemplate(EventTemplate template) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'template_name': template.templateName,
      'event_type': template.eventType,
      'default_details': template.defaultDetails,
    };
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('event_templates')
            .update(payload)
            .eq('id', template.id)
            .select();
      },
      label: 'eventTemplates.update',
    );
    if (response.isEmpty) {
      throw StateError('Event template ${template.id} introuvable.');
    }
    return EventTemplate.fromJson(
        Map<String, dynamic>.from(response.first as Map));
  }

  @override
  Future<void> deleteTemplate(int id) async {
    await _api.run(
      (SupabaseClient client) {
        return client.from('event_templates').delete().eq('id', id);
      },
      label: 'eventTemplates.delete',
    );
  }
}

class SyncedEventTemplateRepository implements EventTemplateRepository {
  SyncedEventTemplateRepository({
    required EventTemplateRepository remote,
    required LocalEventTemplateDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final EventTemplateRepository _remote;
  final LocalEventTemplateDataSource _local;
  final OfflineSyncManager _offlineManager;
  bool _handlersRegistered = false;

  @override
  Future<List<EventTemplate>> fetchTemplates(String profileId) async {
    if (_offlineManager.isOffline.value) {
      return _local.fetchTemplates(profileId);
    }
    try {
      final List<EventTemplate> templates =
          await _remote.fetchTemplates(profileId);
      await _local.replaceTemplates(
        templates,
        profileId: profileId,
      );
      return templates;
    } catch (error) {
      final List<EventTemplate> cached =
          await _local.fetchTemplates(profileId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<EventTemplate> createTemplate(EventTemplate template) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertTemplates(
        <EventTemplate>[template],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createEventTemplate,
          description: 'Créer modèle ${template.templateName}',
          payload: <String, dynamic>{
            'template': template.toJson(),
          },
          rollbackPayload: <String, dynamic>{
            'template': template.toJson(),
          },
          priority: 85,
        ),
      );
      return template;
    }

    final EventTemplate created = await _remote.createTemplate(template);
    await _local.upsertTemplates(<EventTemplate>[created]);
    return created;
  }

  @override
  Future<EventTemplate> updateTemplate(EventTemplate template) async {
    if (_offlineManager.isOffline.value) {
      final EventTemplate? previous =
          await _local.fetchTemplateById(template.id);
      await _local.upsertTemplates(
        <EventTemplate>[template],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateEventTemplate,
          description: 'Mettre à jour modèle ${template.templateName}',
          payload: <String, dynamic>{
            'template': template.toJson(),
          },
          rollbackPayload: previous == null
              ? null
              : <String, dynamic>{'template': previous.toJson()},
          priority: 80,
        ),
      );
      return template;
    }

    final EventTemplate updated = await _remote.updateTemplate(template);
    await _local.upsertTemplates(<EventTemplate>[updated]);
    return updated;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    if (_offlineManager.isOffline.value) {
      final EventTemplate? snapshot = await _local.fetchTemplateById(id);
      await _local.deleteTemplate(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteEventTemplate,
          description: 'Supprimer modèle $id',
          payload: <String, dynamic>{'template_id': id},
          rollbackPayload: snapshot == null
              ? null
              : <String, dynamic>{'template': snapshot.toJson()},
          priority: 75,
        ),
      );
      return;
    }
    await _remote.deleteTemplate(id);
    await _local.deleteTemplate(id);
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createEventTemplate,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['template'] as Map<String, dynamic>;
        final EventTemplate template = EventTemplate.fromJson(raw);
        final EventTemplate created = await _remote.createTemplate(template);
        await _local.deleteTemplate(template.id);
        await _local.upsertTemplates(<EventTemplate>[created]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['template'] as Map<String, dynamic>?;
        if (raw != null) {
          final EventTemplate template = EventTemplate.fromJson(raw);
          await _local.deleteTemplate(template.id);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateEventTemplate,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['template'] as Map<String, dynamic>;
        final EventTemplate template = EventTemplate.fromJson(raw);
        final EventTemplate updated = await _remote.updateTemplate(template);
        await _local.upsertTemplates(<EventTemplate>[updated]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['template'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertTemplates(
            <EventTemplate>[EventTemplate.fromJson(raw)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteEventTemplate,
      (QueuedSyncAction action) async {
        final int id = action.payload['template_id'] as int;
        await _remote.deleteTemplate(id);
        await _local.deleteTemplate(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['template'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertTemplates(
            <EventTemplate>[EventTemplate.fromJson(raw)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );
  }
}

class InMemoryEventTemplateRepository implements EventTemplateRepository {
  InMemoryEventTemplateRepository();

  final List<EventTemplate> _templates = <EventTemplate>[];

  @override
  Future<List<EventTemplate>> fetchTemplates(String profileId) async {
    return _templates
        .where((EventTemplate template) => template.userId == profileId)
        .toList();
  }

  @override
  Future<EventTemplate> createTemplate(EventTemplate template) async {
    _templates.removeWhere((EventTemplate element) => element.id == template.id);
    _templates.add(template);
    return template;
  }

  @override
  Future<EventTemplate> updateTemplate(EventTemplate template) async {
    await deleteTemplate(template.id);
    _templates.add(template);
    return template;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    _templates.removeWhere((EventTemplate template) => template.id == id);
  }
}
