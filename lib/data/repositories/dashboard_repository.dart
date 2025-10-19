import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/local_data_sources.dart';
import '../models/dashboard_kpi_row.dart';
import '../models/dashboard_snapshot.dart';
import '../models/dashboard_preferences.dart';
import '../services/api_client.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot?> fetchSnapshot({
    DateTime? periodStart,
    DateTime? periodEnd,
  });

  Future<List<DashboardKpiRow>> fetchKpis({
    DateTime? since,
    List<int>? speciesIds,
    int limit = 12,
  });

  Future<DashboardPreferences?> loadPreferences(String profileId);

  Future<void> savePreferences(DashboardPreferences preferences);
}

class SupabaseDashboardRepository implements DashboardRepository {
  SupabaseDashboardRepository({
    required LocalDashboardPreferencesDataSource localPreferences,
    ApiExecutor? apiClient,
  })  : _localPreferences = localPreferences,
        _api = apiClient ?? ApiClient();

  final LocalDashboardPreferencesDataSource _localPreferences;
  final ApiExecutor _api;

  @override
  Future<DashboardSnapshot?> fetchSnapshot({
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      if (periodStart != null) 'p_period_start': ApiClient.encodeDate(periodStart),
      if (periodEnd != null) 'p_period_end': ApiClient.encodeDate(periodEnd),
    };
    final dynamic response = await _api.run((SupabaseClient client) {
      return client.rpc(
        'get_dashboard_snapshot',
        params: params.isEmpty ? null : params,
      );
    }, label: 'dashboard.snapshot.fetch');

    if (response == null) {
      return null;
    }

    if (response is List && response.isNotEmpty) {
      // Some RPCs return a single row wrapped inside a list.
      final dynamic first = response.first;
      if (first is Map) {
        return DashboardSnapshot.fromJson(
          Map<String, dynamic>.from(first as Map<dynamic, dynamic>),
        );
      }
    } else if (response is Map) {
      return DashboardSnapshot.fromJson(
        Map<String, dynamic>.from(response as Map<dynamic, dynamic>),
      );
    }

    throw DataLayerException(
      'Unexpected payload from get_dashboard_snapshot: ${response.runtimeType}',
    );
  }

  @override
  Future<List<DashboardKpiRow>> fetchKpis({
    DateTime? since,
    List<int>? speciesIds,
    int limit = 12,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      if (since != null) 'p_since': ApiClient.encodeDate(since),
      if (speciesIds != null && speciesIds.isNotEmpty)
        'p_species_ids': speciesIds,
      'p_limit': limit,
    };
    final List<dynamic> response = await _api.run((SupabaseClient client) {
      return client.rpc(
        'get_dashboard_kpis',
        params: params,
      );
    }, label: 'dashboard.kpis.fetch');
    return response
        .map(
          (dynamic row) =>
              DashboardKpiRow.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  @override
  Future<DashboardPreferences?> loadPreferences(String profileId) {
    return _localPreferences.fetch(profileId);
  }

  @override
  Future<void> savePreferences(DashboardPreferences preferences) {
    return _localPreferences.upsert(preferences);
  }
}

class InMemoryDashboardRepository implements DashboardRepository {
  InMemoryDashboardRepository();

  final Map<String, DashboardPreferences> _storedPreferences =
      <String, DashboardPreferences>{};

  @override
  Future<DashboardSnapshot?> fetchSnapshot({
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    // No remote aggregate available in memory; return null so the caller can fallback.
    return null;
  }

  @override
  Future<List<DashboardKpiRow>> fetchKpis({
    DateTime? since,
    List<int>? speciesIds,
    int limit = 12,
  }) async {
    final DateTime now = DateTime.now();
    return <DashboardKpiRow>[
      DashboardKpiRow(
        profileId: 'demo-profile',
        speciesId: 1,
        speciesName: 'Lapin',
        periodStart: DateTime(now.year, now.month, 1),
        periodEnd: now,
        totalLitters: 4,
        averageKitsBornAlive: 7.5,
        averageKitsWeaned: 6.8,
        totalKitsWeaned: 27,
        topDoeLabel: 'Fiona',
        topBuckLabel: 'Jasper',
      ),
    ];
  }

  @override
  Future<DashboardPreferences?> loadPreferences(String profileId) async {
    return _storedPreferences[profileId];
  }

  @override
  Future<void> savePreferences(DashboardPreferences preferences) async {
    _storedPreferences[preferences.profileId] = preferences;
  }
}
