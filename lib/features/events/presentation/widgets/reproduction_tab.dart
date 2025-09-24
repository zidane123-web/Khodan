import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../presentation/cubit/breeding_cubit.dart';
import 'breeding_record_card.dart';
import 'breeding_reminders_section.dart';
import '../screens/breeding_record_screen.dart';

class ReproductionTabView extends StatelessWidget {
  const ReproductionTabView({super.key});

  Future<void> _editRecord(
    BuildContext context,
    BreedingRecord record,
  ) async {
    final BreedingCubit cubit = context.read<BreedingCubit>();
    final BreedingRecord? updated = await BreedingRecordScreen.show(
      context,
      animals: cubit.state.animals,
      initial: record,
    );
    if (updated != null && context.mounted) {
      await cubit.updateRecord(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saillie mise à jour.')),
        );
      }
    }
  }

  void _promptCreateKits(
    BuildContext context,
    BreedingRecord record,
  ) {
    final int kitsCount = record.kitsBornAlive ?? 0;
    if (kitsCount <= 0) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          kitsCount > 1
              ? 'Créez $kitsCount fiches lapereaux dans l’onglet Animaux.'
              : 'Créez la fiche du lapereau dans l’onglet Animaux.',
        ),
      ),
    );
  }

  Future<void> _deleteRecord(
    BuildContext context,
    BreedingRecord record,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer cette saillie ?'),
        content: const Text(
          'Cette action supprimera les rappels associés. Continuer ?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BreedingCubit>().deleteRecord(record.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saillie supprimée.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreedingCubit, BreedingState>(
      builder: (BuildContext context, BreedingState state) {
        if (state.status == BreedingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == BreedingStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.errorMessage ?? 'Impossible de charger les données.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final List<BreedingRecord> records = state.records;
        final Map<String, Animal> animalsById = state.animalsById;

        return RefreshIndicator(
          onRefresh: () => context.read<BreedingCubit>().loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              BreedingRemindersSection(
                reminders: state.reminders,
                animalsById: animalsById,
              ),
              const SizedBox(height: 16),
              Text(
                'Suivi des portées',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (records.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Enregistrez votre première saillie pour suivre les portées.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...records.map(
                  (BreedingRecord record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BreedingRecordCard(
                      record: record,
                      doe: animalsById[record.doeId],
                      buck: animalsById[record.buckId],
                      onEdit: () => _editRecord(context, record),
                      onDelete: () => _deleteRecord(context, record),
                      onCreateKits: () => _promptCreateKits(context, record),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
