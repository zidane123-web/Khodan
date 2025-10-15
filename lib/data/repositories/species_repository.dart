import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/species_config.dart';
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
