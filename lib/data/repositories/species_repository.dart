import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/species_config.dart';
import '../local/local_data_sources.dart';
import '../services/offline_sync_manager.dart';
import '../services/api_client.dart';
abstract class SpeciesRepository {
  Future<List<SpeciesConfig>> fetchSpecies(String profileId);

  Future<SpeciesConfig> createSpecies(SpeciesConfig config);
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
    final List<dynamic> response = await _api.run(
      (SupabaseClient client) {
        return client
            .from('species_config')
            .insert(config.toJson())
            .select();
      },
      label: 'species.create',
    );
    return SpeciesConfig.fromJson(response.first as Map<String, dynamic>);
  }
}

class SyncedSpeciesRepository implements SpeciesRepository {
  SyncedSpeciesRepository({
    required SpeciesRepository remote,
    required LocalSpeciesDataSource local,
    OfflineSyncManager? offlineManager,
  })  : _remote = remote,
        _local = local,
        _offlineManager = offlineManager ?? OfflineSyncManager.instance;

  final SpeciesRepository _remote;
  final LocalSpeciesDataSource _local;
  final OfflineSyncManager _offlineManager;

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
      await _local.upsertSpeciesConfigs(<SpeciesConfig>[config], syncState: kSyncStatePending);
      return config;
    }

    final SpeciesConfig created = await _remote.createSpecies(config);
    await _local.upsertSpeciesConfigs(<SpeciesConfig>[created]);
    return created;
  }
}
