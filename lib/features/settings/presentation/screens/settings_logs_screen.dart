import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/core/logging/diagnostics_service.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/diagnostics_cubit.dart';

class SettingsLogsScreen extends StatelessWidget {
  const SettingsLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiagnosticsCubit>(
      create: (BuildContext context) => DiagnosticsCubit(
        service: DiagnosticsService.instance,
        offlineManager: OfflineSyncManager.instance,
      )..initialize(),
      child: const _DiagnosticsView(),
    );
  }
}

class _DiagnosticsView extends StatelessWidget {
  const _DiagnosticsView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocConsumer<DiagnosticsCubit, DiagnosticsState>(
      listener: (BuildContext context, DiagnosticsState state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<DiagnosticsCubit>().acknowledgeError();
        }
        if (state.infoMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          context.read<DiagnosticsCubit>().acknowledgeInfo();
        }
      },
      builder: (BuildContext context, DiagnosticsState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.logsTitle),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.logsRefresh,
                onPressed: state.loading
                    ? null
                    : () => context
                          .read<DiagnosticsCubit>()
                          .refreshDeviceSnapshot(),
                icon: state.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              if (state.loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<DiagnosticsCubit>().refreshDeviceSnapshot(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: <Widget>[
                      _DeviceInfoCard(
                        diagnostics: state.deviceDiagnostics,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 12),
                      _LoggingToggle(
                        enabled: state.detailedLogging,
                        onChanged: (bool value) => context
                            .read<DiagnosticsCubit>()
                            .toggleDetailedLogging(value),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 12),
                      _ActionsRow(
                        exporting: state.exporting,
                        onExport: () => _handleExport(context, share: false),
                        onShare: () => _handleExport(context, share: true),
                        onClear: () =>
                            context.read<DiagnosticsCubit>().clearLogs(),
                        l10n: l10n,
                      ),
                      const SizedBox(height: 24),
                      _LogsSection(
                        entries: state.entries,
                        theme: theme,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleExport(
    BuildContext context, {
    required bool share,
  }) async {
    final DiagnosticsCubit cubit = context.read<DiagnosticsCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? path = await cubit.exportLogs();
    if (!context.mounted || path == null || !share) {
      return;
    }
    if (kIsWeb) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logsShareUnavailable)),
      );
      return;
    }
    try {
      final Locale locale = Localizations.localeOf(context);
      final DateFormat formatter = DateFormat(
        'dd/MM/yyyy HH:mm',
        locale.toLanguageTag(),
      );
      final XFile file = XFile(path, mimeType: 'text/plain');
      await Share.shareXFiles(
        <XFile>[file],
        subject: l10n.logsShareSubject,
        text: l10n.logsShareText(formatter.format(DateTime.now())),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logsShareError('$error'))),
      );
    }
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.diagnostics, required this.l10n});

  final DeviceDiagnostics? diagnostics;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (diagnostics == null) {
      return Card(
        child: ListTile(
          leading: Icon(
            Icons.devices_other_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text(l10n.logsLoadingTitle),
          subtitle: Text(l10n.logsLoadingSubtitle),
        ),
      );
    }
    final DeviceDiagnostics data = diagnostics!;
    final Locale locale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat(
      'dd/MM/yyyy HH:mm',
      locale.toLanguageTag(),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.logsDeviceInfoTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.devices_other_outlined,
              label: l10n.logsDevicePlatform,
              value: '${data.platform} – ${data.osVersion}',
            ),
            _InfoRow(
              icon: Icons.app_settings_alt_outlined,
              label: l10n.logsDeviceVersion,
              value: '${data.appVersion}+${data.buildNumber}',
            ),
            _InfoRow(
              icon: Icons.language_outlined,
              label: l10n.logsDeviceLanguage,
              value: data.locale,
            ),
            _InfoRow(
              icon: Icons.cloud_sync_outlined,
              label: l10n.logsDeviceOffline,
              value: data.offlineMode
                  ? l10n.logsDeviceOfflineActive
                  : l10n.logsDeviceOfflineInactive,
            ),
            _InfoRow(
              icon: Icons.pending_actions_outlined,
              label: l10n.logsDevicePendingActions,
              value: data.pendingActions.toString(),
            ),
            const Divider(height: 24),
            Text(
              l10n.logsDeviceRefreshedAt(formatter.format(data.generatedAt)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LoggingToggle extends StatelessWidget {
  const _LoggingToggle({
    required this.enabled,
    required this.onChanged,
    required this.l10n,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: enabled,
      onChanged: onChanged,
      title: Text(l10n.logsOfflineToggle),
      subtitle: Text(l10n.logsOfflineToggleHint),
      secondary: const Icon(Icons.bug_report_outlined),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.exporting,
    required this.onExport,
    required this.onShare,
    required this.onClear,
    required this.l10n,
  });

  final bool exporting;
  final VoidCallback onExport;
  final VoidCallback onShare;
  final VoidCallback onClear;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        FilledButton.icon(
          onPressed: exporting ? null : onExport,
          icon: exporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_alt_outlined),
          label: Text(l10n.logsExport),
        ),
        FilledButton.tonalIcon(
          onPressed: exporting ? null : onShare,
          icon: const Icon(Icons.share_outlined),
          label: Text(l10n.logsShare),
        ),
        OutlinedButton.icon(
          onPressed: exporting ? null : onClear,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.logsClear),
        ),
      ],
    );
  }
}

class _LogsSection extends StatelessWidget {
  const _LogsSection({
    required this.entries,
    required this.theme,
    required this.l10n,
  });

  final List<DiagnosticsEntry> entries;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Column(
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(l10n.logsHistoryEmpty, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.logsHistoryDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.logsHistoryCount(entries.length),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...entries.map(
          (DiagnosticsEntry entry) => _LogEntryTile(entry: entry, l10n: l10n),
        ),
      ],
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry, required this.l10n});

  final DiagnosticsEntry entry;
  final AppLocalizations l10n;

  Color _resolveColor(BuildContext context) {
    switch (entry.level) {
      case 'error':
        return Colors.red.shade400;
      case 'warning':
        return Colors.orange.shade400;
      case 'debug':
        return Colors.blueGrey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _resolveIcon() {
    switch (entry.level) {
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'debug':
        return Icons.bug_report_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
      locale.toLanguageTag(),
    );
    final Color accent = _resolveColor(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(_resolveIcon(), color: accent),
        title: Text(entry.message),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.logsEntryMetadata(
                entry.source,
                formatter.format(entry.timestamp.toLocal()),
              ),
              style: theme.textTheme.bodySmall,
            ),
            if (entry.details != null && entry.details!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  entry.details!.trim(),
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
