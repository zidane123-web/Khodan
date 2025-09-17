import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/species_config.dart';

abstract class SpeciesRepository {
  Future<List<SpeciesConfig>> fetchSpecies(String profileId);

  Future<SpeciesConfig> createSpecies(SpeciesConfig config);
}

class SupabaseSpeciesRepository implements SpeciesRepository {
  SupabaseSpeciesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<SpeciesConfig>> fetchSpecies(String profileId) async {
    final List<dynamic> data = await _client
        .from('species_config')
        .select()
        .eq('profile_id', profileId)
        .order('species_name');

    return data
        .map((dynamic row) => SpeciesConfig.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SpeciesConfig> createSpecies(SpeciesConfig config) async {
    final List<dynamic> response = await _client
        .from('species_config')
        .insert(config.toJson())
        .select();
    return SpeciesConfig.fromJson(response.first as Map<String, dynamic>);
  }
}
