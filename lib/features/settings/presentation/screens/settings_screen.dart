import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/offline_cubit.dart';
import '../cubit/sync_history_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SyncHistoryCubit>(
          create: (BuildContext context) => SyncHistoryCubit()..initialize(),
        ),
        BlocProvider<OfflineCubit>(
          create: (BuildContext context) =>
              OfflineCubit(historyCubit: context.read<SyncHistoryCubit>())
                ..initialize(),
        ),
      ],
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocConsumer<OfflineCubit, OfflineState>(
      listener: (BuildContext context, OfflineState state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, OfflineState state) {
        final OfflineCubit cubit = context.read<OfflineCubit>();
        final ThemeData theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: Column(
            children: <Widget>[
              if (state.loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SwitchListTile(
                      secondary: state.loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              state.enabled
                                  ? Icons.cloud_off_outlined
                                  : Icons.cloud_sync_outlined,
                            ),
                      title: Text(l10n.settingsOfflineSection),
                      subtitle: Text(
                        state.pendingActions > 0
                            ? l10n.settingsOfflineSummaryPending(
                                state.pendingActions,
                              )
                            : l10n.settingsOfflineSummaryReady,
                      ),
                      value: state.enabled,
                      onChanged: state.loading
                          ? null
                          : (bool value) => cubit.toggle(value),
                    ),
                    if (state.pendingActions > 0)
                      ListTile(
                        leading: const Icon(Icons.sync_problem_outlined),
                        title: Text(l10n.settingsOfflineQueueTitle),
                        subtitle: Text(l10n.settingsOfflineQueueSubtitle),
                        trailing: FilledButton.tonalIcon(
                          onPressed: state.loading
                              ? null
                              : cubit.synchronizeNow,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.settingsOfflineQueueButton),
                        ),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.shield_moon_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        state.enabled
                            ? l10n.settingsOfflineStatusOffline
                            : l10n.settingsOfflineStatusOnline,
                      ),
                      subtitle: Text(
                        state.enabled
                            ? l10n.settingsOfflineStatusOfflineDetails
                            : l10n.settingsOfflineStatusOnlineDetails,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(l10n.settingsProfileTitle),
                      subtitle: Text(l10n.settingsProfileSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsProfileRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: const Text('Mon compte'),
                      subtitle: const Text('Plan, membres et factures'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsAccountRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.pets_outlined),
                      title: Text(l10n.settingsSpeciesTitle),
                      subtitle: Text(l10n.settingsSpeciesSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(
                          const SettingsReferentialsRoute().location,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        l10n.settingsSupportSection,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.library_books_outlined),
                      title: Text(l10n.settingsKnowledgeBase),
                      subtitle: Text(l10n.settingsSupportDescription),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(
                          const SettingsKnowledgeBaseRoute().location,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined),
                      title: Text(l10n.settingsContactSupport),
                      subtitle: Text(l10n.settingsSupportDescription),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(
                          const SettingsContactSupportRoute().location,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.subject_outlined),
                      title: Text(l10n.settingsLogs),
                      subtitle: Text(l10n.settingsSupportDescription),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsLogsRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.settingsAboutTitle),
                      subtitle: Text(l10n.settingsAboutSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsAboutRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(
                        l10n.settingsSignOut,
                        style: const TextStyle(color: Colors.red),
                      ),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () async {
                        await context.read<AuthCubit>().signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
