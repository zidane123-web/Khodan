import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/hutch.dart';
import '../../../../data/models/litter.dart';
import '../cubit/hutches_cubit.dart';
import '../cubit/litters_cubit.dart';
import 'empty_state.dart';
import 'hutch_dialogs.dart';
import 'info_chip.dart';
import 'litter_dialogs.dart';
import 'offline_banner.dart';

class HutchesTab extends StatelessWidget {
  const HutchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Litter> litters = context.watch<LittersCubit>().state.litters;
    return BlocBuilder<HutchesCubit, HutchesState>(
      builder: (BuildContext context, HutchesState state) {
        if (state.status == HutchesStatus.loading && state.hutches.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == HutchesStatus.failure && state.hutches.isEmpty) {
          return EmptyState(
            message: state.errorMessage ?? 'Erreur lors du chargement des clapiers.',
            onRetry: () => context.read<HutchesCubit>().load(),
          );
        }

        return Column(
          children: <Widget>[
            if (state.hasPendingSync)
              const OfflineBanner(
                message: 'Clapiers en attente de synchronisation.',
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<HutchesCubit>().load(),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int crossAxisCount =
                        constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                    if (state.hutches.isEmpty) {
                      return ListView(
                        children: const <Widget>[
                          EmptyState(
                            message:
                                'Aucun clapier configure. Ajoutez votre premier enclos.',
                          ),
                        ],
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.hutches.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Hutch hutch = state.hutches[index];
                        final List<Litter> occupantLitters = hutch.occupants
                            .map(
                              (HutchOccupant occupant) => litters.firstWhere(
                                (Litter litter) => litter.id == occupant.litterId,
                                orElse: () => Litter(
                                  id: occupant.litterId,
                                  code: occupant.litterCode,
                                  doeTag: '',
                                  buckTag: '',
                                  breedingDate: DateTime.now(),
                                  kindlingDate: DateTime.now(),
                                  bornAlive: 0,
                                  bornDead: 0,
                                  expectedWeaned: 0,
                                  cage: hutch.label,
                                ),
                              ),
                            )
                            .toList(growable: false);
                        return HutchCard(
                          hutch: hutch,
                          occupantLitters: occupantLitters,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HutchCard extends StatelessWidget {
  const HutchCard({
    required this.hutch,
    required this.occupantLitters,
    super.key,
  });

  final Hutch hutch;
  final List<Litter> occupantLitters;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int totalKits = occupantLitters.fold(
      0,
      (int acc, Litter litter) => acc + litter.totalKits,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  hutch.label,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Chip(label: Text(hutch.status.label)),
                const Spacer(),
                IconButton(
                  tooltip: 'Entretien',
                  onPressed: () => showMaintenanceSheet(context, hutch),
                  icon: const Icon(Icons.clean_hands_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                InfoChip(
                  icon: Icons.people_outline,
                  label: 'Occupants $totalKits / ${hutch.capacity}',
                ),
                InfoChip(
                  icon: Icons.history_toggle_off,
                  label: 'Dernier nettoyage ${_formatDate(hutch.lastCleaning)}',
                ),
                if (hutch.zone != null && hutch.zone!.isNotEmpty)
                  InfoChip(
                    icon: Icons.place_outlined,
                    label: hutch.zone!,
                  ),
                if (hutch.hasPendingSync)
                  const InfoChip(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Brouillon',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (occupantLitters.isEmpty)
              const Text('Aucune portee assignee.'),
            if (occupantLitters.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: occupantLitters.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final Litter litter = occupantLitters[index];
                    return _OccupantRow(litter: litter, hutch: hutch);
                  },
                ),
              ),
            if (hutch.notes != null && hutch.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  hutch.notes!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OccupantRow extends StatelessWidget {
  const _OccupantRow({required this.litter, required this.hutch});

  final Litter litter;
  final Hutch hutch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                litter.code,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${litter.totalKits} kits • Femelle ${litter.doeTag.isEmpty ? 'n/a' : litter.doeTag}',
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Poids',
          onPressed: () async {
            final List<LitterKitWeightInput>? payload =
                await showKitWeightsSheet(context, litter);
            if (payload != null && context.mounted) {
              await context
                  .read<HutchesCubit>()
                  .saveKitWeights(litterId: litter.id, payload: payload);
            }
          },
          icon: const Icon(Icons.scale_outlined),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}
