import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/planning_export_service.dart';
import '../cubit/planning_cubit.dart';
import '../cubit/planning_state.dart';
import '../widgets/planning_calendar_view.dart';
import '../widgets/planning_chain_view.dart';
import '../widgets/planning_list_view.dart';
import '../../../../app/config/router.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlanningCubit>(
      create: (BuildContext context) => PlanningCubit(
        eventRepository: context.read<EventRepository>(),
        breedingRepository: context.read<BreedingRepository>(),
        animalRepository: context.read<AnimalRepository>(),
      )..load(),
      child: const _PlanningView(),
    );
  }
}

class _PlanningView extends StatefulWidget {
  const _PlanningView();

  @override
  State<_PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<_PlanningView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PlanningExportService _exportService = PlanningExportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<PlanningCubit, PlanningState>(
      builder: (BuildContext context, PlanningState state) {
        final PlanningCubit cubit = context.read<PlanningCubit>();
        final bool selectionMode = state.selectedTaskIds.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              selectionMode
                  ? l10n.planningSelectionCount(state.selectedTaskIds.length)
                  : l10n.planningTitle,
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.auto_awesome_motion_outlined),
                tooltip: 'Modeles',
                onPressed: () =>
                    context.push(const PlanningTemplatesRoute().location),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: l10n.planningExportCsv,
                onPressed: () => _exportCsv(context, cubit, l10n),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                tooltip: l10n.planningExportIcalDisabled,
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.planningExportIcalDisabled)),
                    );
                },
              ),
              if (selectionMode)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: l10n.planningFilterReset,
                  onPressed: cubit.clearSelection,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: <Tab>[
                Tab(text: l10n.planningTabList),
                Tab(text: l10n.planningTabCalendar),
                Tab(text: l10n.planningTabChain),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              PlanningListTab(),
              PlanningCalendarTab(),
              PlanningChainTab(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportCsv(
    BuildContext context,
    PlanningCubit cubit,
    AppLocalizations l10n,
  ) async {
    final tasks = cubit.collectSelection();
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.planningEmpty)));
      return;
    }
    await _exportService.shareCsv(tasks: tasks, l10n: l10n);
  }
}
