import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/core/constants.dart';
import '../../../../data/models/support_request.dart';
import '../../../../data/repositories/support_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/support_cubit.dart';

class SettingsContactSupportScreen extends StatelessWidget {
  const SettingsContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthCubit>().state;
    final String? profileId =
        authState.profile?.id ?? authState.session?.user.id;
    final String? email =
        authState.profile?.email ?? authState.session?.user.email;

    if (profileId == null || email == null) {
      return const _MissingSessionView();
    }

    final SupportRepository repository = context.read<SupportRepository>();

    return BlocProvider<SupportCubit>(
      create: (BuildContext context) => SupportCubit(
        repository: repository,
        profileId: profileId,
        contactEmail: email,
        offlineManager: OfflineSyncManager.instance,
      ),
      child: const _SupportView(),
    );
  }
}

class _MissingSessionView extends StatelessWidget {
  const _MissingSessionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact support'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Vous devez être connecté pour contacter le support.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SupportView extends StatefulWidget {
  const _SupportView();

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _priority = 'normal';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacter le support'),
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (BuildContext context, SupportState state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<SupportCubit>().acknowledgeError();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<SupportCubit>().acknowledgeSuccess();
            _subjectController.clear();
            _messageController.clear();
            setState(() {
              _priority = 'normal';
            });
          }
        },
        builder: (BuildContext context, SupportState state) {
          return ValueListenableBuilder<bool>(
            valueListenable: OfflineSyncManager.instance.isOffline,
            builder: (
              BuildContext context,
              bool isOffline,
              Widget? child,
            ) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (isOffline)
                      Card(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const ListTile(
                          leading: Icon(Icons.cloud_off_outlined),
                          title: Text('Mode hors connexion'),
                          subtitle: Text(
                            'Votre message sera envoyé automatiquement dès le retour du réseau.',
                          ),
                        ),
                      ),
                    _buildQuickActions(theme),
                    const SizedBox(height: 16),
                    _buildFormCard(context, state),
                    const SizedBox(height: 24),
                    _buildRecentRequests(theme, state),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('support@khodan.app'),
            subtitle: const Text('Réponse sous 24h ouvrées.'),
            trailing: IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: AppConstants.supportEmail),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Adresse support copiée')),
                );
              },
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Base de connaissances'),
            subtitle: const Text(
              'Consultez les guides d’utilisation et FAQ.',
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/settings/support/knowledge');
            },
            trailing: const Icon(Icons.open_in_new_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, SupportState state) {
    final ThemeData theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Envoyer un message',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Sujet',
                  prefixIcon: Icon(Icons.subject_outlined),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez préciser le sujet.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey<String>('support-priority-$_priority'),
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  prefixIcon: Icon(Icons.whatshot_outlined),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'normal',
                    child: Text('Normale'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'urgent',
                    child: Text('Urgente'),
                  ),
                ],
                onChanged: state.submitting
                    ? null
                    : (String? value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  hintText:
                      'Décrivez votre question ou le problème rencontré en fournissant le plus de détails possible.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (String? value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Merci de détailler votre demande (au moins 10 caractères).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed:
                    state.submitting ? null : () => _submit(context, state),
                icon: state.submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  state.submitting ? 'Envoi en cours...' : 'Envoyer au support',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRequests(ThemeData theme, SupportState state) {
    final List<SupportRequest> entries = state.recentRequests;
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Derniers tickets',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...entries.take(5).map(
                  (SupportRequest request) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      request.priority == 'urgent'
                          ? Icons.priority_high_outlined
                          : Icons.inbox_outlined,
                    ),
                    title: Text(request.subject),
                    subtitle: Text(
                      request.createdAt.toLocal().toString(),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, SupportState state) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<SupportCubit>().submit(
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
          priority: _priority,
        );
  }
}
