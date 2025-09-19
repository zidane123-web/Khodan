import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/alerts_list.dart';
import '../widgets/breeding_performance_card.dart';
import '../widgets/dashboard_calendar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/tasks_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (BuildContext context) => DashboardCubit(
        InMemoryAnimalRepository(),
        InMemoryBreedingRepository(),
        InMemoryEventRepository(),
      )..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _openKpiPreferences(
    BuildContext context,
    DashboardState state,
  ) async {
    final DashboardCubit cubit = context.read<DashboardCubit>();
    final List<DashboardKpiType> initialOrder =
        List<DashboardKpiType>.from(state.kpiOrder);
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!initialOrder.contains(type)) {
        initialOrder.add(type);
      }
    }

    final List<DashboardKpiType>? result =
        await showModalBottomSheet<List<DashboardKpiType>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => _KpiPreferencesSheet(
        initialOrder: initialOrder,
        state: state,
      ),
    );

    if (result != null) {
      cubit.updateKpiOrder(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        final ThemeData theme = Theme.of(context);
        Widget body;
        switch (state.status) {
          case DashboardStatus.initial:
          case DashboardStatus.loading:
            body = const Center(child: CircularProgressIndicator());
            break;
          case DashboardStatus.failure:
            body = Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ??
                      'Impossible de charger les statistiques.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
            break;
          case DashboardStatus.success:
            body = RefreshIndicator(
              onRefresh: () =>
                  context.read<DashboardCubit>().loadDashboard(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          Text(
                            'Indicateurs clés',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _DashboardKpiGrid(state: state),
                          const SizedBox(height: 24),
                          AlertsList(alerts: state.alerts),
                          const SizedBox(height: 24),
                          DashboardCalendar(events: state.calendarEvents),
                          const SizedBox(height: 24),
                          BreedingPerformanceCard(stats: state.performance),
                          const SizedBox(height: 24),
                          TasksList(
                            title: 'Aujourd’hui',
                            tasks: state.todayTasks,
                          ),
                          const SizedBox(height: 16),
                          TasksList(
                            title: 'À venir',
                            tasks: state.upcomingTasks,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ma journée'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Personnaliser les indicateurs',
                onPressed: () => _openKpiPreferences(context, state),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: body,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/events'),
            icon: const Icon(Icons.add),
            label: const Text('Nouvel événement'),
          ),
        );
      },
    );
  }
}

class _DashboardKpiGrid extends StatelessWidget {
  const _DashboardKpiGrid({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final Map<DashboardKpiType, _KpiPresentation> presentations =
        _buildAllKpiPresentations(state);
    final List<DashboardKpiType> order = <DashboardKpiType>[...state.kpiOrder];
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!order.contains(type)) {
        order.add(type);
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: order.take(4).map((DashboardKpiType type) {
        final _KpiPresentation presentation = presentations[type]!;
        return KpiCard(
          title: presentation.title,
          value: presentation.value,
          subtitle: presentation.subtitle,
          icon: presentation.icon,
        );
      }).toList(),
    );
  }
}

class _KpiPreferencesSheet extends StatefulWidget {
  const _KpiPreferencesSheet({
    required this.initialOrder,
    required this.state,
  });

  final List<DashboardKpiType> initialOrder;
  final DashboardState state;

  @override
  State<_KpiPreferencesSheet> createState() => _KpiPreferencesSheetState();
}

class _KpiPreferencesSheetState extends State<_KpiPreferencesSheet> {
  late List<DashboardKpiType> _order;

  @override
  void initState() {
    super.initState();
    _order = List<DashboardKpiType>.from(widget.initialOrder);
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!_order.contains(type)) {
        _order.add(type);
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final DashboardKpiType item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  void _reset() {
    setState(() {
      _order = List<DashboardKpiType>.from(const DashboardState().kpiOrder);
      for (final DashboardKpiType type in DashboardKpiType.values) {
        if (!_order.contains(type)) {
          _order.add(type);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<DashboardKpiType, _KpiPresentation> presentations =
        _buildAllKpiPresentations(widget.state);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Indicateurs favoris',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Réorganisez la liste ci-dessous. Les 4 premiers seront affichés sur votre tableau de bord.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _order.take(4).map((DashboardKpiType type) {
                  return Chip(
                    label: Text(presentations[type]!.title),
                    avatar: const Icon(Icons.push_pin, size: 16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _order.length,
                  onReorder: _onReorder,
                  buildDefaultDragHandles: false,
                  itemBuilder: (BuildContext context, int index) {
                    final DashboardKpiType type = _order[index];
                    final _KpiPresentation presentation = presentations[type]!;
                    final bool isHighlighted = index < 4;
                    return Card(
                      key: ValueKey<DashboardKpiType>(type),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: isHighlighted
                          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                          : null,
                      child: ListTile(
                        leading: Icon(presentation.icon),
                        title: Text(presentation.title),
                        subtitle: presentation.description != null
                            ? Text(presentation.description!)
                            : null,
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Réinitialiser'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context)
                        .pop(List<DashboardKpiType>.from(_order)),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiPresentation {
  const _KpiPresentation({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.description,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? description;
}

Map<DashboardKpiType, _KpiPresentation> _buildAllKpiPresentations(
  DashboardState state,
) {
  final Map<DashboardKpiType, _KpiPresentation> map =
      <DashboardKpiType, _KpiPresentation>{};
  final List<DashboardTask> allTasks = <DashboardTask>[...state.todayTasks]
    ..addAll(state.upcomingTasks);
  final int plannedWithinWeek = allTasks
      .where((DashboardTask task) => task.kind == DashboardTaskKind.mating)
      .length;

  for (final DashboardKpiType type in DashboardKpiType.values) {
    map[type] = _buildKpiPresentation(type, state, plannedWithinWeek);
  }
  return map;
}

_KpiPresentation _buildKpiPresentation(
  DashboardKpiType type,
  DashboardState state,
  int plannedWithinWeek,
) {
  switch (type) {
    case DashboardKpiType.totalAnimals:
      final String subtitle = state.activeAnimals == state.totalAnimals
          ? 'Tous les animaux sont actifs'
          : '${state.activeAnimals} actifs';
      return _KpiPresentation(
        title: 'Lapins enregistrés',
        value: state.totalAnimals.toString(),
        subtitle: subtitle,
        description: 'Nombre total d’animaux enregistrés.',
        icon: Icons.pets,
      );
    case DashboardKpiType.activeAnimals:
      final int inactive = state.totalAnimals - state.activeAnimals;
      final String subtitle = state.totalAnimals == 0
          ? 'Aucun animal enregistré'
          : inactive > 0
              ? '$inactive inactifs'
              : 'Tous sont actifs';
      return _KpiPresentation(
        title: 'Animaux actifs',
        value: state.activeAnimals.toString(),
        subtitle: subtitle,
        description: 'Animaux actuellement présents et actifs.',
        icon: Icons.pets_outlined,
      );
    case DashboardKpiType.gestatingDoes:
      final String subtitle = state.activeLitters > 0
          ? '${state.activeLitters} portées en cours'
          : 'Aucune portée active';
      return _KpiPresentation(
        title: 'Lapines en gestation',
        value: state.doesInGestation.toString(),
        subtitle: subtitle,
        description: 'Femelles avec une gestation confirmée ou présumée.',
        icon: Icons.favorite_outline,
      );
    case DashboardKpiType.plannedBreedings:
      final String subtitle;
      if (state.plannedBreedings == 0) {
        subtitle = 'Aucune saillie programmée';
      } else if (plannedWithinWeek > 0) {
        subtitle = '$plannedWithinWeek dans les 7 jours';
      } else {
        subtitle = 'Prévisions au-delà de 7 jours';
      }
      return _KpiPresentation(
        title: 'Saillies prévues',
        value: state.plannedBreedings.toString(),
        subtitle: subtitle,
        description: 'Saillies programmées dans votre planning.',
        icon: Icons.event_available_outlined,
      );
    case DashboardKpiType.activeLitters:
      final String subtitle = state.activeLitters == 0
          ? 'Aucune portée à surveiller'
          : 'Portées en allaitement';
      return _KpiPresentation(
        title: 'Portées actives',
        value: state.activeLitters.toString(),
        subtitle: subtitle,
        description: 'Portées encore en cours avant sevrage.',
        icon: Icons.home_outlined,
      );
    case DashboardKpiType.breedingSuccessRate:
      final String value = state.breedingSuccessRate == null
          ? '--'
          : '${(state.breedingSuccessRate! * 100).toStringAsFixed(0)}%';
      final String subtitle = state.breedingEvaluatedCount == 0
          ? 'Pas assez de données'
          : '${state.breedingEvaluatedCount} saillies évaluées';
      return _KpiPresentation(
        title: 'Taux de réussite repro',
        value: value,
        subtitle: subtitle,
        description: 'Proportion de saillies confirmées gestantes.',
        icon: Icons.trending_up,
      );
    case DashboardKpiType.averageKitsBornAlive:
      final String subtitle = state.performance.totalLitters == 0
          ? 'Pas encore de portée'
          : '${state.performance.totalLitters} portées analysées';
      return _KpiPresentation(
        title: 'Moy. nés vivants',
        value: _formatAverage(state.performance.averageKitsBornAlive),
        subtitle: subtitle,
        description: 'Nombre moyen de lapereaux nés vivants par portée.',
        icon: Icons.child_care,
      );
    case DashboardKpiType.averageKitsWeaned:
      final String subtitle = state.performance.totalLitters == 0
          ? 'Pas encore de sevrage'
          : '${state.performance.totalLitters} portées analysées';
      return _KpiPresentation(
        title: 'Moy. sevrés',
        value: _formatAverage(state.performance.averageKitsWeaned),
        subtitle: subtitle,
        description: 'Nombre moyen de lapereaux sevrés par portée.',
        icon: Icons.monitor_weight,
      );
    case DashboardKpiType.totalKitsWeaned:
      final String subtitle = state.performance.totalLitters == 0
          ? 'En attente des premières portées'
          : 'Depuis ${state.performance.totalLitters} portées';
      return _KpiPresentation(
        title: 'Lapereaux sevrés',
        value: state.performance.totalKitsWeaned.toString(),
        subtitle: subtitle,
        description: 'Total de lapereaux sevrés sur la période.',
        icon: Icons.groups,
      );
  }
}

String _formatAverage(double? value) {
  if (value == null) {
    return '--';
  }
  return value.toStringAsFixed(1);
}
