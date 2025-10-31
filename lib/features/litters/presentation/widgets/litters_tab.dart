import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/litter.dart';
import '../cubit/litters_cubit.dart';
import 'empty_state.dart';
import 'info_chip.dart';
import 'litter_dialogs.dart';
import 'offline_banner.dart';

class LittersTab extends StatelessWidget {
  const LittersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LittersCubit, LittersState>(
      builder: (BuildContext context, LittersState state) {
        if (state.status == LittersStatus.loading && state.litters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LittersStatus.failure && state.litters.isEmpty) {
          return EmptyState(
            message: state.errorMessage ??
                'Impossible de charger les portees pour le moment.',
            onRetry: () => context.read<LittersCubit>().load(),
          );
        }

        return Column(
          children: <Widget>[
            if (state.hasPendingSync)
              const OfflineBanner(
                message: 'Mode hors-ligne actif. Synchronisation des portees en attente.',
              ),
            if (state.hasSelection)
              _LitterSelectionBar(count: state.selectedIds.length),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<LittersCubit>().load(),
                child: state.litters.isEmpty
                    ? ListView(
                        children: const <Widget>[
                          EmptyState(
                            message:
                                'Aucune portee enregistree. Lancez votre premiere reproduction !',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final Litter litter = state.litters[index];
                          final bool isSelected =
                              state.selectedIds.contains(litter.id);
                          return LitterCard(
                            litter: litter,
                            selected: isSelected,
                            onToggleSelected: (bool? _) =>
                                context.read<LittersCubit>().toggleSelection(litter.id),
                            onRecordWeights: () async {
                              final List<LitterKitWeightInput>? payload =
                                  await showKitWeightsSheet(context, litter);
                              if (payload != null && context.mounted) {
                                await context
                                    .read<LittersCubit>()
                                    .saveKitWeights(litterId: litter.id, payload: payload);
                              }
                            },
                            onAssignHousing: () async {
                              final LitterBatchUpdate? update =
                                  await showAssignHousingDialog(context, litter);
                              if (update != null && context.mounted) {
                                await context.read<LittersCubit>().applyBatch(update);
                              }
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: state.litters.length,
                      ),
              ),
            ),
            if (state.hasSelection)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () async {
                        final LittersCubit cubit = context.read<LittersCubit>();
                        final LittersState current = cubit.state;
                        final LitterBatchUpdate? update = await showBatchEditSheet(
                          context,
                          current.selectedIds.toList(),
                        );
                        if (update != null && context.mounted) {
                          await cubit.applyBatch(update);
                        }
                      },
                      icon: const Icon(Icons.tune),
                      label: const Text('Edition groupee'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.read<LittersCubit>().clearSelection(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Annuler selection'),
                    ),
                    TextButton.icon(
                      onPressed: () => context.read<LittersCubit>().selectAll(),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Tout selectionner'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LitterSelectionBar extends StatelessWidget {
  const _LitterSelectionBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        '$count portee${count > 1 ? 's' : ''} selectionnee${count > 1 ? 's' : ''}',
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class LitterCard extends StatelessWidget {
  const LitterCard({
    required this.litter,
    required this.selected,
    required this.onToggleSelected,
    required this.onRecordWeights,
    required this.onAssignHousing,
    super.key,
  });

  final Litter litter;
  final bool selected;
  final ValueChanged<bool?> onToggleSelected;
  final VoidCallback onRecordWeights;
  final VoidCallback onAssignHousing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      color: selected ? theme.colorScheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(value: selected, onChanged: onToggleSelected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        litter.code,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Femelle ${litter.doeTag} • Male ${litter.buckTag}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                LitterStatusChip(status: litter.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                InfoChip(
                  icon: Icons.cottage_outlined,
                  label: 'Cage ${litter.cage}',
                ),
                if (litter.enclosure != null && litter.enclosure!.isNotEmpty)
                  InfoChip(
                    icon: Icons.park_outlined,
                    label: litter.enclosure!,
                  ),
                InfoChip(
                  icon: Icons.cake_outlined,
                  label: 'Nes vivants ${litter.bornAlive}',
                ),
                InfoChip(
                  icon: Icons.child_care_outlined,
                  label: '${litter.totalKits} kits',
                ),
                if (litter.nextReminder != null)
                  InfoChip(
                    icon: Icons.notification_add_outlined,
                    label: 'Prochain rappel ${_formatDate(litter.nextReminder!)}',
                  ),
                if (litter.hasPendingSync)
                  const InfoChip(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Brouillon',
                  ),
              ],
            ),
            if (litter.notes != null && litter.notes!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                litter.notes!,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: onRecordWeights,
                        icon: const Icon(Icons.scale),
                        label: const Text('Enregistrer poids'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onAssignHousing,
                        icon: const Icon(Icons.drive_file_move_outline),
                        label: const Text('Assigner cage'),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onToggleSelected(!selected),
                  child: Text(selected ? 'Deselectionner' : 'Selectionner'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LitterStatusChip extends StatelessWidget {
  const LitterStatusChip({required this.status, super.key});

  final LitterStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.flag_outlined, size: 16),
      label: Text(status.label),
    );
  }
}

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}
