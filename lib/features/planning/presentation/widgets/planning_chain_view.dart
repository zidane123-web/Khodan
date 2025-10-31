import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../cubit/planning_cubit.dart';
import '../cubit/planning_state.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../l10n/app_localizations.dart';

class PlanningChainTab extends StatelessWidget {
  const PlanningChainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<PlanningCubit, PlanningState>(
      builder: (BuildContext context, PlanningState state) {
        if (state.status == PlanningStatus.loading &&
            state.breedingChains.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.breedingChains.isEmpty) {
          return Center(child: Text(l10n.planningChainEmpty));
        }

        final PlanningCubit cubit = context.read<PlanningCubit>();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: state.breedingChains.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final PlanningBreedingChain chain = state.breedingChains[index];
            final Animal? doe = state.animalsById[chain.record.doeId];
            final Animal? buck = state.animalsById[chain.record.buckId];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Portee ${chain.record.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_animalLabel(doe, chain.record.doeId)} × ${_animalLabel(buck, chain.record.buckId)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final BreedingTask task in chain.tasks)
                      _ChainStep(
                        recordId: chain.record.id,
                        task: task,
                        cubit: cubit,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _animalLabel(Animal? animal, String fallback) {
    if (animal == null) {
      return fallback;
    }
    return animal.tagId.isNotEmpty
        ? animal.tagId
        : (animal.name?.isNotEmpty == true ? animal.name! : fallback);
  }
}

class _ChainStep extends StatelessWidget {
  const _ChainStep({
    required this.recordId,
    required this.task,
    required this.cubit,
  });

  final String recordId;
  final BreedingTask task;
  final PlanningCubit cubit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime now = DateTime.now();
    final bool overdue = !task.isCompleted && task.dueDate.isBefore(now);
    final String statusLabel = task.isCompleted
        ? 'Termine'
        : overdue
        ? 'En retard'
        : 'Planifie';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _iconForType(task.type),
        color: overdue ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(_titleForType(task.type)),
      subtitle: Text(
        MaterialLocalizations.of(context).formatFullDate(task.dueDate),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Chip(
            label: Text(statusLabel),
            backgroundColor: overdue
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainerHigh,
          ),
          if (!task.isCompleted)
            TextButton(
              onPressed: () => cubit.markBreedingStepDone(recordId, task.type),
              child: const Text('Marquer fait'),
            ),
        ],
      ),
    );
  }

  IconData _iconForType(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return Icons.monitor_heart;
      case BreedingTaskType.kindling:
        return Icons.nest_cam_wired_stand;
      case BreedingTaskType.weaning:
        return Icons.child_care;
    }
  }

  String _titleForType(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return 'Palpation';
      case BreedingTaskType.kindling:
        return 'Mise bas';
      case BreedingTaskType.weaning:
        return 'Sevrage';
    }
  }
}
