import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/services/reporting_service.dart';
import '../../../../data/repositories/food_inventory_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../widgets/productivity_report_screen.dart';
import '../cubit/report_cubit.dart';
import '../../services/report_export_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportCubit>(
      create: (BuildContext context) => ReportCubit(
        context.read<ReportingService>(),
      ),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  final GlobalKey _fertilityKey = GlobalKey();
  final GlobalKey _litterKey = GlobalKey();
  final ReportExportService _exportService = ReportExportService();
  bool _exportInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final ReportCubit cubit = context.read<ReportCubit>();
    final AuthState authState = context.read<AuthCubit>().state;
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;
    await cubit.load(profileId: profileId, forceRefresh: forceRefresh);
  }

  Future<void> _onRefresh() async {
    final AuthState authState = context.read<AuthCubit>().state;
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;
    await context
        .read<ReportCubit>()
        .load(profileId: profileId, forceRefresh: true);
  }

  Future<void> _showExportSheet(ReportState state) async {
    if (!state.canExport || _exportInProgress) {
      return;
    }
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exporter en PDF'),
                onTap: () => Navigator.of(context).pop('pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('Exporter en CSV'),
                onTap: () => Navigator.of(context).pop('csv'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || choice == null) {
      return;
    }
    if (choice == 'pdf') {
      await _exportPdf(state);
    } else if (choice == 'csv') {
      await _exportCsv(state);
    }
  }

  Future<void> _exportPdf(ReportState state) async {
    setState(() => _exportInProgress = true);
    try {
      final Uint8List? fertility = await _captureChart(_fertilityKey);
      final Uint8List? litter = await _captureChart(_litterKey);
      await _exportService.sharePdf(
        state: state,
        fertilityChart: fertility,
        litterChart: litter,
      );
      if (mounted) {
        _showSnack('PDF genere avec succes.');
      }
    } catch (error) {
      if (mounted) {
        _showSnack('Echec export PDF: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _exportInProgress = false);
      }
    }
  }

  Future<void> _exportCsv(ReportState state) async {
    setState(() => _exportInProgress = true);
    try {
      await _exportService.shareCsv(state: state);
      if (mounted) {
        _showSnack('CSV genere avec succes.');
      }
    } catch (error) {
      if (mounted) {
        _showSnack('Echec export CSV: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _exportInProgress = false);
      }
    }
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return null;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (BuildContext context, ReportState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapports'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Exporter',
                icon: _exportInProgress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_outlined),
                onPressed: state.canExport && !_exportInProgress
                    ? () => _showExportSheet(state)
                    : null,
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ReportState state) {
    switch (state.status) {
      case ReportStatus.initial:
      case ReportStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ReportStatus.failure:
        return ErrorPlaceholder(message: state.errorMessage);
      case ReportStatus.success:
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: <Widget>[
              _FiltersPanel(state: state),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: _fertilityKey,
                child: FertilityChartCard(metrics: state.viewData.monthlyMetrics),
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: _litterKey,
                child: LitterSizeChartCard(metrics: state.viewData.monthlyMetrics),
              ),
              const SizedBox(height: 16),
              BreederPerformanceCard(
                performances: state.viewData.topPerformances,
                animalsById: state.viewData.animalsById,
              ),
              const SizedBox(height: 16),
              EventSummaryCard(
                counts: state.viewData.eventCountsByType,
                range: state.viewData.range,
              ),
              const SizedBox(height: 16),
              InventorySummaryCard(summary: state.viewData.inventorySummary),
              const SizedBox(height: 16),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.trending_up),
                title: const Text('Rapport de productivite detaille'),
                subtitle: const Text(
                  'Comparer les performances des reproducteurs sur la periode selectionnee.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => BlocProvider.value(
                        value: BlocProvider.of<ReportCubit>(context),
                        child: const ProductivityReportScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
    }
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({required this.state});

  final ReportState state;

  @override
  Widget build(BuildContext context) {
    final ReportCubit cubit = context.read<ReportCubit>();
    final DateFormat dateLabel = DateFormat.yMMMd('fr');
    final ThemeData theme = Theme.of(context);

    final List<DropdownMenuEntry<ReportPeriod>> periodEntries =
        ReportPeriod.values
            .map(
              (ReportPeriod value) => DropdownMenuEntry<ReportPeriod>(
                value: value,
                label: value.label,
              ),
            )
            .toList();

    final List<DropdownMenuEntry<SexFilterOption>> sexEntries =
        <SexFilterOption>[
      SexFilterOption.all,
      SexFilterOption.female,
      SexFilterOption.male,
    ]
            .map(
              (SexFilterOption option) => DropdownMenuEntry<SexFilterOption>(
                value: option,
                label: _sexLabel(option),
              ),
            )
            .toList();

    final List<DropdownMenuEntry<String?>> breederEntries =
        <DropdownMenuEntry<String?>>[
      const DropdownMenuEntry<String?>(
        value: null,
        label: 'Tous les reproducteurs',
      ),
      for (final Animal animal in state.viewData.availableBreeders)
        DropdownMenuEntry<String?>(
          value: animal.id,
          label: _animalLabel(animal),
        ),
    ];

    final List<DropdownMenuEntry<String?>> lotEntries =
        <DropdownMenuEntry<String?>>[
      const DropdownMenuEntry<String?>(
        value: null,
        label: 'Tous les lots',
      ),
      for (final String lot in state.viewData.availableLots)
        DropdownMenuEntry<String?>(value: lot, label: lot),
    ];

    final List<DropdownMenuEntry<String?>> locationEntries =
        <DropdownMenuEntry<String?>>[
      const DropdownMenuEntry<String?>(
        value: null,
        label: 'Toutes les localisations',
      ),
      for (final String location in state.viewData.availableLocations)
        DropdownMenuEntry<String?>(value: location, label: location),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Filtres',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: DropdownMenu<ReportPeriod>(
                    initialSelection: state.period,
                    label: const Text('Periode'),
                    dropdownMenuEntries: periodEntries,
                    onSelected: (ReportPeriod? value) {
                      if (value != null) {
                        cubit.updatePeriod(value);
                      }
                    },
                  ),
                ),
                if (state.period == ReportPeriod.custom)
                  SizedBox(
                    width: 220,
                    child: OutlinedButton(
                      onPressed: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          locale: const Locale('fr'),
                          initialDateRange:
                              state.customRange ?? state.viewData.range,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365 * 3),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          cubit.updateCustomRange(picked);
                        }
                      },
                      child: Text(
                        '${dateLabel.format(state.viewData.range.start)} - '
                        '${dateLabel.format(state.viewData.range.end)}',
                      ),
                    ),
                  ),
                SizedBox(
                  width: 200,
                  child: DropdownMenu<SexFilterOption>(
                    initialSelection: state.sexFilter,
                    label: const Text('Sexe'),
                    dropdownMenuEntries: sexEntries,
                    onSelected: (SexFilterOption? value) {
                      if (value != null) {
                        cubit.updateSexFilter(value);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownMenu<String?>(
                    initialSelection: state.selectedBreederId,
                    label: const Text('Reproducteur'),
                    dropdownMenuEntries: breederEntries,
                    onSelected: cubit.updateBreeder,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownMenu<String?>(
                    initialSelection: state.selectedLot,
                    label: const Text('Lot'),
                    dropdownMenuEntries: lotEntries,
                    onSelected: cubit.updateLot,
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownMenu<String?>(
                    initialSelection: state.selectedLocation,
                    label: const Text('Localisation'),
                    dropdownMenuEntries: locationEntries,
                    onSelected: cubit.updateLocation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Astuce: utilisez le bouton partager dans la barre d\'application pour generer un PDF ou un CSV.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _sexLabel(SexFilterOption option) {
    switch (option) {
      case SexFilterOption.all:
        return 'Tous';
      case SexFilterOption.female:
        return 'Femelles';
      case SexFilterOption.male:
        return 'Males';
    }
  }

  static String _animalLabel(Animal animal) {
    return animal.name == null || animal.name!.isEmpty
        ? animal.tagId
        : '${animal.tagId} - ${animal.name}';
  }
}

class FertilityChartCard extends StatelessWidget {
  const FertilityChartCard({required this.metrics, super.key});

  final List<MonthlyMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat monthFormat = DateFormat.MMM('fr');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: metrics.isEmpty
            ? const EmptyReportPlaceholder(
                title: 'Taux de fertilite',
                description: 'Aucune donnee pour la periode selectionnee.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Taux de fertilite', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final int index = value.toInt();
                                if (index < 0 || index >= metrics.length) {
                                  return const SizedBox.shrink();
                                }
                                final DateTime month = metrics[index].month;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    monthFormat.format(month),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text('${(value * 100).round()} %');
                              },
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        minY: 0,
                        maxY: 1,
                        lineBarsData: <LineChartBarData>[
                          LineChartBarData(
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            spots: <FlSpot>[
                              for (int i = 0; i < metrics.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  metrics[i].successRate,
                                ),
                            ],
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

class LitterSizeChartCard extends StatelessWidget {
  const LitterSizeChartCard({required this.metrics, super.key});

  final List<MonthlyMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat monthFormat = DateFormat.MMM('fr');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: metrics.isEmpty
            ? const EmptyReportPlaceholder(
                title: 'Taille moyenne des portees',
                description: 'Aucune mise bas pour la periode selectionnee.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Taille moyenne des portees',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(show: false),
                        barGroups: <BarChartGroupData>[
                          for (int i = 0; i < metrics.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: <BarChartRodData>[
                                BarChartRodData(
                                  toY: (metrics[i].averageBorn ?? 0).toDouble(),
                                  color: theme.colorScheme.secondary,
                                  width: 12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                if (metrics[i].averageWeaned != null)
                                  BarChartRodData(
                                    toY: metrics[i].averageWeaned!.toDouble(),
                                    color: theme.colorScheme.tertiary,
                                    width: 12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                              ],
                            ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final int index = value.toInt();
                                if (index < 0 || index >= metrics.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    monthFormat.format(metrics[index].month),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(value.toStringAsFixed(0));
                              },
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Naissances en secondaire, sevrages en tertiaire.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}

class BreederPerformanceCard extends StatelessWidget {
  const BreederPerformanceCard({
    required this.performances,
    required this.animalsById,
    super.key,
  });

  final List<BreederPerformance> performances;
  final Map<String, Animal> animalsById;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: performances.isEmpty
            ? const EmptyReportPlaceholder(
                title: 'Performances par reproducteur',
                description: 'Aucune statistique disponible pour cette periode.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Performances par reproducteur',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final BreederPerformance performance in performances)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _BreederTile(
                        performance: performance,
                        animal: animalsById[performance.animalId],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class EventSummaryCard extends StatelessWidget {
  const EventSummaryCard({
    required this.counts,
    required this.range,
    super.key,
  });

  final Map<String, int> counts;
  final DateTimeRange range;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.MMMd('fr');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: counts.isEmpty
            ? const EmptyReportPlaceholder(
                title: 'Activite evenementielle',
                description: 'Aucun evenement correspondant aux filtres.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Activite evenementielle', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(range.start)} - ${dateFormat.format(range.end)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      for (final MapEntry<String, int> entry
                          in counts.entries.toList()
                            ..sort(
                              (MapEntry<String, int> a, MapEntry<String, int> b) =>
                                  b.value.compareTo(a.value),
                            ))
                        Chip(
                          avatar: const Icon(Icons.event),
                          label: Text('${_formatEventType(entry.key)} (${entry.value})'),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  static String _formatEventType(String raw) {
    if (raw.isEmpty) {
      return 'Autre';
    }
    final String spaced = raw.replaceAll('_', ' ');
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}

class InventorySummaryCard extends StatelessWidget {
  const InventorySummaryCard({required this.summary, super.key});

  final InventorySummary? summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat numberFormat = NumberFormat.decimalPattern('fr');
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'fr', symbol: '€');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: summary == null
            ? const EmptyReportPlaceholder(
                title: 'Inventaire aliments',
                description:
                    'Aucune donnee de stock. Ajoutez vos achats pour suivre les volumes.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Inventaire aliments', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _SummaryBadge(
                        icon: Icons.scale,
                        label: 'Quantite totale',
                        value: '${numberFormat.format(summary!.totalQuantityKg)} kg',
                      ),
                      _SummaryBadge(
                        icon: Icons.inventory_2_outlined,
                        label: 'Entrees',
                        value: numberFormat.format(summary!.entriesCount),
                      ),
                      _SummaryBadge(
                        icon: Icons.local_atm_outlined,
                        label: 'Valeur estimee',
                        value: currencyFormat.format(summary!.totalCost),
                      ),
                      _SummaryBadge(
                        icon: Icons.bolt_outlined,
                        label: 'Conso mensuelle',
                        value:
                            '${numberFormat.format(summary!.estimatedMonthlyConsumptionKg)} kg',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: theme.textTheme.labelSmall),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _BreederTile extends StatelessWidget {
  const _BreederTile({required this.performance, this.animal});

  final BreederPerformance performance;
  final Animal? animal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title =
        animal == null ? performance.animalId : _FiltersPanel._animalLabel(animal!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              '${(performance.successRate * 100).toStringAsFixed(0)} %',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          children: <Widget>[
            Chip(
              label: Text('Saillies: ${performance.totalMatings}'),
            ),
            Chip(
              label: Text('Sevres: ${performance.totalWeaned}'),
            ),
          ],
        ),
      ],
    );
  }
}

class EmptyReportPlaceholder extends StatelessWidget {
  const EmptyReportPlaceholder({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.warning_amber, size: 48),
            const SizedBox(height: 12),
            Text(
              message ?? 'Impossible de charger les rapports.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
