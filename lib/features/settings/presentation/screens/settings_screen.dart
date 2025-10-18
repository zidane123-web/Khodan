import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/offline_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OfflineCubit>(
      create: (BuildContext context) => OfflineCubit()..initialize(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfflineCubit, OfflineState>(
      listener: (BuildContext context, OfflineState state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (BuildContext context, OfflineState state) {
        final OfflineCubit cubit = context.read<OfflineCubit>();
        final ThemeData theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres'),
          ),
          body: Column(
            children: <Widget>[
              if (state.loading)
                const LinearProgressIndicator(minHeight: 2),
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
                      title: const Text('Mode hors-ligne'),
                      subtitle: Text(
                        state.pendingActions > 0
                            ? 'Synchronisation en attente : ${state.pendingActions} action(s).'
                            : 'Synchronise automatiquement dès le retour du réseau.',
                      ),
                      value: state.enabled,
                      onChanged: state.loading
                          ? null
                          : (bool value) => cubit.toggle(value),
                    ),
                    if (state.pendingActions > 0)
                      ListTile(
                        leading: const Icon(Icons.sync_problem_outlined),
                        title: const Text('Actions en file d’attente'),
                        subtitle: const Text(
                            'Vos modifications seront envoyées dès que la connexion sera disponible.'),
                        trailing: FilledButton.tonalIcon(
                          onPressed: state.loading ? null : cubit.synchronizeNow,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Synchroniser'),
                        ),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.shield_moon_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        state.enabled ? 'Mode hors-ligne actif' : 'Mode en ligne',
                      ),
                      subtitle: Text(
                        state.enabled
                            ? 'Les actions sont enregistrées en local jusqu’à la reconnexion.'
                            : 'Les données sont synchronisées en temps réel.',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Profil de l\'élevage'),
                      subtitle: const Text('Mettre à jour les coordonnées et préférences légales.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsProfileRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Gestion des espèces'),
                      subtitle: const Text('Configurer les durées de gestation et sevrage.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Assistance'),
                      subtitle: const Text('Consulter la base de connaissances et contacter le support.'),
                      trailing: const Icon(Icons.help_outline),
                      onTap: () {
                        context.push(const SettingsContactSupportRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('À propos'),
                      subtitle: const Text('Version, licences et mentions légales.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(const SettingsAboutRoute().location);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.red),
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
