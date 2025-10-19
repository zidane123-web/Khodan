import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/animal.dart';
import '../../../data/models/breeding_record.dart';
import '../presentation/cubit/report_cubit.dart';
import '../../../data/services/reporting_service.dart';

class ProductivityReportScreen extends StatefulWidget {
  const ProductivityReportScreen({super.key});

  @override
  State<ProductivityReportScreen> createState() => _ProductivityReportScreenState();
}

class _ProductivityReportScreenState extends State<ProductivityReportScreen> {
  SexFilterOption _sexFilter = SexFilterOption.all;
  ProductivitySort _sort = ProductivitySort.success;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (BuildContext context, ReportState state) {
        switch (state.status) {
          case ReportStatus.initial:
          case ReportStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
      case ReportStatus.failure:
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rapport de productivite'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.errorMessage ?? 'Impossible de charger le rapport.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
          case ReportStatus.success:
            return _buildContent(context, state);
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, ReportState state) {
    final ThemeData theme = Theme.of(context);
    final ReportDataset dataset = state.dataset!;
    final NumberFormat numberFormat = NumberFormat.decimalPattern('fr');
    const List<DropdownMenuEntry<SexFilterOption>> sexEntries =
        <DropdownMenuEntry<SexFilterOption>>[
      DropdownMenuEntry<SexFilterOption>(
        value: SexFilterOption.all,
        label: 'Tous',
      ),
      DropdownMenuEntry<SexFilterOption>(
        value: SexFilterOption.female,
        label: 'Femelles',
      ),
      DropdownMenuEntry<SexFilterOption>(
        value: SexFilterOption.male,
        label: 'Males',
      ),
    ];
    const List<DropdownMenuEntry<ProductivitySort>> sortEntries =
        <DropdownMenuEntry<ProductivitySort>>[
      DropdownMenuEntry<ProductivitySort>(
        value: ProductivitySort.success,
        label: 'Par taux de succes',
      ),
      DropdownMenuEntry<ProductivitySort>(
        value: ProductivitySort.weaned,
        label: 'Par sevrages cumules',
      ),
      DropdownMenuEntry<ProductivitySort>(
        value: ProductivitySort.matings,
        label: 'Par saillies',
      ),
    ];

    final List<_ProductivityStats> stats = _buildStats(
      animals: state.viewData.filteredAnimals,
      records: state.viewData.filteredRecords,
      lotsByAnimal: dataset.animalLots,
      locationsByAnimal: dataset.animalLocations,
    );

    final Iterable<_ProductivityStats> filtered = stats.where((_ProductivityStats stat) {
      if (_sexFilter != SexFilterOption.all) {
        final bool isDoe = stat.isFemale;
        if (_sexFilter == SexFilterOption.female && !isDoe) {
          return false;
        }
        if (_sexFilter == SexFilterOption.male && isDoe) {
          return false;
        }
      }
      if (_query.isEmpty) {
        return true;
      }
      final String normalized = _query.toLowerCase();
      return stat.animal.tagId.toLowerCase().contains(normalized) ||
          (stat.animal.name?.toLowerCase().contains(normalized) ?? false);
    });

    final List<_ProductivityStats> ordered = filtered.toList()
      ..sort(( _ProductivityStats a, _ProductivityStats b) {
        switch (_sort) {
          case ProductivitySort.success:
            return b.successRate.compareTo(a.successRate);
          case ProductivitySort.weaned:
            return b.totalWeaned.compareTo(a.totalWeaned);
          case ProductivitySort.matings:
            return b.totalMatings.compareTo(a.totalMatings);
        }
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport de productivite'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Analysez les performances detaillees de vos reproducteurs.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      child: DropdownMenu<SexFilterOption>(
                        initialSelection: _sexFilter,
                        label: const Text('Sexe'),
                        dropdownMenuEntries: sexEntries,
                        onSelected: (SexFilterOption? value) {
                          if (value != null) {
                            setState(() => _sexFilter = value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownMenu<ProductivitySort>(
                        initialSelection: _sort,
                        label: const Text('Tri'),
                        dropdownMenuEntries: sortEntries,
                        onSelected: (ProductivitySort? value) {
                          if (value != null) {
                            setState(() => _sort = value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Rechercher',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (String value) =>
                            setState(() => _query = value.trim()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(
                      avatar: const Icon(Icons.calendar_month, size: 18),
                      label: Text(
                        '${DateFormat.MMMd('fr').format(state.viewData.range.start)}'
                        ' - ${DateFormat.MMMd('fr').format(state.viewData.range.end)}',
                      ),
                    ),
                    if (state.selectedLot != null)
                      Chip(
                        avatar: const Icon(Icons.category_outlined, size: 18),
                        label: Text('Lot ${state.selectedLot}'),
                      ),
                    if (state.selectedLocation != null)
                      Chip(
                        avatar: const Icon(Icons.place_outlined, size: 18),
                        label: Text(state.selectedLocation!),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ordered.isEmpty
                ? const _EmptyProductivityPlaceholder()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: ordered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final _ProductivityStats stat = ordered[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      _formatAnimalLabel(stat.animal),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    '${(stat.successRate * 100).toStringAsFixed(0)} %',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _StatBadge(
                                    icon: Icons.monitor_heart_outlined,
                                    label: 'Saillies',
                                    value: numberFormat.format(stat.totalMatings),
                                  ),
                                  _StatBadge(
                                    icon: Icons.baby_changing_station_outlined,
                                    label: 'Sevrages',
                                    value: numberFormat.format(stat.totalWeaned),
                                  ),
                                  if (stat.averageKitsBorn != null)
                                    _StatBadge(
                                      icon: Icons.pets_outlined,
                                      label: 'Portee moyenne',
                                      value: stat.averageKitsBorn!.toStringAsFixed(1),
                                    ),
                                  if (stat.averageKitsWeaned != null)
                                    _StatBadge(
                                      icon: Icons.favorite_outline,
                                      label: 'Sevres moyens',
                                      value: stat.averageKitsWeaned!.toStringAsFixed(1),
                                    ),
                                  if (stat.lot != null)
                                    _StatBadge(
                                      icon: Icons.category_outlined,
                                      label: 'Lot',
                                      value: stat.lot!,
                                    ),
                                  if (stat.location != null)
                                    _StatBadge(
                                      icon: Icons.place_outlined,
                                      label: 'Localisation',
                                      value: stat.location!,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static List<_ProductivityStats> _buildStats({
    required List<Animal> animals,
    required List<BreedingRecord> records,
    required Map<String, String> lotsByAnimal,
    required Map<String, String> locationsByAnimal,
  }) {
    final Map<String, Animal> animalsById = <String, Animal>{
      for (final Animal animal in animals) animal.id: animal,
    };

    final Map<String, List<BreedingRecord>> recordsByAnimal =
        <String, List<BreedingRecord>>{};
    for (final BreedingRecord record in records) {
      recordsByAnimal
          .putIfAbsent(record.doeId, () => <BreedingRecord>[])
          .add(record);
      recordsByAnimal
          .putIfAbsent(record.buckId, () => <BreedingRecord>[])
          .add(record);
    }

    final List<_ProductivityStats> stats = <_ProductivityStats>[];
    for (final MapEntry<String, List<BreedingRecord>> entry
        in recordsByAnimal.entries) {
      final Animal? animal = animalsById[entry.key];
      if (animal == null) {
        continue;
      }
      stats.add(
        _ProductivityStats.fromRecords(
          animal: animal,
          records: entry.value,
          lot: lotsByAnimal[animal.id],
          location: locationsByAnimal[animal.id],
        ),
      );
    }
    return stats;
  }

  static String _formatAnimalLabel(Animal animal) {
    if (animal.name != null && animal.name!.isNotEmpty) {
      return '${animal.tagId} - ${animal.name}';
    }
    return animal.tagId;
  }
}

enum ProductivitySort { success, matings, weaned }

class _StatBadge extends StatelessWidget {
  const _StatBadge({
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
      avatar: Icon(icon, size: 18),
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

class _EmptyProductivityPlaceholder extends StatelessWidget {
  const _EmptyProductivityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.insights_outlined, size: 64),
            SizedBox(height: 12),
            Text(
              'Aucun reproducteur ne correspond aux filtres.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductivityStats extends Equatable {
  const _ProductivityStats({
    required this.animal,
    required this.totalMatings,
    required this.successfulMatings,
    required this.successRate,
    required this.totalWeaned,
    required this.isFemale,
    this.averageKitsBorn,
    this.averageKitsWeaned,
    this.lot,
    this.location,
  });

  final Animal animal;
  final int totalMatings;
  final int successfulMatings;
  final double successRate;
  final int totalWeaned;
  final bool isFemale;
  final double? averageKitsBorn;
  final double? averageKitsWeaned;
  final String? lot;
  final String? location;

  factory _ProductivityStats.fromRecords({
    required Animal animal,
    required List<BreedingRecord> records,
    String? lot,
    String? location,
  }) {
    int total = 0;
    int success = 0;
    int totalBorn = 0;
    int bornCount = 0;
    int totalWeaned = 0;
    int weanedCount = 0;

    for (final BreedingRecord record in records) {
      total += 1;
      if (record.palpationPositive == true) {
        success += 1;
      }
      if (record.kitsBornAlive != null) {
        totalBorn += record.kitsBornAlive!;
        bornCount += 1;
      }
      if (record.kitsWeaned != null) {
        totalWeaned += record.kitsWeaned!;
        weanedCount += 1;
      }
    }

    final bool isFemale = animal.sex.toLowerCase().contains('fem');
    return _ProductivityStats(
      animal: animal,
      totalMatings: total,
      successfulMatings: success,
      successRate: total == 0 ? 0 : success / total,
      totalWeaned: totalWeaned,
      isFemale: isFemale,
      averageKitsBorn: bornCount == 0 ? null : totalBorn / bornCount,
      averageKitsWeaned: weanedCount == 0 ? null : totalWeaned / weanedCount,
      lot: lot,
      location: location,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        animal,
        totalMatings,
        successfulMatings,
        successRate,
        totalWeaned,
        isFemale,
        averageKitsBorn,
        averageKitsWeaned,
        lot,
        location,
      ];
}
