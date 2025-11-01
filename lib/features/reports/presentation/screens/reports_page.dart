import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../models/report_models.dart';
import '../../services/report_export_service.dart';
import '../../services/reports_service.dart';
import '../cubit/reports_cubit.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, this.profileIdOverride});

  final String? profileIdOverride;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ReportsTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthState? authState;
    if (widget.profileIdOverride == null) {
      authState = context.watch<AuthCubit>().state;
    }
    final String? profileId =
        widget.profileIdOverride ??
        authState?.profile?.id ??
        authState?.session?.user.id;

    return BlocProvider<ReportsCubit>(
      create: (BuildContext context) {
        final ReportsCubit cubit = ReportsCubit(
          service: context.read<ReportsService>(),
          exportService: ReportsExportService(),
        );
        if (profileId != null) {
          cubit.load(profileId: profileId);
        }
        return cubit;
      },
      child: _ReportsScaffold(
        tabController: _tabController,
        profileId: profileId,
      ),
    );
  }
}

class _ReportsScaffold extends StatefulWidget {
  const _ReportsScaffold({
    required this.tabController,
    required this.profileId,
  });

  final TabController tabController;
  final String? profileId;

  @override
  State<_ReportsScaffold> createState() => _ReportsScaffoldState();
}

class _ReportsScaffoldState extends State<_ReportsScaffold> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ReportsTab get _currentTab => ReportsTab.values[widget.tabController.index];

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {});
  }

  void _showMessage(String message) {
    _messengerKey.currentState?.hideCurrentSnackBar();
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleExportCsv(BuildContext context) async {
    try {
      await context.read<ReportsCubit>().exportCsv(_currentTab);
      _showMessage('Export CSV pret a partager.');
    } catch (error) {
      _showMessage('Echec export CSV: $error');
    }
  }

  Future<void> _handleExportExcel(BuildContext context) async {
    try {
      await context.read<ReportsCubit>().exportExcel(_currentTab);
      _showMessage('Export Excel pret a partager.');
    } catch (error) {
      _showMessage('Echec export Excel: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rapports'),
          bottom: TabBar(
            controller: widget.tabController,
            tabs: const <Tab>[
              Tab(text: 'Reproduction'),
              Tab(text: 'Croissance'),
              Tab(text: 'Finances'),
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: widget.profileId == null
                  ? null
                  : () => context.read<ReportsCubit>().refresh(
                      profileId: widget.profileId!,
                    ),
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
            ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'csv') {
                  _handleExportCsv(context);
                } else if (value == 'excel') {
                  _handleExportExcel(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'csv',
                  child: ListTile(
                    leading: Icon(Icons.table_chart_outlined),
                    title: Text('Exporter CSV'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'excel',
                  child: ListTile(
                    leading: Icon(Icons.grid_on_outlined),
                    title: Text('Exporter Excel'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _ReportsHeader(profileId: widget.profileId),
            Expanded(
              child: TabBarView(
                controller: widget.tabController,
                children: <Widget>[
                  _ReproductionTab(profileId: widget.profileId),
                  _GrowthTab(profileId: widget.profileId),
                  _FinanceTab(profileId: widget.profileId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({required this.profileId});

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (BuildContext context, ReportsState state) {
        final DateFormat formatter = DateFormat('d MMM yyyy', 'fr');
        final String rangeLabel =
            '${formatter.format(state.range.start)} - ${formatter.format(state.range.end)}';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Periode analysee',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(rangeLabel),
                  ],
                ),
              ),
              DropdownButton<ReportsRangePreset>(
                value: state.preset,
                onChanged: profileId == null
                    ? null
                    : (ReportsRangePreset? preset) {
                        if (preset != null) {
                          context.read<ReportsCubit>().changePreset(
                            preset: preset,
                            profileId: profileId!,
                          );
                        }
                      },
                items: const <DropdownMenuItem<ReportsRangePreset>>[
                  DropdownMenuItem<ReportsRangePreset>(
                    value: ReportsRangePreset.threeMonths,
                    child: Text('3 mois'),
                  ),
                  DropdownMenuItem<ReportsRangePreset>(
                    value: ReportsRangePreset.sixMonths,
                    child: Text('6 mois'),
                  ),
                  DropdownMenuItem<ReportsRangePreset>(
                    value: ReportsRangePreset.twelveMonths,
                    child: Text('12 mois'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReproductionTab extends StatelessWidget {
  const _ReproductionTab({required this.profileId});

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (BuildContext context, ReportsState state) {
        if (state.status == ReportsStatus.loading && state.bundle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ReportsStatus.failure) {
          return _ErrorView(
            message:
                state.errorMessage ?? 'Impossible de charger les rapports.',
            onRetry: profileId == null
                ? null
                : () => context.read<ReportsCubit>().refresh(
                    profileId: profileId!,
                  ),
          );
        }
        final List<ReproductionReportRow> rows =
            state.bundle?.reproduction ?? <ReproductionReportRow>[];
        if (rows.isEmpty) {
          return const _EmptyView(
            message: 'Aucun indicateur de reproduction pour cette periode.',
          );
        }

        final ReproductionReportRow latest = rows.last;
        final List<FlSpot> fertilitySpots = _toSpots(
          rows,
          (ReproductionReportRow row) => row.fertilityRate * 100,
        );
        final List<String> labels = rows
            .map((ReproductionReportRow row) {
              return DateFormat('MM/yy').format(row.periodStart);
            })
            .toList(growable: false);

        return RefreshIndicator(
          onRefresh: profileId == null
              ? () async {}
              : () =>
                    context.read<ReportsCubit>().refresh(profileId: profileId!),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _ReportChartCard(
                title: 'Taux de fertilite',
                subtitle: 'Evolution par mois',
                spots: fertilitySpots,
                labels: labels,
                valueSuffix: '%',
              ),
              const SizedBox(height: 16),
              _MetricWrap(
                metrics: <_MetricDefinition>[
                  _MetricDefinition(
                    label: 'Fertilite',
                    value: _formatPercent(latest.fertilityRate),
                  ),
                  _MetricDefinition(
                    label: 'Mise bas',
                    value: latest.kindlings.toString(),
                    helper: 'Confirmations',
                  ),
                  _MetricDefinition(
                    label: 'Kits sevres',
                    value: latest.kitsWeaned.toString(),
                  ),
                  _MetricDefinition(
                    label: 'Taille portee',
                    value: _formatNumber(latest.averageLitterSize),
                  ),
                  _MetricDefinition(
                    label: 'Sevrage',
                    value: _formatPercent(latest.weaningRate),
                  ),
                  _MetricDefinition(
                    label: 'Mortalite',
                    value: _formatPercent(latest.preweaningMortalityRate),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ReproductionTable(rows: rows),
            ],
          ),
        );
      },
    );
  }
}

class _GrowthTab extends StatelessWidget {
  const _GrowthTab({required this.profileId});

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (BuildContext context, ReportsState state) {
        if (state.status == ReportsStatus.loading && state.bundle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ReportsStatus.failure) {
          return _ErrorView(
            message:
                state.errorMessage ?? 'Impossible de charger les rapports.',
            onRetry: profileId == null
                ? null
                : () => context.read<ReportsCubit>().refresh(
                    profileId: profileId!,
                  ),
          );
        }
        final List<GrowthReportRow> rows =
            state.bundle?.growth ?? <GrowthReportRow>[];
        if (rows.isEmpty) {
          return const _EmptyView(
            message: 'Aucun indicateur de croissance pour cette periode.',
          );
        }
        final GrowthReportRow latest = rows.last;
        final List<FlSpot> weightSpots = _toSpots(
          rows,
          (GrowthReportRow row) => (row.averageWeaningWeightKg ?? 0) * 1000,
        );
        final List<String> labels = rows
            .map((GrowthReportRow row) {
              return DateFormat('MM/yy').format(row.periodStart);
            })
            .toList(growable: false);

        return RefreshIndicator(
          onRefresh: profileId == null
              ? () async {}
              : () =>
                    context.read<ReportsCubit>().refresh(profileId: profileId!),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _ReportChartCard(
                title: 'Poids moyen au sevrage',
                subtitle: 'Gramme par periode',
                spots: weightSpots,
                labels: labels,
                valueSuffix: 'g',
              ),
              const SizedBox(height: 16),
              _MetricWrap(
                metrics: <_MetricDefinition>[
                  _MetricDefinition(
                    label: 'Age sevrage',
                    value: _formatNumber(latest.averageWeaningAgeDays),
                    helper: 'Jours moyens',
                  ),
                  _MetricDefinition(
                    label: 'Poids sevrage',
                    value: _formatNumber(latest.averageWeaningWeightKg),
                    helper: 'kg',
                  ),
                  _MetricDefinition(
                    label: 'Gain quotidien',
                    value: _formatNumber(latest.averageDailyGainKg) == '--'
                        ? '--'
                        : '${_formatNumber(latest.averageDailyGainKg)} kg',
                  ),
                  _MetricDefinition(
                    label: 'Retention 12 sem',
                    value: _formatPercent(latest.twelveWeekRetentionRate),
                  ),
                  _MetricDefinition(
                    label: 'Kits sevres',
                    value: latest.kitsWeaned.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _GrowthTable(rows: rows),
            ],
          ),
        );
      },
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab({required this.profileId});

  final String? profileId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (BuildContext context, ReportsState state) {
        if (state.status == ReportsStatus.loading && state.bundle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ReportsStatus.failure) {
          return _ErrorView(
            message:
                state.errorMessage ?? 'Impossible de charger les rapports.',
            onRetry: profileId == null
                ? null
                : () => context.read<ReportsCubit>().refresh(
                    profileId: profileId!,
                  ),
          );
        }
        final ReportsBundle? bundle = state.bundle;
        final List<FinanceReportRow> rows =
            bundle?.finances ?? <FinanceReportRow>[];
        if (bundle == null || rows.isEmpty) {
          return const _EmptyView(
            message: 'Aucun mouvement financier pour la periode.',
          );
        }
        final FinanceReportRow latest = rows.last;
        final List<FlSpot> marginSpots = _toSpots(
          rows,
          (FinanceReportRow row) => row.netMargin / 1000,
        );
        final List<String> labels = rows
            .map((FinanceReportRow row) {
              return DateFormat('MM/yy').format(row.periodStart);
            })
            .toList(growable: false);
        final NumberFormat currency = NumberFormat.currency(
          locale: 'fr',
          symbol: 'FCFA',
          decimalDigits: 0,
        );

        return RefreshIndicator(
          onRefresh: profileId == null
              ? () async {}
              : () =>
                    context.read<ReportsCubit>().refresh(profileId: profileId!),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _ReportChartCard(
                title: 'Marge nette',
                subtitle: 'en milliers FCFA',
                spots: marginSpots,
                labels: labels,
                valueSuffix: 'k',
              ),
              const SizedBox(height: 16),
              _MetricWrap(
                metrics: <_MetricDefinition>[
                  _MetricDefinition(
                    label: 'Recettes',
                    value: currency.format(bundle.summary.incomeTotal),
                  ),
                  _MetricDefinition(
                    label: 'Depenses',
                    value: currency.format(bundle.summary.expenseTotal),
                  ),
                  _MetricDefinition(
                    label: 'Marge nette',
                    value: currency.format(bundle.summary.netMargin),
                  ),
                  _MetricDefinition(
                    label: 'Cout alim/portee',
                    value: latest.feedCostPerWeaned == null
                        ? '--'
                        : currency.format(latest.feedCostPerWeaned),
                  ),
                  _MetricDefinition(
                    label: 'Revenu/doe',
                    value: latest.revenuePerActiveDoe == null
                        ? '--'
                        : currency.format(latest.revenuePerActiveDoe),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FinanceTable(rows: rows),
            ],
          ),
        );
      },
    );
  }
}

class _ReportChartCard extends StatelessWidget {
  const _ReportChartCard({
    required this.title,
    required this.subtitle,
    required this.spots,
    required this.labels,
    required this.valueSuffix,
  });

  final String title;
  final String subtitle;
  final List<FlSpot> spots;
  final List<String> labels;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: spots.isEmpty
                  ? const Center(child: Text('Pas assez de donnees'))
                  : LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: spots.length >= 3 ? null : 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '${value.toStringAsFixed(0)}$valueSuffix',
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final int index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    labels[index],
                                    style: theme.textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        minX: 0,
                        maxX: (spots.length - 1).toDouble(),
                        lineBarsData: <LineChartBarData>[
                          LineChartBarData(
                            spots: spots,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            isCurved: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDefinition {
  const _MetricDefinition({
    required this.label,
    required this.value,
    this.helper,
  });

  final String label;
  final String value;
  final String? helper;
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.metrics});

  final List<_MetricDefinition> metrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (_MetricDefinition metric) => Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(metric.label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (metric.helper != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(metric.helper!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ReproductionTable extends StatelessWidget {
  const _ReproductionTable({required this.rows});

  final List<ReproductionReportRow> rows;

  @override
  Widget build(BuildContext context) {
    final NumberFormat percent = NumberFormat('0.0', 'fr');
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      columns: const <DataColumn>[
        DataColumn(label: Text('Periode')),
        DataColumn(label: Text('Saillies')),
        DataColumn(label: Text('Fertilite')),
        DataColumn(label: Text('Mises bas')),
        DataColumn(label: Text('Kits sevres')),
        DataColumn(label: Text('Taille portee')),
        DataColumn(label: Text('Sevrage')),
      ],
      rows: rows
          .map(
            (ReproductionReportRow row) => DataRow(
              cells: <DataCell>[
                DataCell(Text(row.label)),
                DataCell(Text(row.totalMatings.toString())),
                DataCell(Text('${percent.format(row.fertilityRate * 100)} %')),
                DataCell(Text(row.kindlings.toString())),
                DataCell(Text(row.kitsWeaned.toString())),
                DataCell(Text(_formatNumber(row.averageLitterSize))),
                DataCell(Text(_formatPercent(row.weaningRate))),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _GrowthTable extends StatelessWidget {
  const _GrowthTable({required this.rows});

  final List<GrowthReportRow> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      columns: const <DataColumn>[
        DataColumn(label: Text('Periode')),
        DataColumn(label: Text('Age sevrage (j)')),
        DataColumn(label: Text('Poids sevrage (kg)')),
        DataColumn(label: Text('Gain quotidien (g)')),
        DataColumn(label: Text('Kits sevres')),
        DataColumn(label: Text('Retention 12 sem')),
      ],
      rows: rows
          .map(
            (GrowthReportRow row) => DataRow(
              cells: <DataCell>[
                DataCell(Text(row.label)),
                DataCell(Text(_formatNumber(row.averageWeaningAgeDays))),
                DataCell(Text(_formatNumber(row.averageWeaningWeightKg))),
                DataCell(Text(_formatGain(row.averageDailyGainKg))),
                DataCell(Text(row.kitsWeaned.toString())),
                DataCell(Text(_formatPercent(row.twelveWeekRetentionRate))),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FinanceTable extends StatelessWidget {
  const _FinanceTable({required this.rows});

  final List<FinanceReportRow> rows;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currency = NumberFormat.currency(
      locale: 'fr',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      columns: const <DataColumn>[
        DataColumn(label: Text('Periode')),
        DataColumn(label: Text('Recettes')),
        DataColumn(label: Text('Depenses')),
        DataColumn(label: Text('Marge')),
        DataColumn(label: Text('Femelles actives')),
        DataColumn(label: Text('Kits sevres')),
      ],
      rows: rows
          .map(
            (FinanceReportRow row) => DataRow(
              cells: <DataCell>[
                DataCell(Text(row.label)),
                DataCell(Text(currency.format(row.incomeTotal))),
                DataCell(Text(currency.format(row.expenseTotal))),
                DataCell(Text(currency.format(row.netMargin))),
                DataCell(Text(row.femaleActive.toString())),
                DataCell(Text(row.kitsWeaned.toString())),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.warning_amber_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.insights_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

List<FlSpot> _toSpots<T>(List<T> rows, double Function(T row) valueSelector) {
  final List<FlSpot> spots = <FlSpot>[];
  for (int index = 0; index < rows.length; index += 1) {
    final double value = valueSelector(rows[index]);
    spots.add(FlSpot(index.toDouble(), value));
  }
  return spots;
}

String _formatPercent(double? value) {
  if (value == null) {
    return '--';
  }
  return '${NumberFormat('0.0', 'fr').format(value * 100)} %';
}

String _formatNumber(double? value) {
  if (value == null) {
    return '--';
  }
  return NumberFormat('0.0', 'fr').format(value);
}

String _formatGain(double? value) {
  if (value == null) {
    return '--';
  }
  return '${NumberFormat('0.0', 'fr').format(value * 1000)} g';
}
