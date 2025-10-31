import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/sync_action.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../domain/models/planning_filters.dart';
import '../../domain/models/schedule_task.dart';
import '../cubit/planning_cubit.dart';
import '../cubit/planning_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/planning_task_tile.dart';

class PlanningListTab extends StatefulWidget {
  const PlanningListTab({super.key});

  @override
  State<PlanningListTab> createState() => _PlanningListTabState();
}

class _PlanningListTabState extends State<PlanningListTab> {
  late final TextEditingController _searchController;
  PlanningCubit get _cubit => context.read<PlanningCubit>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _cubit.state.searchQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _cubit.updateSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocListener<PlanningCubit, PlanningState>(
      listenWhen: (PlanningState previous, PlanningState current) =>
          previous.searchQuery != current.searchQuery,
      listener: (BuildContext context, PlanningState state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
      },
      child: BlocBuilder<PlanningCubit, PlanningState>(
        builder: (BuildContext context, PlanningState state) {
          if (state.status == PlanningStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Erreur inconnue',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state.status == PlanningStatus.loading &&
              state.filteredTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool selectionMode = state.selectedTaskIds.isNotEmpty;
          final List<ScheduleTask> tasks = state.filteredTasks;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.planningSearchHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              _FiltersRow(state: state, l10n: l10n, cubit: _cubit),
              if (state.isOfflineMode || state.offlinePendingActions > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _OfflineBanner(state: state, l10n: l10n),
                ),
              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.planningEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final ScheduleTask task = tasks[index];
                      final bool isSelected = state.selectedTaskIds.contains(
                        task.id,
                      );
                      return PlanningTaskTile(
                        task: task,
                        cubit: _cubit,
                        l10n: l10n,
                        selectionMode: selectionMode,
                        isSelected: isSelected,
                        onToggleSelection: () =>
                            _cubit.toggleTaskSelection(task.id),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow({
    required this.state,
    required this.l10n,
    required this.cubit,
  });

  final PlanningState state;
  final AppLocalizations l10n;
  final PlanningCubit cubit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          _StatusFilterChip(
            label: l10n.planningStatusPlanned,
            status: ScheduleTaskStatus.planned,
            selected: state.filters.statuses.contains(
              ScheduleTaskStatus.planned,
            ),
            cubit: cubit,
          ),
          _StatusFilterChip(
            label: l10n.planningStatusOverdue,
            status: ScheduleTaskStatus.overdue,
            selected: state.filters.statuses.contains(
              ScheduleTaskStatus.overdue,
            ),
            cubit: cubit,
          ),
          _StatusFilterChip(
            label: l10n.planningStatusCompleted,
            status: ScheduleTaskStatus.completed,
            selected: state.filters.statuses.contains(
              ScheduleTaskStatus.completed,
            ),
            cubit: cubit,
          ),
          _StatusFilterChip(
            label: l10n.planningStatusSkipped,
            status: ScheduleTaskStatus.skipped,
            selected: state.filters.statuses.contains(
              ScheduleTaskStatus.skipped,
            ),
            cubit: cubit,
          ),
          ChoiceChip(
            label: Text(l10n.planningPeriodToday),
            selected: state.filters.period == PlanningPeriod.today,
            onSelected: (_) => cubit.setPeriodFilter(PlanningPeriod.today),
          ),
          ChoiceChip(
            label: Text(l10n.planningPeriodWeek),
            selected: state.filters.period == PlanningPeriod.week,
            onSelected: (_) => cubit.setPeriodFilter(PlanningPeriod.week),
          ),
          ChoiceChip(
            label: Text(l10n.planningPeriodMonth),
            selected: state.filters.period == PlanningPeriod.month,
            onSelected: (_) => cubit.setPeriodFilter(PlanningPeriod.month),
          ),
          ActionChip(
            label: Text(l10n.planningFilterType),
            avatar: state.filters.types.isEmpty
                ? null
                : CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      state.filters.types.length.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
                    ),
                  ),
            onPressed: () => _openTypeSheet(context),
          ),
          TextButton(
            onPressed: cubit.resetFilters,
            child: Text(l10n.planningFilterReset),
          ),
        ],
      ),
    );
  }

  Future<void> _openTypeSheet(BuildContext context) async {
    final Set<String> availableTypes = <String>{
      for (final ScheduleTask task in state.tasks) task.type,
    };
    final Set<String> selected = Set<String>.from(state.filters.types);
    final Set<String>? result = await showModalBottomSheet<Set<String>>(
      context: context,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final List<String> sortedTypes = availableTypes.toList()..sort();
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(l10n.planningFilterType),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () {
                        setState(() => selected.clear());
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedTypes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String type = sortedTypes[index];
                        final bool isChecked = selected.contains(type);
                        return CheckboxListTile(
                          title: Text(type),
                          value: isChecked,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                selected.add(type);
                              } else {
                                selected.remove(type);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(<String>{}),
                            child: Text(l10n.planningFilterReset),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(
                              sheetContext,
                            ).pop(Set<String>.from(selected)),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      cubit.setTypeFilters(result.map((String e) => e.toLowerCase()).toSet());
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.status,
    required this.selected,
    required this.cubit,
  });

  final String label;
  final ScheduleTaskStatus status;
  final bool selected;
  final PlanningCubit cubit;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => cubit.toggleStatusFilter(status),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.state, required this.l10n});

  final PlanningState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OfflineSyncManager manager = OfflineSyncManager.instance;
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(
              state.isOfflineMode
                  ? Icons.wifi_off
                  : Icons.cloud_upload_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.offlinePendingActions > 0
                    ? l10n.planningOfflinePending(state.offlinePendingActions)
                    : l10n.settingsOfflineStatusOffline,
              ),
            ),
            TextButton(
              onPressed: () => _showQueue(context, manager),
              child: Text(l10n.planningOfflineViewQueue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQueue(
    BuildContext context,
    OfflineSyncManager manager,
  ) async {
    final List<QueuedSyncAction> queue = manager.pendingQueue;
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: queue.isEmpty
                ? Center(child: Text(l10n.settingsOfflineSummaryReady))
                : ListView.separated(
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      final QueuedSyncAction action = queue[index];
                      return ListTile(
                        leading: const Icon(Icons.sync),
                        title: Text(action.description),
                        subtitle: Text(
                          'Tentatives : ${action.attempts} · Etat : ${action.status.name}',
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
