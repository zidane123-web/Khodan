// Generated localization file. Do not modify by hand.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Khodan';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAnimals => 'Breeders';

  @override
  String get navEvents => 'Litters & Cages';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get navPlanning => 'Schedule';

  @override
  String get navPlanningDescription =>
      'Plan breeding tasks and review the agenda.';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navNotificationsDescription =>
      'Track critical alerts and upcoming reminders.';

  @override
  String get navHelpCenter => 'Help Center';

  @override
  String get navHelpCenterDescription => 'Access guides and support articles.';

  @override
  String get navMore => 'More';

  @override
  String get placeholderPlanningTitle => 'Schedule coming soon';

  @override
  String get placeholderPlanningMessage =>
      'The planning module will arrive soon. The calendar and tasks will live here.';

  @override
  String get placeholderNotificationsTitle => 'Notifications coming soon';

  @override
  String get placeholderNotificationsMessage =>
      'Alerts and reminders will appear here once the module is enabled.';

  @override
  String get placeholderFabLabel => 'Quick action';

  @override
  String get placeholderFabMessage =>
      'This shortcut will become available when the feature is ready.';

  @override
  String get settingsSupportSection => 'Support and Diagnostics';

  @override
  String get settingsKnowledgeBase => 'Knowledge Base';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get settingsLogs => 'Logs and Diagnostics';

  @override
  String get settingsOfflineSection => 'Offline Mode';

  @override
  String get settingsOfflineToggle => 'Enable offline mode';

  @override
  String get settingsSupportDescription =>
      'Browse guides, reach the team, and export diagnostics logs.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsOfflineSummaryPending(int count) {
    return 'Pending sync: $count action(s).';
  }

  @override
  String get settingsOfflineSummaryReady =>
      'Automatically synchronises as soon as the network is back.';

  @override
  String get settingsOfflineQueueTitle => 'Pending actions';

  @override
  String get settingsOfflineQueueSubtitle =>
      'Your changes will be sent as soon as a connection is available.';

  @override
  String get settingsOfflineQueueButton => 'Synchronise';

  @override
  String get settingsOfflineStatusOffline => 'Offline mode enabled';

  @override
  String get settingsOfflineStatusOnline => 'Online mode';

  @override
  String get settingsOfflineStatusOfflineDetails =>
      'Actions are stored locally until the app reconnects.';

  @override
  String get settingsOfflineStatusOnlineDetails =>
      'Data is synchronised in real time.';

  @override
  String get settingsProfileTitle => 'Farm profile';

  @override
  String get settingsProfileSubtitle =>
      'Update your contact details and legal preferences.';

  @override
  String get settingsSpeciesTitle => 'Species management';

  @override
  String get settingsSpeciesSubtitle =>
      'Configure gestation and weaning durations.';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutSubtitle => 'Version, licences, and legal notices.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get knowledgeBaseTitle => 'Knowledge Base';

  @override
  String get knowledgeBaseRefresh => 'Refresh';

  @override
  String get knowledgeBaseSearchHint => 'Search guides, FAQ, keywords…';

  @override
  String get knowledgeBaseOfflineBanner =>
      'Offline mode: the articles shown are loaded from your local cache.';

  @override
  String knowledgeBaseLastUpdate(Object date) {
    return 'Last updated: $date';
  }

  @override
  String knowledgeBaseUpdatedAt(Object date) {
    return 'Updated $date';
  }

  @override
  String get knowledgeBaseEmpty => 'No article matches your search.';

  @override
  String get knowledgeBaseRetry => 'Retry';

  @override
  String knowledgeBaseLastSync(Object date) {
    return 'Last synchronisation: $date';
  }

  @override
  String get knowledgeBaseEmptyHelp =>
      'We could not find an article for your search.\nTry different keywords or reach out to support.';

  @override
  String knowledgeBaseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'No article found',
    );
    return '$_temp0';
  }

  @override
  String get commonClear => 'Clear';

  @override
  String get logsTitle => 'Logs and Diagnostics';

  @override
  String get logsRefresh => 'Refresh diagnostics';

  @override
  String get logsOfflineToggle => 'Detailed logging';

  @override
  String get logsExport => 'Export';

  @override
  String get logsShare => 'Share';

  @override
  String get logsClear => 'Clear history';

  @override
  String logsShareError(Object error) {
    return 'Unable to share: $error';
  }

  @override
  String get logsShareUnavailable =>
      'File sharing is not available on the web.';

  @override
  String get logsFileGenerated => 'Log file generated.';

  @override
  String get logsHistoryEmpty => 'No logs to display.';

  @override
  String get logsHistoryDescription =>
      'Sync actions and errors will show up here.';

  @override
  String get logsLoadingTitle => 'Collecting system information…';

  @override
  String get logsLoadingSubtitle => 'Please wait a few seconds.';

  @override
  String get logsDeviceInfoTitle => 'Device and environment';

  @override
  String get logsDevicePlatform => 'Platform';

  @override
  String get logsDeviceVersion => 'App version';

  @override
  String get logsDeviceLanguage => 'Language';

  @override
  String get logsDeviceOffline => 'Offline mode';

  @override
  String get logsDeviceOfflineActive => 'Enabled';

  @override
  String get logsDeviceOfflineInactive => 'Disabled';

  @override
  String get logsDevicePendingActions => 'Pending actions';

  @override
  String logsDeviceRefreshedAt(Object date) {
    return 'Last updated: $date';
  }

  @override
  String get logsOfflineToggleHint =>
      'Captures verbose logs (may include sensitive data).';

  @override
  String logsHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'History ($count)',
      one: 'History (1)',
      zero: 'History',
    );
    return '$_temp0';
  }

  @override
  String logsEntryMetadata(Object source, Object timestamp) {
    return '$source – $timestamp';
  }

  @override
  String get logsShareSubject => 'Khodan logs';

  @override
  String logsShareText(Object date) {
    return 'Khodan diagnostic logs generated on $date.';
  }

  @override
  String get contactSupportTitle => 'Contact support';

  @override
  String get contactSupportSubmit => 'Send to support';

  @override
  String get contactSupportSubjectLabel => 'Subject';

  @override
  String get contactSupportMessageLabel => 'Message';

  @override
  String get contactSupportPriorityLabel => 'Priority';

  @override
  String get contactSupportOfflineNotice => 'Offline mode';

  @override
  String get contactSupportOfflineDetails =>
      'Your request will be sent as soon as the connection is restored.';

  @override
  String get contactSupportMissingSession =>
      'You must be signed in to contact support.';

  @override
  String get contactSupportSubjectValidation => 'Please provide a subject.';

  @override
  String get contactSupportPriorityNormal => 'Normal';

  @override
  String get contactSupportPriorityUrgent => 'Urgent';

  @override
  String get contactSupportMessageHint =>
      'Describe your question or the issue with as many details as possible.';

  @override
  String get contactSupportMessageValidation =>
      'Please add more details (minimum 10 characters).';

  @override
  String get contactSupportSubmitting => 'Sending…';

  @override
  String get contactSupportRecentTitle => 'Latest tickets';

  @override
  String get planningTitle => 'Schedule';

  @override
  String get planningSearchHint => 'Search tasks, animals, notes…';

  @override
  String get planningTabList => 'List';

  @override
  String get planningTabCalendar => 'Calendar';

  @override
  String get planningTabChain => 'Chain';

  @override
  String get planningFilterStatus => 'Status';

  @override
  String get planningFilterPeriod => 'Period';

  @override
  String get planningFilterType => 'Type';

  @override
  String get planningFilterReset => 'Reset';

  @override
  String get planningStatusPlanned => 'To do';

  @override
  String get planningStatusCompleted => 'Done';

  @override
  String get planningStatusOverdue => 'Overdue';

  @override
  String get planningStatusSkipped => 'Skipped';

  @override
  String get planningPeriodAll => 'All';

  @override
  String get planningPeriodToday => 'Today';

  @override
  String get planningPeriodWeek => '7 days';

  @override
  String get planningPeriodMonth => '30 days';

  @override
  String get planningEmpty => 'No task matches your filters.';

  @override
  String planningOfflinePending(int count) {
    return '$count offline action(s) pending';
  }

  @override
  String get planningOfflineViewQueue => 'View queue';

  @override
  String get planningMarkDone => 'Mark done';

  @override
  String get planningReschedule => 'Reschedule';

  @override
  String get planningDelete => 'Delete';

  @override
  String get planningExportCsv => 'Export CSV';

  @override
  String get planningExportIcalDisabled => 'Export iCal (coming soon)';

  @override
  String get planningCalendarMonth => 'Month';

  @override
  String get planningCalendarWeek => 'Week';

  @override
  String get planningChainSection => 'Reproduction chains';

  @override
  String get planningChainEmpty => 'No reproduction chain to display.';

  @override
  String planningSelectionCount(int count) {
    return '$count selected';
  }

  @override
  String get planningBulkComplete => 'Complete selected';

  @override
  String get planningBulkExport => 'Export selection';

  @override
  String get planningCsvExported => 'CSV generated';
}
