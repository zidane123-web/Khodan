import 'package:flutter/material.dart';

import '../../domain/models/schedule_task.dart';
import '../cubit/planning_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class PlanningTaskTile extends StatelessWidget {
  const PlanningTaskTile({
    required this.task,
    required this.cubit,
    required this.l10n,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelection,
    super.key,
  });

  final ScheduleTask task;
  final PlanningCubit cubit;
  final AppLocalizations l10n;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime scheduledAt = task.scheduledAt;
    final String dateLabel = localizations.formatMediumDate(scheduledAt);
    final String? timeLabel = task.hasSpecificTime
        ? localizations.formatTimeOfDay(
            TimeOfDay.fromDateTime(scheduledAt),
            alwaysUse24HourFormat: true,
          )
        : null;

    final Color? cardColor = isSelected
        ? theme.colorScheme.primaryContainer
        : null;

    return Card(
      color: cardColor,
      child: InkWell(
        onTap: selectionMode ? onToggleSelection : null,
        onLongPress: onToggleSelection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (selectionMode || isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelection(),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4),
                  child: Icon(
                    _iconForCategory(task.category),
                    color: _colorForStatus(task.status, theme),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _titleForTask(task),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (task.isOfflinePending)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Tooltip(
                              message: l10n.planningOfflinePending(1),
                              child: Icon(
                                Icons.cloud_upload,
                                size: 18,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Chip(
                          label: Text(_statusLabel(task.status)),
                          backgroundColor: _backgroundForStatus(
                            task.status,
                            theme,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        if (task.priority == ScheduleTaskPriority.important ||
                            task.priority == ScheduleTaskPriority.critical)
                          Chip(
                            label: Text(
                              task.priority == ScheduleTaskPriority.critical
                                  ? 'Critical'
                                  : 'Important',
                            ),
                            backgroundColor: theme.colorScheme.errorContainer,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        Text(
                          timeLabel == null
                              ? dateLabel
                              : '$dateLabel · $timeLabel',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (task.subjects.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.subjects.join(', '),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    if ((task.description ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canComplete =
        !task.isCompleted && task.status != ScheduleTaskStatus.skipped;

    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          tooltip: l10n.planningMarkDone,
          color: canComplete ? theme.colorScheme.primary : null,
          onPressed: canComplete ? () => _onMarkDone(context) : null,
        ),
        if (task.source == ScheduleTaskSource.event)
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: l10n.planningReschedule,
            onPressed: () => _onReschedule(context),
          ),
        if (task.source == ScheduleTaskSource.event)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.planningDelete,
            onPressed: () => _onDelete(context),
          ),
      ],
    );
  }

  Future<void> _onMarkDone(BuildContext context) async {
    await cubit.markTaskDone(task);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.planningMarkDone)));
  }

  Future<void> _onReschedule(BuildContext context) async {
    final DateTime initial = task.scheduledAt;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (pickedDate == null || !context.mounted) {
      return;
    }
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        task.hasSpecificTime
            ? initial
            : DateTime(initial.year, initial.month, initial.day, 8),
      ),
    );
    final DateTime newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? initial.hour,
      pickedTime?.minute ?? initial.minute,
    );
    await cubit.rescheduleTask(task, newDateTime);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.planningReschedule)));
  }

  Future<void> _onDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.planningDelete),
          content: Text('Supprimer cette tache ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                MaterialLocalizations.of(dialogContext).cancelButtonLabel,
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                MaterialLocalizations.of(dialogContext).okButtonLabel,
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await cubit.deleteTask(task);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.planningDelete)));
    }
  }

  IconData _iconForCategory(ScheduleTaskCategory category) {
    switch (category) {
      case ScheduleTaskCategory.reproduction:
        return Icons.pets;
      case ScheduleTaskCategory.health:
        return Icons.monitor_heart;
      case ScheduleTaskCategory.logistics:
        return Icons.event_note;
      case ScheduleTaskCategory.monitoring:
        return Icons.track_changes;
    }
  }

  Color _colorForStatus(ScheduleTaskStatus status, ThemeData theme) {
    switch (status) {
      case ScheduleTaskStatus.planned:
        return theme.colorScheme.primary;
      case ScheduleTaskStatus.overdue:
        return theme.colorScheme.error;
      case ScheduleTaskStatus.completed:
        return theme.colorScheme.secondary;
      case ScheduleTaskStatus.skipped:
      case ScheduleTaskStatus.cancelled:
        return theme.colorScheme.outline;
    }
  }

  Color _backgroundForStatus(ScheduleTaskStatus status, ThemeData theme) {
    switch (status) {
      case ScheduleTaskStatus.planned:
        return theme.colorScheme.primaryContainer;
      case ScheduleTaskStatus.overdue:
        return theme.colorScheme.errorContainer;
      case ScheduleTaskStatus.completed:
        return theme.colorScheme.secondaryContainer;
      case ScheduleTaskStatus.skipped:
      case ScheduleTaskStatus.cancelled:
        return theme.colorScheme.surfaceContainerHigh;
    }
  }

  String _statusLabel(ScheduleTaskStatus status) {
    switch (status) {
      case ScheduleTaskStatus.planned:
        return l10n.planningStatusPlanned;
      case ScheduleTaskStatus.overdue:
        return l10n.planningStatusOverdue;
      case ScheduleTaskStatus.completed:
        return l10n.planningStatusCompleted;
      case ScheduleTaskStatus.skipped:
      case ScheduleTaskStatus.cancelled:
        return l10n.planningStatusSkipped;
    }
  }

  String _titleForTask(ScheduleTask task) {
    final String base = task.type.replaceAll('_', ' ');
    if (task.subjects.isNotEmpty) {
      return '$base · ${task.subjects.first}';
    }
    return base;
  }
}
