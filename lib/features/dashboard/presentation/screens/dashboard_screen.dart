import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../animals/presentation/models/animal_quick_filter.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/alerts_list.dart';
import '../widgets/breeding_performance_card.dart';
import '../widgets/dashboard_calendar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/tasks_list.dart';
import '../../../../app/config/router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (BuildContext context) => DashboardCubit(
        SupabaseAnimalRepository(),
        SupabaseBreedingRepository(),
        SupabaseEventRepository(),
      )..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardCubit>().loadDashboard();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this screen
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      context.read<DashboardCubit>().loadDashboard();
    }
  }

  Future<void> _openCustomization(
    BuildContext context,
    DashboardState state,
  ) async {
    final DashboardCubit cubit = context.read<DashboardCubit>();
    final List<DashboardKpiType> initialOrder = List<DashboardKpiType>.from(
      state.kpiOrder,
    );
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!initialOrder.contains(type)) {
        initialOrder.add(type);
      }
    }

    final _DashboardCustomizationResult? result =
        await showModalBottomSheet<_DashboardCustomizationResult>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) => _DashboardCustomizationSheet(
            initialOrder: initialOrder,
            state: state,
          ),
        );

    if (result != null) {
      cubit
        ..updateKpiOrder(result.kpiOrder)
        ..updateModulePreferences(
          order: result.moduleOrder,
          hidden: result.hiddenModules,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
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
              onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _DashboardModuleGrid(state: state),
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
                tooltip: 'Personnaliser le tableau de bord',
                onPressed: () => _openCustomization(context, state),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Se déconnecter',
                onPressed: () async {
                  await context.read<AuthCubit>().signOut();
                  if (context.mounted) {
                    context.go(const LoginRoute().location);
                  }
                },
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

    final Map<DashboardKpiType, DashboardKpiFilter> filters = state.kpiFilters;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: order.take(4).map((DashboardKpiType type) {
        final _KpiPresentation presentation = presentations[type]!;
        final DashboardKpiFilter? filter = filters[type];
        return KpiCard(
          title: presentation.title,
          value: presentation.value,
          subtitle: presentation.subtitle,
          icon: presentation.icon,
          color: presentation.color,
          onTap: filter == null
              ? null
              : () {
                  context.go(
                    const AnimalsRoute().location,
                    extra: AnimalQuickFilter(
                      label: filter.label,
                      sex: filter.sex,
                      statusQuery: filter.statusQuery,
                      includeIds: filter.includeIds == null
                          ? null
                          : Set<String>.from(filter.includeIds!),
                    ),
                  );
                },
        );
      }).toList(),
    );
  }
}

