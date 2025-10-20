import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/core/constants.dart';
import '../../../../data/models/support_request.dart';
import '../../../../data/repositories/support_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../../../l10n/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactSupportTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.contactSupportMissingSession,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactSupportTitle)),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (BuildContext context, SupportState state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<SupportCubit>().acknowledgeError();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
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
            builder: (BuildContext context, bool isOffline, Widget? child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (isOffline)
                      Card(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: ListTile(
                          leading: const Icon(Icons.cloud_off_outlined),
                          title: Text(l10n.contactSupportOfflineNotice),
                          subtitle: Text(l10n.contactSupportOfflineDetails),
                        ),
                      ),
                    _buildForm(context, state, l10n),
                    const SizedBox(height: 24),
                    _buildRecentRequests(theme, state, l10n),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    SupportState state,
    AppLocalizations l10n,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _subjectController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.contactSupportSubjectLabel,
              prefixIcon: const Icon(Icons.topic_outlined),
            ),
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(AppConstants.supportSubjectMaxLength),
            ],
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.contactSupportSubjectValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey<String>('support-priority-$_priority'),
            initialValue: _priority,
            decoration: InputDecoration(
              labelText: l10n.contactSupportPriorityLabel,
              prefixIcon: const Icon(Icons.whatshot_outlined),
            ),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'normal',
                child: Text(l10n.contactSupportPriorityNormal),
              ),
              DropdownMenuItem<String>(
                value: 'urgent',
                child: Text(l10n.contactSupportPriorityUrgent),
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
            decoration: InputDecoration(
              labelText: l10n.contactSupportMessageLabel,
              alignLabelWithHint: true,
              hintText: l10n.contactSupportMessageHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 6,
            validator: (String? value) {
              if (value == null || value.trim().length < 10) {
                return l10n.contactSupportMessageValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.submitting ? null : () => _submit(context, state),
            icon: state.submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(
              state.submitting
                  ? l10n.contactSupportSubmitting
                  : l10n.contactSupportSubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(
    ThemeData theme,
    SupportState state,
    AppLocalizations l10n,
  ) {
    final List<SupportRequest> entries = state.recentRequests;
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    final DateFormat formatter = DateFormat.yMd(
      locale.toLanguageTag(),
    ).add_Hm();
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
              l10n.contactSupportRecentTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...entries
                .take(5)
                .map(
                  (SupportRequest request) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      request.priority == 'urgent'
                          ? Icons.priority_high_outlined
                          : Icons.inbox_outlined,
                    ),
                    title: Text(request.subject),
                    subtitle: Text(
                      formatter.format(request.createdAt.toLocal()),
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
