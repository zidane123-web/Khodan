import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/breeding_performance_card.dart';
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
      )..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

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
    final int plannedToday = state.todayTasks
        .where((String task) => task.contains('Saillie planifiée'))
        .length;
    final int plannedUpcoming = state.upcomingTasks
        .where((String task) => task.contains('Saillie planifiée'))
        .length;
    final int plannedWithinWeek = plannedToday + plannedUpcoming;

    final String animalsSubtitle = state.activeAnimals == state.totalAnimals
        ? 'Tous les animaux sont actifs'
        : '${state.activeAnimals} actifs';
    final String gestationSubtitle = state.activeLitters > 0
        ? '${state.activeLitters} portées en cours'
        : 'Aucune portée active';
    final String plannedSubtitle = state.plannedBreedings == 0
        ? 'Aucune saillie programmée'
        : plannedWithinWeek > 0
            ? '$plannedWithinWeek dans les 7 jours'
            : 'Prévisions au-delà de 7 jours';
    final String successSubtitle = state.breedingEvaluatedCount == 0
        ? 'Pas assez de données'
        : '${state.breedingEvaluatedCount} saillies évaluées';
    final String successValue = state.breedingSuccessRate == null
        ? '--'
        : '${(state.breedingSuccessRate! * 100).toStringAsFixed(0)}%';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        KpiCard(
          title: 'Lapins enregistrés',
          value: state.totalAnimals.toString(),
          subtitle: animalsSubtitle,
          icon: Icons.pets,
        ),
        KpiCard(
          title: 'Lapines en gestation',
          value: state.doesInGestation.toString(),
          subtitle: gestationSubtitle,
          icon: Icons.favorite_outline,
        ),
        KpiCard(
          title: 'Saillies prévues',
          value: state.plannedBreedings.toString(),
          subtitle: plannedSubtitle,
          icon: Icons.event_available_outlined,
        ),
        KpiCard(
          title: 'Taux de réussite repro',
          value: successValue,
          subtitle: successSubtitle,
          icon: Icons.trending_up,
        ),
      ],
    );
  }
}
