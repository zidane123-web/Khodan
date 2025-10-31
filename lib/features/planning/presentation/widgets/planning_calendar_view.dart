import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/models/schedule_task.dart';
import '../cubit/planning_cubit.dart';
import '../cubit/planning_state.dart';
import '../../../../l10n/app_localizations.dart';
import 'planning_task_tile.dart';

class PlanningCalendarTab extends StatelessWidget {
  const PlanningCalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<PlanningCubit, PlanningState>(
      builder: (BuildContext context, PlanningState state) {
        if (state.status == PlanningStatus.loading &&
            state.calendarBuckets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final PlanningCubit cubit = context.read<PlanningCubit>();
        final DateTime anchor = state.calendarAnchor ?? DateTime.now();
        final DateTime selectedDay = state.selectedDay ?? DateTime.now();
        final List<ScheduleTask> tasksForDay =
            state.calendarBuckets[selectedDay] ?? const <ScheduleTask>[];
        final bool selectionMode = state.selectedTaskIds.isNotEmpty;

        final String monthLabel = DateFormat.yMMMM(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(anchor);

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => cubit.goToAdjacentMonth(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        monthLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => cubit.goToAdjacentMonth(1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<PlanningCalendarView>(
                segments: <ButtonSegment<PlanningCalendarView>>[
                  ButtonSegment<PlanningCalendarView>(
                    value: PlanningCalendarView.month,
                    label: Text(l10n.planningCalendarMonth),
                  ),
                  ButtonSegment<PlanningCalendarView>(
                    value: PlanningCalendarView.week,
                    label: Text(l10n.planningCalendarWeek),
                  ),
                ],
                selected: <PlanningCalendarView>{state.calendarView},
                onSelectionChanged: (Set<PlanningCalendarView> selection) {
                  cubit.setCalendarView(selection.first);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.calendarView == PlanningCalendarView.month
                    ? _MonthGrid(
                        anchor: anchor,
                        selectedDay: selectedDay,
                        buckets: state.calendarBuckets,
                        onSelected: cubit.selectDay,
                      )
                    : _WeekList(
                        selectedDay: selectedDay,
                        buckets: state.calendarBuckets,
                        onSelected: cubit.selectDay,
                      ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: tasksForDay.isEmpty
                  ? Center(child: Text(l10n.planningEmpty))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: tasksForDay.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ScheduleTask task = tasksForDay[index];
                        final bool isSelected = state.selectedTaskIds.contains(
                          task.id,
                        );
                        return PlanningTaskTile(
                          task: task,
                          cubit: cubit,
                          l10n: l10n,
                          selectionMode: selectionMode,
                          isSelected: isSelected,
                          onToggleSelection: () =>
                              cubit.toggleTaskSelection(task.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.anchor,
    required this.selectedDay,
    required this.buckets,
    required this.onSelected,
  });

  final DateTime anchor;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduleTask>> buckets;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final DateTime firstOfMonth = DateTime(anchor.year, anchor.month, 1);
    final int delta = (firstOfMonth.weekday + 6) % 7;
    final DateTime firstCell = firstOfMonth.subtract(Duration(days: delta));
    final List<DateTime> days = <DateTime>[
      for (int i = 0; i < 42; i++)
        DateTime(firstCell.year, firstCell.month, firstCell.day + i),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: days.length,
      itemBuilder: (BuildContext context, int index) {
        final DateTime day = days[index];
        final bool isSelected = _isSameDay(day, selectedDay);
        final bool isCurrentMonth = day.month == anchor.month;
        final List<ScheduleTask> dayTasks =
            buckets[DateTime(day.year, day.month, day.day)] ??
            const <ScheduleTask>[];
        return GestureDetector(
          onTap: () => onSelected(day),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border.all(
                color: isCurrentMonth
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isCurrentMonth
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const Spacer(),
                if (dayTasks.isNotEmpty)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${dayTasks.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WeekList extends StatelessWidget {
  const _WeekList({
    required this.selectedDay,
    required this.buckets,
    required this.onSelected,
  });

  final DateTime selectedDay;
  final Map<DateTime, List<ScheduleTask>> buckets;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final int delta = (selectedDay.weekday + 6) % 7;
    final DateTime weekStart = selectedDay.subtract(Duration(days: delta));
    final List<DateTime> days = <DateTime>[
      for (int i = 0; i < 7; i++)
        DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    ];

    return ListView.separated(
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final DateTime day = days[index];
        final List<ScheduleTask> dayTasks =
            buckets[DateTime(day.year, day.month, day.day)] ??
            const <ScheduleTask>[];
        final bool isSelected =
            day.year == selectedDay.year &&
            day.month == selectedDay.month &&
            day.day == selectedDay.day;
        return ListTile(
          onTap: () => onSelected(day),
          tileColor: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          title: Text(MaterialLocalizations.of(context).formatFullDate(day)),
          trailing: dayTasks.isEmpty
              ? null
              : CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text('${dayTasks.length}'),
                ),
        );
      },
    );
  }
}
