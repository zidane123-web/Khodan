import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/models/schedule_task.dart';

class PlanningExportService {
  PlanningExportService();

  Future<void> shareCsv({
    required List<ScheduleTask> tasks,
    required AppLocalizations l10n,
  }) async {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final List<List<String>> rows = <List<String>>[
      <String>['Date', 'Type', 'Status', 'Subjects', 'Notes', 'Origin'],
      for (final ScheduleTask task in tasks)
        <String>[
          dateFormat.format(task.scheduledAt),
          task.type,
          _statusLabel(task.status, l10n),
          task.subjects.join(' | '),
          task.description ?? '',
          task.origin ?? task.source.name,
        ],
    ];
    final String csv = const ListToCsvConverter().convert(rows);
    final XFile file = XFile.fromData(
      utf8.encode(csv),
      name: _buildFileName(),
      mimeType: 'text/csv',
    );
    await Share.shareXFiles(
      <XFile>[file],
      subject: l10n.planningExportCsv,
      text: l10n.planningCsvExported,
    );
  }

  String _statusLabel(ScheduleTaskStatus status, AppLocalizations l10n) {
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

  String _buildFileName() {
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmm');
    return 'planning_${formatter.format(DateTime.now())}.csv';
  }
}
