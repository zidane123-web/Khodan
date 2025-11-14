import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/farm_member.dart';
import '../../../../data/models/subscription_plan.dart';
import '../../../../data/models/user_subscription.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/subscription_cubit.dart';
import '../widgets/subscription_quota_banner.dart';

class MonComptePage extends StatelessWidget {
  const MonComptePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.watch<AuthCubit>().state;
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (BuildContext context, SubscriptionState state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<SubscriptionCubit>().acknowledgeError();
        } else if (state.infoMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.infoMessage!)),
          );
          context.read<SubscriptionCubit>().acknowledgeInfo();
        }
      },
      builder: (BuildContext context, SubscriptionState state) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mon compte'),
              bottom: const TabBar(
                tabs: <Widget>[
                  Tab(text: 'Mes infos'),
                  Tab(text: 'Abonnement'),
                  Tab(text: 'Factures'),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  onPressed:
                      state.loading ? null : context.read<SubscriptionCubit>().refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                if (state.showQuotaBanner)
                  SubscriptionQuotaBanner(
                    state: state,
                    onAction: state.pendingAction
                        ? null
                        : () => _openPlanSheet(context, state),
                  ),
                if (!state.tutorialDismissed)
                  _TutorialCard(
                    onDismiss: context.read<SubscriptionCubit>().dismissTutorial,
                  ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _InfosTab(authState: authState, subscriptionState: state),
                      _SubscriptionTab(
                        state: state,
                        onChangePlan: () => _openPlanSheet(context, state),
                      ),
                      _InvoicesTab(state: state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPlanSheet(BuildContext context, SubscriptionState state) {
    final List<SubscriptionPlan> plans = state.plans;
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun plan disponible pour le moment.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Choisir un plan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final SubscriptionPlan plan = plans[index];
                      final bool isCurrent =
                          state.current?.plan?.code == plan.code;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      plan.label,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Chip(
                                      label: const Text('Plan actuel'),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(plan.description ?? ''),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _PlanInfoChip(
                                    icon: Icons.pets,
                                    label:
                                        'Éleveurs: ${plan.maxBreeders?.toString() ?? 'illimités'}',
                                  ),
                                  _PlanInfoChip(
                                    icon: Icons.group,
                                    label:
                                        'Membres: ${plan.maxMembers?.toString() ?? 'illimités'}',
                                  ),
                                  _PlanInfoChip(
                                    icon: Icons.cloud_upload,
                                    label:
                                        'Stockage: ${plan.storageLimitMb == null ? 'illimité' : '${plan.storageLimitMb} Mo'}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: state.pendingAction
                                          || isCurrent
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                          context
                                              .read<SubscriptionCubit>()
                                              .requestPlanChange(plan);
                                        },
                                  child: const Text('Choisir ce plan'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfosTab extends StatelessWidget {
  const _InfosTab({required this.authState, required this.subscriptionState});

  final AuthState authState;
  final SubscriptionState subscriptionState;

  @override
  Widget build(BuildContext context) {
    final profile = authState.profile;
    return RefreshIndicator(
      onRefresh: context.read<SubscriptionCubit>().refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (profile == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Profil en cours de synchronisation. Réessayez dans un instant.',
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.farmName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(profile.email),
                    const SizedBox(height: 8),
                    Text(profile.farmLocation ?? 'Localisation non renseignée'),
                    const SizedBox(height: 8),
                    Text('Plan: ${subscriptionState.activePlan?.label ?? 'Free'}'),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/settings/profile'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifier mes informations'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Besoin d’aide ?'),
              subtitle: const Text('Contactez support@khodan.agri pour toute question facturation.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTab extends StatelessWidget {
  const _SubscriptionTab({required this.state, required this.onChangePlan});

  final SubscriptionState state;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    final List<FarmMember> members = state.members;
    final bool canAddMember = !state.membersLimitReached;
    final List<FarmMember> activeMembers =
        members.where((FarmMember member) => member.status != 'removed').toList();
    return RefreshIndicator(
      onRefresh: context.read<SubscriptionCubit>().refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    state.activePlan?.label ?? 'Plan gratuit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Éleveurs utilisés : ${state.breedersUsed}/${state.maxBreeders ?? '∞'}',
                  ),
                  Text(
                    'Membres : ${state.membersUsed}/${state.maxMembers ?? '∞'}',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.pendingAction ? null : onChangePlan,
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Changer de plan'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.current?.manualPaymentReference != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Paiement manuel en cours',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Référence : ${state.current!.manualPaymentReference}',
                    ),
                    const SizedBox(height: 4),
                    const Text('Envoyez votre reçu à support@khodan.agri pour activer le plan.'),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: state.current!.manualPaymentReference!,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Référence copiée.')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copier la référence'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Membres de la ferme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: canAddMember
                    ? () => _showAddMemberDialog(context)
                    : null,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Ajouter un membre'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (activeMembers.isEmpty)
            const Text('Aucun membre ajouté pour l’instant.')
          else
            ...activeMembers.map(
              (FarmMember member) => Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(member.displayName ?? member.email),
                  subtitle: Text('Role: ${member.role} - Statut: ${member.status}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => context
                        .read<SubscriptionCubit>()
                        .removeMember(member.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    String role = 'viewer';
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un membre'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom (optionnel)'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Email requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'viewer', child: Text('Lecture seule')),
                    DropdownMenuItem(value: 'technician', child: Text('Technicien')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      role = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Inviter'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      if (!context.mounted) {
        return;
      }
      await context.read<SubscriptionCubit>().addMember(
            email: emailController.text.trim(),
            displayName: nameController.text.trim().isEmpty
                ? null
                : nameController.text.trim(),
            role: role,
          );
    }
  }
}

class _InvoicesTab extends StatelessWidget {
  const _InvoicesTab({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final UserSubscription? subscription = state.current;
    final List<_InvoiceEntry> entries = <_InvoiceEntry>[];
    if (subscription?.invoiceUrl != null) {
      entries.add(
        _InvoiceEntry(
          label: 'Facture la plus récente',
          url: subscription!.invoiceUrl!,
        ),
      );
    }
    if (subscription?.manualPaymentReference != null) {
      entries.add(
        _InvoiceEntry(
          label: 'Reçu manuel à valider',
          reference: subscription!.manualPaymentReference,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: context.read<SubscriptionCubit>().refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.isEmpty ? 1 : entries.length,
        itemBuilder: (BuildContext context, int index) {
          if (entries.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune facture disponible pour le moment.'),
              ),
            );
          }
          final _InvoiceEntry entry = entries[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(entry.label),
              subtitle: entry.reference == null
                  ? Text(entry.url ?? '')
                  : Text('Référence ${entry.reference} (mock)'),
              trailing: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        entry.reference == null
                            ? 'Téléchargement simulé (${entry.url}).'
                            : 'Téléchargement mock - référence ${entry.reference}.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Télécharger'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanInfoChip extends StatelessWidget {
  const _PlanInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tutoriel express',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('1. Choisissez un plan adapté à votre ferme.'),
            const Text('2. Recevez une référence de paiement sécurisée.'),
            const Text('3. Envoyez le reçu pour activation par Khodan.'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text('Compris'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceEntry {
  _InvoiceEntry({required this.label, this.url, this.reference});

  final String label;
  final String? url;
  final String? reference;
}
