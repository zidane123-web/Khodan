import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/core/constants.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/services/offline_sync_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';

class SettingsProfileScreen extends StatelessWidget {
  const SettingsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthCubit>().state;
    final Profile? seedProfile = authState.profile;
    final String? profileId =
        seedProfile?.id ?? authState.session?.user.id;

    if (profileId == null) {
      return const _MissingProfileView();
    }

    final ProfileRepository repository = context.read<ProfileRepository>();

    return BlocProvider<ProfileCubit>(
      create: (BuildContext context) => ProfileCubit(
        repository: repository,
        profileId: profileId,
        historyStore: ProfileHistoryStore(),
        offlineManager: OfflineSyncManager.instance,
        seed: seedProfile,
      )..initialize(),
      child: const _SettingsProfileView(),
    );
  }
}

class _MissingProfileView extends StatelessWidget {
  const _MissingProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil élevage'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Impossible de charger le profil de l’élevage. '
            'Reconnectez-vous pour réessayer.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SettingsProfileView extends StatefulWidget {
  const _SettingsProfileView();

  @override
  State<_SettingsProfileView> createState() => _SettingsProfileViewState();
}

class _SettingsProfileViewState extends State<_SettingsProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _farmLocationController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Map<String, String> _localeOptions = <String, String>{
    'fr_FR': 'Français (France)',
    'en_US': 'English (US)',
  };

  final List<String> _timeZones = <String>[
    'UTC',
    'Africa/Abidjan',
    'Africa/Dakar',
    'Africa/Nairobi',
    'Europe/Paris',
  ];

  Profile? _lastProfile;
  String? _selectedLocale;
  String? _selectedTimeZone;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _marketingOptIn = false;

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncFromProfile(Profile profile) {
    if (_lastProfile == profile) {
      return;
    }
    _lastProfile = profile;
    _farmNameController.text = profile.farmName;
    _farmLocationController.text = profile.farmLocation ?? '';
    _phoneController.text = profile.phone ?? '';
    _selectedLocale = profile.locale ?? _localeOptions.keys.first;
    _selectedTimeZone = profile.timeZone ?? _timeZones.first;
    _termsAccepted = profile.hasAcceptedTerms;
    _privacyAccepted = profile.hasAcceptedPrivacy;
    _marketingOptIn = profile.marketingOptIn;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (BuildContext context, ProfileState state) {
        if (state.profile != null) {
          setState(() {
            _syncFromProfile(state.profile!);
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<ProfileCubit>().acknowledgeError();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          context.read<ProfileCubit>().acknowledgeSuccess();
        }
      },
      builder: (BuildContext context, ProfileState state) {
        final bool isSaving = state.saving;
        final bool isLoading = state.loading && state.profile == null;
        final Profile? profile = state.profile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil élevage'),
            actions: <Widget>[
              if (state.pendingSync)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Sync en attente'),
                    ],
                  ),
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
                  ? const _MissingProfileContent()
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<ProfileCubit>().refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _buildIdentityCard(theme, profile, isSaving),
                            const SizedBox(height: 16),
                            _buildLegalCard(theme),
                            const SizedBox(height: 16),
                            _buildSubscriptionCard(theme, profile),
                            const SizedBox(height: 16),
                            _buildHistoryCard(theme, state),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: isSaving ? null : () => _submit(context),
                              icon: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                isSaving
                                    ? 'Enregistrement...'
                                    : 'Enregistrer les modifications',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildIdentityCard(
    ThemeData theme,
    Profile profile,
    bool isSaving,
  ) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
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
                'Informations générales',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _farmNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’élevage',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                enabled: !isSaving,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom de l’élevage est requis.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _farmLocationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation',
                  hintText: 'Ville, région...',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                enabled: !isSaving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  helperText: 'Format international recommandé.',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                enabled: !isSaving,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9+(). \-]'),
                  ),
                ],
                validator: (String? value) {
                  final String trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return null;
                  }
                  final RegExp pattern = RegExp(r'^[0-9+(). \-]{6,}$');
                  if (!pattern.hasMatch(trimmed)) {
                    return 'Numéro invalide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(
                  'profile-locale-${_selectedLocale ?? _localeOptions.keys.first}',
                ),
                initialValue: _selectedLocale ?? _localeOptions.keys.first,
                decoration: const InputDecoration(
                  labelText: 'Langue par défaut',
                  prefixIcon: Icon(Icons.language_outlined),
                ),
                items: _localeOptions.entries
                    .map(
                      (MapEntry<String, String> entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (String? value) {
                        setState(() {
                          _selectedLocale = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(
                  'profile-timezone-${_selectedTimeZone ?? _timeZones.first}',
                ),
                initialValue: _selectedTimeZone ?? _timeZones.first,
                decoration: const InputDecoration(
                  labelText: 'Fuseau horaire',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: _timeZones
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (String? value) {
                        setState(() {
                          _selectedTimeZone = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    profile.email.isEmpty ? '?' : profile.email[0].toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: const Text('Adresse email'),
                subtitle: Text(
                  profile.email,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  tooltip: 'Copier',
                  icon: const Icon(Icons.copy_all_outlined),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: profile.email));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email copié')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          SwitchListTile.adaptive(
            value: _termsAccepted,
            onChanged: (bool value) {
              setState(() {
                _termsAccepted = value;
              });
            },
            title: const Text('CGU acceptées'),
            subtitle: const Text('Autorise l’utilisation du service.'),
            secondary: const Icon(Icons.rule_folder_outlined),
          ),
          const Divider(height: 0),
          SwitchListTile.adaptive(
            value: _privacyAccepted,
            onChanged: (bool value) {
              setState(() {
                _privacyAccepted = value;
              });
            },
            title: const Text('Politique de confidentialité'),
            subtitle: const Text('Consentement au stockage sécurisé des données.'),
            secondary: const Icon(Icons.privacy_tip_outlined),
          ),
          const Divider(height: 0),
          SwitchListTile.adaptive(
            value: _marketingOptIn,
            onChanged: (bool value) {
              setState(() {
                _marketingOptIn = value;
              });
            },
            title: const Text('Recevoir les nouveautés par email'),
            secondary: const Icon(Icons.campaign_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme, Profile profile) {
    final String status = profile.billingStatus ?? 'Non défini';
    final Color badgeColor = status == 'active'
        ? Colors.green
        : status == 'trialing'
            ? Colors.orange
            : theme.colorScheme.outline;
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
              'Abonnement & Facturation',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Dernière mise à jour : ${profile.updatedAt.toLocal()}",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Besoin d’ajuster votre plan ? Contactez le support via ${AppConstants.supportEmail}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: AppConstants.supportEmail),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adresse support copiée pour mise à niveau.'),
                  ),
                );
              },
              icon: const Icon(Icons.upgrade_outlined),
              label: const Text('Contacter le support facturation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme, ProfileState state) {
    final List<ProfileHistoryEntry> entries = state.history;
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
              'Historique des modifications',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('Aucune modification enregistrée pour le moment.')
            else
              ...entries
                  .take(5)
                  .map(
                    (ProfileHistoryEntry entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_outlined),
                      title: Text(entry.summary),
                      subtitle: Text(
                        entry.timestamp.toLocal().toString(),
                      ),
                    ),
                  ),
            if (entries.length > 5)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '+${entries.length - 5} autres entrées en mémoire',
                  style: theme.textTheme.labelMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final ProfileCubit cubit = context.read<ProfileCubit>();
    final ProfileState state = cubit.state;
    final Profile? profile = state.profile;
    if (profile == null) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String farmName = _farmNameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String location = _farmLocationController.text.trim();

    final Profile updated = profile.copyWith(
      farmName: farmName,
      phone: phone.isEmpty ? null : phone,
      farmLocation: location.isEmpty ? null : location,
      locale: _selectedLocale,
      timeZone: _selectedTimeZone,
      legalPreferences: <String, dynamic>{
        'termsAccepted': _termsAccepted,
        'privacyAccepted': _privacyAccepted,
        'marketingOptIn': _marketingOptIn,
      },
      updatedAt: DateTime.now(),
    );

    if (!_termsAccepted || !_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez accepter les CGU et la politique de confidentialité.',
          ),
        ),
      );
      return;
    }

    cubit.save(updated);
  }
}

class _MissingProfileContent extends StatelessWidget {
  const _MissingProfileContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune donnée de profil disponible hors connexion. '
          'Reconnectez-vous pour synchroniser votre compte.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