class _DashboardModuleGrid extends StatelessWidget {
  const _DashboardModuleGrid({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<DashboardModuleType> modules = state.moduleOrder
        .where(
          (DashboardModuleType type) => !state.hiddenModules.contains(type),
        )
        .toList();

    if (modules.isEmpty) {
      return _buildInfoCard(
        theme,
        title: 'Aucun widget sélectionné',
        icon: Icons.dashboard_customize,
        message:
            'Activez des widgets depuis le menu de personnalisation pour composer votre tableau de bord.',
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1100
            ? 3
            : width >= 760
            ? 2
            : 1;
        final double spacing = 12;
        final double itemWidth = columns == 1
            ? width
            : (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: modules.map((DashboardModuleType type) {
            final Widget module = _buildModule(theme, type);
            return SizedBox(
              width: columns == 1 ? width : itemWidth,
              child: module,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildModule(ThemeData theme, DashboardModuleType type) {
    switch (type) {
      case DashboardModuleType.kpis:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Indicateurs clés', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _DashboardKpiGrid(state: state),
              ],
            ),
          ),
        );
      case DashboardModuleType.alerts:
        return AlertsList(alerts: state.alerts);
      case DashboardModuleType.calendar:
        return DashboardCalendar(events: state.calendarEvents);
      case DashboardModuleType.tasksToday:
        return TasksList(title: 'Aujourd’hui', tasks: state.todayTasks);
      case DashboardModuleType.tasksUpcoming:
        return TasksList(title: 'À venir', tasks: state.upcomingTasks);
      case DashboardModuleType.performance:
        return BreedingPerformanceCard(stats: state.performance);
      case DashboardModuleType.weightTracking:
        return _buildInfoCard(
          theme,
          title: 'Suivi des poids',
          icon: Icons.monitor_weight,
          message:
              'Ajoutez des évènements de pesée à vos animaux pour visualiser leur évolution directement ici.',
        );
      case DashboardModuleType.healthAlerts:
        return _buildInfoCard(
          theme,
          title: 'Alertes santé',
          icon: Icons.medical_services_outlined,
          message:
              'Planifiez les traitements et vaccinations pour recevoir des rappels automatiques.',
        );
      case DashboardModuleType.feedInventory:
        return _buildInfoCard(
          theme,
          title: 'Inventaire des aliments',
          icon: Icons.inventory_2_outlined,
          message:
              'Suivez vos stocks d’aliments et anticipez les réapprovisionnements.',
        );
    }
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DashboardCustomizationResult {
  const _DashboardCustomizationResult({
    required this.kpiOrder,
    required this.moduleOrder,
    required this.hiddenModules,
  });

  final List<DashboardKpiType> kpiOrder;
  final List<DashboardModuleType> moduleOrder;
  final Set<DashboardModuleType> hiddenModules;
}

class _DashboardCustomizationSheet extends StatefulWidget {
  const _DashboardCustomizationSheet({
    required this.initialOrder,
    required this.state,
  });

  final List<DashboardKpiType> initialOrder;
  final DashboardState state;

  @override
  State<_DashboardCustomizationSheet> createState() =>
      _DashboardCustomizationSheetState();
}

class _DashboardCustomizationSheetState
    extends State<_DashboardCustomizationSheet> {
  late List<DashboardKpiType> _order;
  late List<DashboardModuleType> _moduleOrder;
  late Set<DashboardModuleType> _hiddenModules;

  @override
  void initState() {
    super.initState();
    _order = List<DashboardKpiType>.from(widget.initialOrder);
    for (final DashboardKpiType type in DashboardKpiType.values) {
      if (!_order.contains(type)) {
        _order.add(type);
      }
    }
    _moduleOrder = List<DashboardModuleType>.from(widget.state.moduleOrder);
    for (final DashboardModuleType type in DashboardModuleType.values) {
      if (!_moduleOrder.contains(type)) {
        _moduleOrder.add(type);
      }
    }
    _hiddenModules = Set<DashboardModuleType>.from(widget.state.hiddenModules);
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

  void _onModuleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final DashboardModuleType item = _moduleOrder.removeAt(oldIndex);
      _moduleOrder.insert(newIndex, item);
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
      _moduleOrder = List<DashboardModuleType>.from(
        const DashboardState().moduleOrder,
      );
      for (final DashboardModuleType type in DashboardModuleType.values) {
        if (!_moduleOrder.contains(type)) {
          _moduleOrder.add(type);
        }
      }
      _hiddenModules = Set<DashboardModuleType>.from(
        const DashboardState().hiddenModules,
      );
    });
  }

  String _moduleLabel(DashboardModuleType type) {
    switch (type) {
      case DashboardModuleType.kpis:
        return 'Indicateurs clés';
      case DashboardModuleType.alerts:
        return 'Alertes de santé';
      case DashboardModuleType.calendar:
        return 'Calendrier';
      case DashboardModuleType.tasksToday:
        return 'Tâches du jour';
      case DashboardModuleType.tasksUpcoming:
        return 'Tâches à venir';
      case DashboardModuleType.performance:
        return 'Performances repro';
      case DashboardModuleType.weightTracking:
        return 'Suivi des poids';
      case DashboardModuleType.healthAlerts:
        return 'Alertes santé avancées';
      case DashboardModuleType.feedInventory:
        return 'Inventaire des aliments';
    }
  }

  String _moduleDescription(DashboardModuleType type) {
    switch (type) {
      case DashboardModuleType.kpis:
        return 'Résumé rapide des métriques clés.';
      case DashboardModuleType.alerts:
        return 'Notifications importantes et rappels critiques.';
      case DashboardModuleType.calendar:
        return 'Vue condensée des évènements à venir.';
      case DashboardModuleType.tasksToday:
        return 'Actions à réaliser dans la journée.';
      case DashboardModuleType.tasksUpcoming:
        return 'Préparez les tâches des prochains jours.';
      case DashboardModuleType.performance:
        return 'Statistiques globales de reproduction.';
      case DashboardModuleType.weightTracking:
        return 'Synthèse des pesées enregistrées.';
      case DashboardModuleType.healthAlerts:
        return 'Suivi des traitements et soins en cours.';
      case DashboardModuleType.feedInventory:
        return 'Gestion des stocks d’aliments.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<DashboardKpiType, _KpiPresentation> presentations =
        _buildAllKpiPresentations(widget.state);

    return FractionallySizedBox(
      heightFactor: 0.9,
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
              Text('Indicateurs favoris', style: theme.textTheme.titleLarge),
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
                          ? theme.colorScheme.primaryContainer.withAlpha(
                              (255 * 0.3).round(),
                            )
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
              const SizedBox(height: 16),
              Text(
                'Widgets du tableau de bord',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 280,
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _moduleOrder.length,
                  onReorder: _onModuleReorder,
                  buildDefaultDragHandles: false,
                  itemBuilder: (BuildContext context, int index) {
                    final DashboardModuleType type = _moduleOrder[index];
                    final bool isEnabled = !_hiddenModules.contains(type);
                    return Card(
                      key: ValueKey<DashboardModuleType>(type),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 56,
                          right: 16,
                        ),
                        title: Text(_moduleLabel(type)),
                        subtitle: Text(_moduleDescription(type)),
                        value: isEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              _hiddenModules.remove(type);
                            } else {
                              _hiddenModules.add(type);
                            }
                          });
                        },
                        secondary: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                    onPressed: () => Navigator.of(context).pop(
                      _DashboardCustomizationResult(
                        kpiOrder: List<DashboardKpiType>.from(_order),
                        moduleOrder: List<DashboardModuleType>.from(
                          _moduleOrder,
                        ),
                        hiddenModules: Set<DashboardModuleType>.from(
                          _hiddenModules,
                        ),
                      ),
                    ),
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
    this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? description;
  final Color? color;
}

Map<DashboardKpiType, _KpiPresentation> _buildAllKpiPresentations(
  DashboardState state,
) {
  final Map<DashboardKpiType, _KpiPresentation> map =
      <DashboardKpiType, _KpiPresentation>{};
  final List<DashboardTask> allTasks = <DashboardTask>[
    ...state.todayTasks,
    ...state.upcomingTasks,
  ];
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
  // Define colors based on a visual language
  const Color colorAnimals = Color(0xFF1B5B3A); // Forest Green
  const Color colorReproduction = Color(0xFFE04F5F); // Soft Red for love/repro
  const Color colorProduction = Color(0xFF2D7CBF); // Blue for production/weaning
  const Color colorAlert = Color(0xFFFF7A2E); // Orange for alerts/planned

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
        color: colorAnimals,
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
        color: colorAnimals,
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
        color: colorReproduction,
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
        color: colorAlert,
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
        color: colorReproduction,
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
        color: colorReproduction,
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
        color: colorProduction,
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
        color: colorProduction,
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
        color: colorProduction,
      );
  }
}

String _formatAverage(double? value) {
  if (value == null) {
    return '--';
  }
  return value.toStringAsFixed(1);
}
