import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/species_config.dart';
import '../models/sync_action.dart';
import '../local/local_data_sources.dart';
import '../services/offline_sync_manager.dart';
import '../services/api_client.dart';
abstract class SpeciesRepository {
  Future<List<SpeciesConfig>> fetchSpecies(String profileId);

  Future<SpeciesConfig> createSpecies(SpeciesConfig config);

  Future<SpeciesConfig> updateSpecies(SpeciesConfig config);

  Future<void> deleteSpecies(int id);
}

class SupabaseSpeciesRepository implements SpeciesRepository {
  SupabaseSpeciesRepository({ApiExecutor? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  @override
  Future<List<SpeciesConfig>> fetchSpecies(String profileId) async {
    final List<dynamic> data = await _api.run(
      (SupabaseClient client) {
        return client
            .from('species_config')
            .select()
            .eq('profile_id', profileId)
            .order('species_name');
      },
      label: 'species.fetch',
    );

    return data
        .map((dynamic row) => SpeciesConfig.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SpeciesConfig> createSpecies(SpeciesConfig config) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(
      config.toJson(),
    )..remove('id');
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('species_config')
            .insert(payload)
            .select();
      },
      label: 'species.create',
    );
    return SpeciesConfig.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<SpeciesConfig> updateSpecies(SpeciesConfig config) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(
      config.toJson(),
    )
      ..remove('id')
      ..remove('profile_id');
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('species_config')
            .update(payload)
            .eq('id', config.id)
            .select();
      },
      label: 'species.update',
    );
    if (response.isEmpty) {
      throw StateError('Species ${config.id} introuvable pour mise à jour.');
    }
    return SpeciesConfig.fromJson(response.first as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSpecies(int id) async {
    await _api.run(
      (SupabaseClient client) {
        return client.from('species_config').delete().eq('id', id);
      },
      label: 'species.delete',
    );
  }
}

class SyncedSpeciesRepository implements SpeciesRepository {
  SyncedSpeciesRepository({
    required SpeciesRepository remote,
    required LocalSpeciesDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance {
    _registerHandlers();
  }

  final SpeciesRepository _remote;
  final LocalSpeciesDataSource _local;
  final OfflineSyncManager _offlineManager;
  bool _handlersRegistered = false;

  @override
  Future<List<SpeciesConfig>> fetchSpecies(String profileId) async {
    if (_offlineManager.isOffline.value) {
      return _local.fetchSpecies(profileId);
    }

    try {
      final List<SpeciesConfig> configs = await _remote.fetchSpecies(profileId);
      if (configs.isNotEmpty) {
        await _local.replaceSpeciesConfigs(
          configs,
          profileId: profileId,
        );
      } else {
        await _local.replaceSpeciesConfigs(
          const <SpeciesConfig>[],
          profileId: profileId,
        );
      }
      return configs;
    } catch (error) {
      final List<SpeciesConfig> cached = await _local.fetchSpecies(profileId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<SpeciesConfig> createSpecies(SpeciesConfig config) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertSpeciesConfigs(
        <SpeciesConfig>[config],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.createSpecies,
          description: 'Créer espèce ${config.speciesName}',
          payload: <String, dynamic>{'species': config.toJson()},
          rollbackPayload: <String, dynamic>{
            'species': config.toJson(),
          },
          priority: 100,
        ),
      );
      return config;
    }

    final SpeciesConfig created = await _remote.createSpecies(config);
    await _local.upsertSpeciesConfigs(<SpeciesConfig>[created]);
    return created;
  }

  @override
  Future<SpeciesConfig> updateSpecies(SpeciesConfig config) async {
    if (_offlineManager.isOffline.value) {
      await _local.upsertSpeciesConfigs(
        <SpeciesConfig>[config],
        syncState: kSyncStatePending,
      );
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.updateSpecies,
          description: 'Mettre à jour ${config.speciesName}',
          payload: <String, dynamic>{'species': config.toJson()},
          rollbackPayload: <String, dynamic>{'species': config.toJson()},
          priority: 90,
        ),
      );
      return config;
    }

    final SpeciesConfig updated = await _remote.updateSpecies(config);
    await _local.upsertSpeciesConfigs(<SpeciesConfig>[updated]);
    return updated;
  }

  @override
  Future<void> deleteSpecies(int id) async {
    if (_offlineManager.isOffline.value) {
      await _local.deleteSpeciesConfig(id);
      await _offlineManager.enqueueAction(
        SyncActionRequest(
          type: SyncActionType.deleteSpecies,
          description: 'Supprimer espèce $id',
          payload: <String, dynamic>{'species_id': id},
          priority: 80,
        ),
      );
      return;
    }
    await _remote.deleteSpecies(id);
    await _local.deleteSpeciesConfig(id);
  }

  void _registerHandlers() {
    if (_handlersRegistered) {
      return;
    }
    _handlersRegistered = true;

    _offlineManager.registerHandler(
      SyncActionType.createSpecies,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['species'] as Map<String, dynamic>;
        final SpeciesConfig config = SpeciesConfig.fromJson(raw);
        final SpeciesConfig created = await _remote.createSpecies(config);
        await _local.deleteSpeciesConfig(config.id);
        await _local.upsertSpeciesConfigs(<SpeciesConfig>[created]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['species'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.deleteSpeciesConfig(raw['id'] as int);
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.updateSpecies,
      (QueuedSyncAction action) async {
        final Map<String, dynamic> raw =
            action.payload['species'] as Map<String, dynamic>;
        final SpeciesConfig config = SpeciesConfig.fromJson(raw);
        final SpeciesConfig updated = await _remote.updateSpecies(config);
        await _local.upsertSpeciesConfigs(<SpeciesConfig>[updated]);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['species'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertSpeciesConfigs(
            <SpeciesConfig>[SpeciesConfig.fromJson(raw)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );

    _offlineManager.registerHandler(
      SyncActionType.deleteSpecies,
      (QueuedSyncAction action) async {
        final int id = action.payload['species_id'] as int;
        await _remote.deleteSpecies(id);
        await _local.deleteSpeciesConfig(id);
      },
      rollback: (QueuedSyncAction action, Object _) async {
        final Map<String, dynamic>? raw =
            action.rollbackPayload?['species'] as Map<String, dynamic>?;
        if (raw != null) {
          await _local.upsertSpeciesConfigs(
            <SpeciesConfig>[SpeciesConfig.fromJson(raw)],
            syncState: kSyncStateSynced,
          );
        }
      },
    );
  }
}
