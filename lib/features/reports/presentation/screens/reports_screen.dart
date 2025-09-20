import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../animals/presentation/cubit/animal_cubit.dart';
import '../../../events/presentation/cubit/breeding_cubit.dart';
import '../../widgets/productivity_report_screen.dart';

enum ReportPeriod { threeMonths, sixMonths, twelveMonths }

extension on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.threeMonths:
        return '3 mois';
      case ReportPeriod.sixMonths:
        return '6 mois';
      case ReportPeriod.twelveMonths:
        return '12 mois';
    }
  }

  Duration get duration {
    switch (this) {
      case ReportPeriod.threeMonths:
        return const Duration(days: 90);
      case ReportPeriod.sixMonths:
        return const Duration(days: 182);
      case ReportPeriod.twelveMonths:
        return const Duration(days: 365);
    }
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<BreedingCubit>(
          create: (BuildContext context) => BreedingCubit(
            InMemoryBreedingRepository(),
            InMemoryAnimalRepository(),
          )..loadData(),
        ),
        BlocProvider<AnimalCubit>(
          create: (BuildContext context) =>
              AnimalCubit(InMemoryAnimalRepository())..fetchAnimals(),
        ),
      ],
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
  ReportPeriod _period = ReportPeriod.sixMonths;
  String _sexFilter = 'Tous';
  String? _breederId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
      ),
      body: BlocBuilder<BreedingCubit, BreedingState>(
        builder: (BuildContext context, BreedingState breedingState) {
          return BlocBuilder<AnimalCubit, AnimalState>(
            builder: (BuildContext context, AnimalState animalState) {
              if (breedingState.status == BreedingStatus.loading ||
                  animalState.status == AnimalStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (breedingState.status == BreedingStatus.failure) {
                return _ErrorPlaceholder(message: breedingState.errorMessage);
              }
              if (animalState.status == AnimalStatus.failure) {
                return _ErrorPlaceholder(message: animalState.errorMessage);
              }

              final Map<String, Animal> animalsById =
                  <String, Animal>{for (final Animal animal in animalState.allAnimals) animal.id: animal};
              final List<BreedingRecord> filteredRecords =
                  _filterRecords(breedingState.records, animalsById);
              final List<_MonthlyMetric> metrics =
                  _buildMonthlyMetrics(filteredRecords);
              final List<_BreederPerformance> performances =
                  _buildBreederPerformances(filteredRecords, animalsById);

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<BreedingCubit>().loadData();
                  await context.read<AnimalCubit>().fetchAnimals();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _FiltersRow(
                      period: _period,
                      sexFilter: _sexFilter,
                      breederId: _breederId,
                      animals: animalState.animals,
                      onPeriodChanged: (ReportPeriod value) =>
                          setState(() => _period = value),
                      onSexChanged: (String value) =>
                          setState(() => _sexFilter = value),
                      onBreederChanged: (String? value) =>
                          setState(() => _breederId = value),
                    ),
                    const SizedBox(height: 16),
                    FertilityChartCard(metrics: metrics),
                    const SizedBox(height: 16),
                    LitterSizeChartCard(metrics: metrics),
                    const SizedBox(height: 16),
                    BreederPerformanceCard(
                      performances: performances,
                      animalsById: animalsById,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: const Icon(Icons.trending_up),
                      title: const Text('Rapport de productivité détaillé'),
                      subtitle: const Text(
                        'Comparer les performances des reproducteurs et identifier les sujets à surveiller.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<Widget>(
                            builder: (BuildContext context) =>
                                ProductivityReportScreen(
                              animals: animalState.allAnimals,
                              records: breedingState.records,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  DateTime get _startDate {
    final DateTime now = DateTime.now();
    return now.subtract(_period.duration);
  }

  List<BreedingRecord> _filterRecords(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final DateTime start = _startDate;
    return records.where((BreedingRecord record) {
      if (record.matingDate.isBefore(start)) {
        return false;
      }
      final bool matchesBreeder = _breederId == null
          ? true
          : record.doeId == _breederId || record.buckId == _breederId;
      if (!matchesBreeder) {
        return false;
      }
      switch (_sexFilter) {
        case 'Femelle':
          final Animal? doe = animalsById[record.doeId];
          return doe?.sex.toLowerCase().contains('fem') ?? false;
        case 'Mâle':
          final Animal? buck = animalsById[record.buckId];
          final String? sex = buck?.sex.toLowerCase();
          return sex != null && (sex.contains('mâ') || sex.contains('mal'));
        default:
          return true;
      }
    }).toList();
  }

  List<_MonthlyMetric> _buildMonthlyMetrics(List<BreedingRecord> records) {
    final Map<DateTime, _MonthlyAccumulator> buckets =
        <DateTime, _MonthlyAccumulator>{};
    for (final BreedingRecord record in records) {
      final DateTime key = DateTime(record.matingDate.year, record.matingDate.month);
      final _MonthlyAccumulator acc =
          buckets.putIfAbsent(key, _MonthlyAccumulator.new);
      acc.totalMatings += 1;
      if (record.palpationPositive == true) {
        acc.successfulMatings += 1;
      }
      if (record.kitsBornAlive != null) {
        acc.totalBorn += record.kitsBornAlive!;
        acc.bornCount += 1;
      }
      if (record.kitsWeaned != null) {
        acc.totalWeaned += record.kitsWeaned!;
        acc.weanedCount += 1;
      }
    }

    final List<DateTime> months = buckets.keys.toList()
      ..sort((DateTime a, DateTime b) => a.compareTo(b));
    return <_MonthlyMetric>[
      for (final DateTime month in months)
        _MonthlyMetric(
          month: month,
          successRate: buckets[month]!.successRate,
          averageBorn: buckets[month]!.averageBorn,
          averageWeaned: buckets[month]!.averageWeaned,
        ),
    ];
  }

  List<_BreederPerformance> _buildBreederPerformances(
    List<BreedingRecord> records,
    Map<String, Animal> animalsById,
  ) {
    final Map<String, _BreederAccumulator> map =
        <String, _BreederAccumulator>{};
    void track(String? id, bool success, int? weaned) {
      if (id == null) {
        return;
      }
      final _BreederAccumulator acc =
          map.putIfAbsent(id, _BreederAccumulator.new);
      acc.totalMatings += 1;
      if (success) {
        acc.successfulMatings += 1;
      }
      if (weaned != null) {
        acc.totalWeaned += weaned;
      }
    }

    for (final BreedingRecord record in records) {
      final bool success = record.palpationPositive == true;
      track(record.doeId, success, record.kitsWeaned);
      track(record.buckId, success, record.kitsWeaned);
    }

    final List<_BreederPerformance> performances = <_BreederPerformance>[
      for (final MapEntry<String, _BreederAccumulator> entry in map.entries)
        _BreederPerformance(
          animal: animalsById[entry.key],
          animalId: entry.key,
          totalMatings: entry.value.totalMatings,
          successRate: entry.value.successRate,
          totalWeaned: entry.value.totalWeaned,
        ),
    ]
      ..sort((_BreederPerformance a, _BreederPerformance b) =>
          b.successRate.compareTo(a.successRate));

    return performances.take(6).toList();
  }
}

class FertilityChartCard extends StatelessWidget {
  const FertilityChartCard({required this.metrics, super.key});

  final List<_MonthlyMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: metrics.isEmpty
            ? const _EmptyReportPlaceholder(
                title: 'Taux de fertilité',
                description:
                    'Aucune donnée de saillie sur la période sélectionnée.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Taux de fertilité', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        backgroundColor:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final int index = value.toInt();
                                if (index < 0 || index >= metrics.length) {
                                  return const SizedBox.shrink();
                                }
                                final DateTime month = metrics[index].month;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('${month.month}/${month.year % 100}'),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text('${(value * 100).round()}%');
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
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots
                                  .map(
                                    (LineBarSpot spot) => LineTooltipItem(
                                      '${metrics[spot.x.toInt()].month.month}/${metrics[spot.x.toInt()].month.year} : ${(spot.y * 100).toStringAsFixed(1)}%\n',
                                      theme.textTheme.bodyMedium!,
                                    ),
                                  )
                                  .toList();
                            },
                          ),
                        ),
                        lineBarsData: <LineChartBarData>[
                          LineChartBarData(
                            color: theme.colorScheme.primary,
                            isCurved: true,
                            barWidth: 3,
                            spots: <FlSpot>[
                              for (int i = 0; i < metrics.length; i++)
                                FlSpot(i.toDouble(), metrics[i].successRate ?? 0),
                            ],
                            dotData: const FlDotData(show: false),
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

  final List<_MonthlyMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: metrics.isEmpty
            ? const _EmptyReportPlaceholder(
                title: 'Taille moyenne des portées',
                description: 'Aucune mise bas enregistrée sur la période.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Taille moyenne des portées',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
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
                                  child: Text('${month.month}/${month.year % 100}'),
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
                        barGroups: <BarChartGroupData>[
                          for (int i = 0; i < metrics.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: <BarChartRodData>[
                                BarChartRodData(
                                  toY: metrics[i].averageBorn ?? 0,
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(6),
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

class BreederPerformanceCard extends StatelessWidget {
  const BreederPerformanceCard({
    required this.performances,
    required this.animalsById,
    super.key,
  });

  final List<_BreederPerformance> performances;
  final Map<String, Animal> animalsById;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: performances.isEmpty
            ? const _EmptyReportPlaceholder(
                title: 'Performances par reproducteur',
                description: 'Aucune statistique disponible pour cette période.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Performances par reproducteur',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final _BreederPerformance performance in performances)
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

class _BreederTile extends StatelessWidget {
  const _BreederTile({required this.performance, this.animal});

  final _BreederPerformance performance;
  final Animal? animal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = animal == null
        ? performance.animalId
        : '${animal!.tagId}${animal!.name != null ? ' · ${animal!.name}' : ''}';
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
        LinearProgressIndicator(
          value: performance.successRate,
          minHeight: 6,
          backgroundColor: theme.colorScheme.surfaceVariant,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          '${performance.totalMatings} saillies · ${performance.totalWeaned} sevrés',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow({
    required this.period,
    required this.sexFilter,
    required this.breederId,
    required this.animals,
    required this.onPeriodChanged,
    required this.onSexChanged,
    required this.onBreederChanged,
  });

  final ReportPeriod period;
  final String sexFilter;
  final String? breederId;
  final List<Animal> animals;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final ValueChanged<String> onSexChanged;
  final ValueChanged<String?> onBreederChanged;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<ReportPeriod>> periodItems = ReportPeriod.values
        .map(
          (ReportPeriod value) => DropdownMenuItem<ReportPeriod>(
            value: value,
            child: Text(value.label),
          ),
        )
        .toList();

    final List<DropdownMenuItem<String?>> breederItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Tous les reproducteurs')),
      ...animals.map(
        (Animal animal) => DropdownMenuItem<String?>(
          value: animal.id,
          child: Text(
            '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
          ),
        ),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<ReportPeriod>(
            value: period,
            decoration: const InputDecoration(labelText: 'Période'),
            items: periodItems,
            onChanged: (ReportPeriod? value) {
              if (value != null) {
                onPeriodChanged(value);
              }
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: sexFilter,
            decoration: const InputDecoration(labelText: 'Sexe'),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'Tous', child: Text('Tous')),
              DropdownMenuItem<String>(value: 'Femelle', child: Text('Femelles')),
              DropdownMenuItem<String>(value: 'Mâle', child: Text('Mâles')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                onSexChanged(value);
              }
            },
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String?>(
            value: breederId,
            decoration: const InputDecoration(labelText: 'Reproducteur'),
            items: breederItems,
            onChanged: onBreederChanged,
          ),
        ),
      ],
    );
  }
}

class _MonthlyAccumulator {
  int totalMatings = 0;
  int successfulMatings = 0;
  int totalBorn = 0;
  int bornCount = 0;
  int totalWeaned = 0;
  int weanedCount = 0;

  double? get successRate =>
      totalMatings == 0 ? null : successfulMatings / totalMatings;
  double? get averageBorn => bornCount == 0 ? null : totalBorn / bornCount;
  double? get averageWeaned => weanedCount == 0 ? null : totalWeaned / weanedCount;
}

class _MonthlyMetric {
  const _MonthlyMetric({
    required this.month,
    this.successRate,
    this.averageBorn,
    this.averageWeaned,
  });

  final DateTime month;
  final double? successRate;
  final double? averageBorn;
  final double? averageWeaned;
}

class _BreederAccumulator {
  int totalMatings = 0;
  int successfulMatings = 0;
  int totalWeaned = 0;

  double get successRate =>
      totalMatings == 0 ? 0 : successfulMatings / totalMatings;
}

class _BreederPerformance {
  const _BreederPerformance({
    required this.animalId,
    required this.totalMatings,
    required this.successRate,
    required this.totalWeaned,
    this.animal,
  });

  final String animalId;
  final int totalMatings;
  final double successRate;
  final int totalWeaned;
  final Animal? animal;
}

class _EmptyReportPlaceholder extends StatelessWidget {
  const _EmptyReportPlaceholder({
    required this.title,
    required this.description,
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

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({this.message});

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
