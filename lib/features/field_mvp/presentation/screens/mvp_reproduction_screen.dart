import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/theme.dart';
import '../mvp_demo_controller.dart';

class MvpReproductionScreen extends StatefulWidget {
  const MvpReproductionScreen({super.key});

  @override
  State<MvpReproductionScreen> createState() => _MvpReproductionScreenState();
}

class _MvpReproductionScreenState extends State<MvpReproductionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openKindlingForm(
    BuildContext context,
    MvpBreedingCycle cycle,
  ) async {
    int totalBorn = 8;
    int deadBorn = 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'La lapine ${cycle.doeName} a-t-elle mis bas ?',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _Counter(
                        label: 'Nés',
                        value: totalBorn,
                        onChanged: (int value) => setModalState(
                          () => totalBorn = value.clamp(0, 20),
                        ),
                      ),
                      _Counter(
                        label: 'Mort-nés',
                        value: deadBorn,
                        onChanged: (int value) => setModalState(
                          () => deadBorn = value.clamp(0, 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      MvpDemoScope.of(context).recordKindling(
                        cycleId: cycle.id,
                        totalBorn: totalBorn,
                        deadBorn: deadBorn,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Portée validée.')),
                      );
                    },
                    child: const Text('Valider la portée'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MvpDemoController store = MvpDemoScope.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproduction'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Saillies en cours'),
            Tab(text: 'Portées nées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: store.breedingCycles.length,
            itemBuilder: (BuildContext context, int index) {
              final MvpBreedingCycle cycle = store.breedingCycles[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.12),
                            child: Icon(Icons.favorite, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  cycle.pairingLabel,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text('Cage ${cycle.cage} • ${cycle.stage}'),
                              ],
                            ),
                          ),
                          Text(
                            '${(cycle.progress * 100).round()} %',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _BreedingProgress(progress: cycle.progress),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Saillie: ${_formatDate(cycle.matingDate)}'),
                              Text('Palpation: ${_formatDate(cycle.palpationDate)}'),
                              Text('Nid: ${_formatDate(cycle.nestDate)}'),
                            ],
                          ),
                          FilledButton.tonal(
                            onPressed: () => _openKindlingForm(context, cycle),
                            child: const Text('Valider mise bas'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: store.litters.length,
            itemBuilder: (BuildContext context, int index) {
              final MvpLitter litter = store.litters[index];
              final Duration remaining = litter.untilWeaning;
              final bool atRisk =
                  litter.mortality > 0 && litter.mortality >= litter.babies / 3;
              final Color highlight = atRisk
                  ? colors?.warning ?? theme.colorScheme.secondary
                  : theme.colorScheme.primary;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.baby_changing_station, color: highlight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mère : ${litter.mother}',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          if (atRisk)
                            Chip(
                              label: const Text('Surveillance'),
                              backgroundColor: highlight.withOpacity(0.16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${litter.babies} lapereaux • Nés le ${_formatDate(litter.birthDate)}',
                      ),
                      if (litter.mortality > 0)
                        Text(
                          'Mortalité : ${litter.mortality}',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Sevrage dans ${remaining.inDays.abs()} jours',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _BreedingProgress extends StatelessWidget {
  const _BreedingProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Text('Saillie'),
            Text('Palpation'),
            Text('Nid'),
            Text('Mise bas'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => onChanged(value - 1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}
