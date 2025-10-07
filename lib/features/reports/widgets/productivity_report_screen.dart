import 'package:flutter/material.dart';

import '../../../data/models/animal.dart';
import '../../../data/models/breeding_record.dart';

class ProductivityReportScreen extends StatefulWidget {
  const ProductivityReportScreen({
    required this.animals,
    required this.records,
    super.key,
  });

  final List<Animal> animals;
  final List<BreedingRecord> records;

  @override
  State<ProductivityReportScreen> createState() => _ProductivityReportScreenState();
}

class _ProductivityReportScreenState extends State<ProductivityReportScreen> {
  String _sexFilter = 'Tous';
  String _sortKey = 'Succès';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_ProductivityStats> stats = _buildStats();

    final List<_ProductivityStats> filtered = stats.where((_ProductivityStats stat) {
      if (_sexFilter != 'Tous') {
        final bool isDoe = stat.animal.sex.toLowerCase().contains('fem');
        if (_sexFilter == 'Femelle' && !isDoe) {
          return false;
        }
        if (_sexFilter == 'Mâle' && isDoe) {
          return false;
        }
      }
      if (_query.isEmpty) {
        return true;
      }
      final String normalized = _query.toLowerCase();
      return (stat.animal.tagId.toLowerCase().contains(normalized) ||
          (stat.animal.name?.toLowerCase().contains(normalized) ?? false));
    }).toList();

    filtered.sort((_ProductivityStats a, _ProductivityStats b) {
      switch (_sortKey) {
        case 'Sevrés':
          return b.totalWeaned.compareTo(a.totalWeaned);
        case 'Saillies':
          return b.totalMatings.compareTo(a.totalMatings);
        case 'Succès':
        default:
          return b.successRate.compareTo(a.successRate);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport de productivité'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Comparez les performances de vos reproducteurs et identifiez les sujets à valoriser ou à réformer.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        initialValue: _sexFilter,
                        decoration: const InputDecoration(labelText: 'Sexe'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(value: 'Tous', child: Text('Tous')),
                          DropdownMenuItem<String>(value: 'Femelle', child: Text('Femelles')),
                          DropdownMenuItem<String>(value: 'Mâle', child: Text('Mâles')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _sexFilter = value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortKey,
                        decoration: const InputDecoration(labelText: 'Tri'),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(value: 'Succès', child: Text('Par taux de réussite')),
                          DropdownMenuItem<String>(value: 'Sevrés', child: Text('Par sevrés cumulés')),
                          DropdownMenuItem<String>(value: 'Saillies', child: Text('Par nombre de saillies')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _sortKey = value);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Rechercher',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (String value) => setState(() => _query = value.trim()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyProductivityPlaceholder()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final _ProductivityStats stat = filtered[index];
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
                                      '${stat.animal.tagId}${stat.animal.name != null ? ' · ${stat.animal.name}' : ''}',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      '${(stat.successRate * 100).toStringAsFixed(0)} %',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: <Widget>[
                                  _StatBadge(
                                    icon: Icons.favorite_outline,
                                    label: 'Saillies',
                                    value: stat.totalMatings.toString(),
                                  ),
                                  _StatBadge(
                                    icon: Icons.child_friendly,
                                    label: 'Sevrés cumulés',
                                    value: stat.totalWeaned.toString(),
                                  ),
                                  _StatBadge(
                                    icon: Icons.pets_outlined,
                                    label: 'Portées moyennes',
                                    value: stat.averageKitsBorn?.toStringAsFixed(1) ?? '—',
                                  ),
                                  _StatBadge(
                                    icon: Icons.scale,
                                    label: 'Sevrés moyens',
                                    value: stat.averageKitsWeaned?.toStringAsFixed(1) ?? '—',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: stat.successRate,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Succès : ${stat.successfulMatings}/${stat.totalMatings}',
                                style: theme.textTheme.bodySmall,
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

  List<_ProductivityStats> _buildStats() {
    return <_ProductivityStats>[
      for (final Animal animal in widget.animals)
        _ProductivityStats.fromAnimal(animal, widget.records),
    ];
  }
}

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
              'Aucun reproducteur correspondant à vos filtres.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductivityStats {
  const _ProductivityStats({
    required this.animal,
    required this.totalMatings,
    required this.successfulMatings,
    required this.successRate,
    required this.totalWeaned,
    this.averageKitsBorn,
    this.averageKitsWeaned,
  });

  final Animal animal;
  final int totalMatings;
  final int successfulMatings;
  final double successRate;
  final int totalWeaned;
  final double? averageKitsBorn;
  final double? averageKitsWeaned;

  factory _ProductivityStats.fromAnimal(
    Animal animal,
    List<BreedingRecord> records,
  ) {
    final bool isDoe = animal.sex.toLowerCase().contains('fem');
    final Iterable<BreedingRecord> relevant = records.where(
      (BreedingRecord record) =>
          isDoe ? record.doeId == animal.id : record.buckId == animal.id,
    );

    int total = 0;
    int success = 0;
    int totalBorn = 0;
    int bornCount = 0;
    int totalWeaned = 0;
    int weanedCount = 0;

    for (final BreedingRecord record in relevant) {
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

    final double successRate = total == 0 ? 0 : success / total;
    final double? averageBorn = bornCount == 0 ? null : totalBorn / bornCount;
    final double? averageWeaned = weanedCount == 0 ? null : totalWeaned / weanedCount;

    return _ProductivityStats(
      animal: animal,
      totalMatings: total,
      successfulMatings: success,
      successRate: successRate,
      totalWeaned: totalWeaned,
      averageKitsBorn: averageBorn,
      averageKitsWeaned: averageWeaned,
    );
  }
}
