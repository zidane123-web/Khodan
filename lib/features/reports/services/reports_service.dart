import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/api_client.dart';
import '../models/report_models.dart';

class ReportsService {
  ReportsService({ApiExecutor? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;
  final DateFormat _sqlDate = DateFormat('yyyy-MM-dd');

  Future<ReportsBundle> load({
    required String profileId,
    required DateTimeRange range,
  }) async {
    final DateTime normalizedStart = DateTime(
      range.start.year,
      range.start.month,
      1,
    );
    final DateTime normalizedEnd = DateTime(
      range.end.year,
      range.end.month + 1,
      0,
    );

    final String startStr = _sqlDate.format(normalizedStart);
    final String endStr = _sqlDate.format(normalizedEnd);

    final List<dynamic> reproductionRows = await _api.run(
      (SupabaseClient client) => client
          .from('view_reports_reproduction')
          .select()
          .eq('profile_id', profileId)
          .gte('period_start', startStr)
          .lte('period_start', endStr)
          .order('period_start', ascending: true),
      label: 'reports.load.reproduction',
    );

    final List<dynamic> growthRows = await _api.run(
      (SupabaseClient client) => client
          .from('view_reports_growth')
          .select()
          .eq('profile_id', profileId)
          .gte('period_start', startStr)
          .lte('period_start', endStr)
          .order('period_start', ascending: true),
      label: 'reports.load.growth',
    );

    final List<dynamic> financeRows = await _api.run(
      (SupabaseClient client) => client
          .from('view_reports_finances')
          .select()
          .eq('profile_id', profileId)
          .gte('period_start', startStr)
          .lte('period_start', endStr)
          .order('period_start', ascending: true),
      label: 'reports.load.finances',
    );

    final dynamic summaryResponse = await _api.run(
      (SupabaseClient client) => client.rpc(
        'fn_report_finance_summary',
        params: <String, dynamic>{
          'p_profile_id': profileId,
          'p_start_date': startStr,
          'p_end_date': endStr,
        },
      ),
      label: 'reports.load.financeSummary',
    );

    final List<ReproductionReportRow> reproduction = reproductionRows
        .map(
          (dynamic row) => ReproductionReportRow.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);

    final List<GrowthReportRow> growth = growthRows
        .map(
          (dynamic row) =>
              GrowthReportRow.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);

    final List<FinanceReportRow> finances = financeRows
        .map(
          (dynamic row) =>
              FinanceReportRow.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);

    final FinanceSummary summary = _parseSummary(summaryResponse);

    return ReportsBundle(
      reproduction: reproduction,
      growth: growth,
      finances: finances,
      summary: summary,
    );
  }

  FinanceSummary _parseSummary(dynamic payload) {
    if (payload is List && payload.isNotEmpty) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        payload.first as Map,
      );
      return FinanceSummary.fromJson(map);
    }
    if (payload is Map<String, dynamic>) {
      return FinanceSummary.fromJson(payload);
    }
    return const FinanceSummary(
      incomeTotal: 0,
      expenseTotal: 0,
      neutralTotal: 0,
      feedExpense: 0,
      salesIncome: 0,
      netMargin: 0,
    );
  }
}
