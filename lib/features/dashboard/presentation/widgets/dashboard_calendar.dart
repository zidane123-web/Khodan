import 'package:flutter/material.dart';

import '../cubit/dashboard_cubit.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({
    required this.events,
    super.key,
  });

  final List<DashboardCalendarEvent> events;

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

enum _CalendarViewMode { week, month }

class _DashboardCalendarState extends State<DashboardCalendar> {
  _CalendarViewMode _mode = _CalendarViewMode.week;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<DateTime, List<DashboardCalendarEvent>> groupedEvents =
        _groupEventsByDate(widget.events);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Calendrier des événements',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                SegmentedButton<_CalendarViewMode>(
                  segments: const <ButtonSegment<_CalendarViewMode>>[
                    ButtonSegment<_CalendarViewMode>(
                      value: _CalendarViewMode.week,
                      label: Text('Semaine'),
                    ),
                    ButtonSegment<_CalendarViewMode>(
                      value: _CalendarViewMode.month,
                      label: Text('Mois'),
                    ),
                  ],
                  selected: <_CalendarViewMode>{_mode},
                  onSelectionChanged: (Set<_CalendarViewMode> selection) {
                    setState(() {
                      _mode = selection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.events.isEmpty)
              Text(
                'Aucun événement planifié pour le moment.',
                style: theme.textTheme.bodyMedium,
              )
            else if (_mode == _CalendarViewMode.week)
              _buildWeekView(context, groupedEvents)
            else
              _buildMonthView(context, groupedEvents),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<DashboardCalendarEvent>> _groupEventsByDate(
    List<DashboardCalendarEvent> events,
  ) {
    final Map<DateTime, List<DashboardCalendarEvent>> grouped =
        <DateTime, List<DashboardCalendarEvent>>{};
    for (final DashboardCalendarEvent event in events) {
      final DateTime key = DateTime(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(key, () => <DashboardCalendarEvent>[]).add(event);
    }
    return grouped;
  }

  Widget _buildWeekView(
    BuildContext context,
    Map<DateTime, List<DashboardCalendarEvent>> grouped,
  ) {
    final ThemeData theme = Theme.of(context);
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));
    final List<DateTime> days = List<DateTime>.generate(
      7,
      (int index) => startOfWeek.add(Duration(days: index)),
    );

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final DateTime day = days[index];
          final List<DashboardCalendarEvent> events =
              grouped[day] ?? <DashboardCalendarEvent>[];
          final bool isToday = DateUtils.isSameDay(day, today);

          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isToday ? theme.colorScheme.primary : theme.dividerColor,
              ),
              color: isToday
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : theme.colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _weekdayLabel(day.weekday),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isToday ? theme.colorScheme.primary : null,
                  ),
                ),
                Text(
                  MaterialLocalizations.of(context).formatShortDate(day),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  Text(
                    'Rien de prévu',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  ...events.take(3).map((DashboardCalendarEvent event) {
                    final Color color = _colorForCategory(event.category, theme);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  event.title,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                if (event.subtitle != null &&
                                    event.subtitle!.isNotEmpty)
                                  Text(
                                    event.subtitle!,
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                if (events.length > 3)
                  Text(
                    '+${events.length - 3} autres',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthView(
    BuildContext context,
    Map<DateTime, List<DashboardCalendarEvent>> grouped,
  ) {
    final ThemeData theme = Theme.of(context);
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime firstDayOfMonth = DateTime(today.year, today.month);
    final int daysInMonth = DateUtils.getDaysInMonth(today.year, today.month);
    final int leadingEmpty = firstDayOfMonth.weekday - 1;

    final List<List<DateTime?>> weeks = <List<DateTime?>>[];
    List<DateTime?> currentWeek = <DateTime?>[];

    for (int i = 0; i < leadingEmpty; i++) {
      currentWeek.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(today.year, today.month, day);
      currentWeek.add(date);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = <DateTime?>[];
      }
    }

    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            for (final String label in _weekdayHeaders)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final List<DateTime?> week in weeks)
          Row(
            children: week
                .map((DateTime? date) => _buildMonthCell(
                      context,
                      date,
                      today,
                      grouped,
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildMonthCell(
    BuildContext context,
    DateTime? date,
    DateTime today,
    Map<DateTime, List<DashboardCalendarEvent>> grouped,
  ) {
    final ThemeData theme = Theme.of(context);
    if (date == null) {
      return Expanded(child: SizedBox(height: 64));
    }
    final List<DashboardCalendarEvent> events =
        grouped[date] ?? <DashboardCalendarEvent>[];
    final bool isToday = DateUtils.isSameDay(date, today);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday ? theme.colorScheme.primary : theme.dividerColor,
            width: isToday ? 1.5 : 1,
          ),
          color:
              isToday ? theme.colorScheme.primary.withOpacity(0.08) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              date.day.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: isToday ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            if (events.isEmpty)
              const SizedBox(height: 0)
            else
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: events.take(3).map((DashboardCalendarEvent event) {
                  final Color color = _colorForCategory(event.category, theme);
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            if (events.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${events.length - 3}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorForCategory(
    DashboardCalendarCategory category,
    ThemeData theme,
  ) {
    switch (category) {
      case DashboardCalendarCategory.taskPalpation:
        return theme.colorScheme.primary;
      case DashboardCalendarCategory.taskKindling:
        return theme.colorScheme.secondary;
      case DashboardCalendarCategory.taskWeaning:
        return theme.colorScheme.tertiary;
      case DashboardCalendarCategory.scheduledMating:
        return theme.colorScheme.primary;
      case DashboardCalendarCategory.health:
        return theme.colorScheme.error;
      case DashboardCalendarCategory.treatment:
        return theme.colorScheme.secondaryContainer;
      case DashboardCalendarCategory.weight:
        return theme.colorScheme.tertiaryContainer;
      case DashboardCalendarCategory.housing:
        return theme.colorScheme.primaryContainer;
      case DashboardCalendarCategory.general:
        return theme.colorScheme.outline;
    }
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        return '';
    }
  }

  static const List<String> _weekdayHeaders = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];
}
