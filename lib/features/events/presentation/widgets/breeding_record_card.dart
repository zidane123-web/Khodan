import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';

class BreedingRecordCard extends StatelessWidget {
  const BreedingRecordCard({
    required this.record,
    required this.doe,
    required this.buck,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCreateKits,
    super.key,
  });

  final BreedingRecord record;
  final Animal? doe;
  final Animal? buck;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCreateKits;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String doeLabel = _formatAnimal(doe, fallbackId: record.doeId);
    final String buckLabel = _formatAnimal(buck, fallbackId: record.buckId);
    final String pairingLabel = '$doeLabel × $buckLabel';

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(pairingLabel, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Saillie du ${localizations.formatMediumDate(record.matingDate)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        if (onEdit != null)
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: record.tasks
                    .map(
                      (BreedingTask task) => Chip(
                        avatar: Icon(
                          _iconForTask(task.type),
                          size: 18,
                          color: task.isCompleted
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        label: Text(
                          '${_labelForTask(task.type)} · ${localizations.formatMediumDate(task.dueDate)}',
                        ),
                        backgroundColor: task.isCompleted
                            ? theme.colorScheme.secondaryContainer
                            : task.isOverdue
                                ? theme.colorScheme.errorContainer
                                : theme.colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                _statusLabel(localizations),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ..._buildSummaryLines(context),
              if (record.notes != null && record.notes!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text('Notes', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(record.notes!),
              ],
              if ((record.kitsBornAlive ?? 0) > 0) ...<Widget>[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.pets),
                    onPressed: onCreateKits ??
                        () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rendez-vous dans la liste des animaux pour ajouter la portée.',
                                ),
                              ),
                            ),
                    label: const Text('Créer les fiches des lapereaux'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(MaterialLocalizations localizations) {
    if (record.weaningDate != null) {
      return 'Sevrage réalisé le ${localizations.formatMediumDate(record.weaningDate!)}';
    }
    if (record.kindlingDate != null) {
      return 'Sevrage prévu le ${localizations.formatMediumDate(record.plannedWeaningDate)}';
    }
    if (record.palpationPositive == false) {
      return 'Gestation non confirmée';
    }
    if (record.palpationDate != null) {
      return 'Mise-bas prévue le ${localizations.formatMediumDate(record.plannedKindlingDate)}';
    }
    return 'Palpation prévue le ${localizations.formatMediumDate(record.plannedPalpationDate)}';
  }

  List<Widget> _buildSummaryLines(BuildContext context) {
    final List<Widget> lines = <Widget>[];
    if (record.kitsBornAlive != null || record.kitsBornDead != null) {
      lines.add(
        Text(
          'Mise-bas : ${record.kitsBornAlive ?? 0} nés vivants, ${record.kitsBornDead ?? 0} morts',
        ),
      );
    }
    if (record.adoptedKitsIn != null || record.kitsRemoved != null) {
      lines.add(
        Text(
          'Adoptions : +${record.adoptedKitsIn ?? 0} · Retraits : -${record.kitsRemoved ?? 0}',
        ),
      );
    }
    if (record.kitsWeaned != null) {
      final String weight = record.averageWeaningWeight != null
          ? ' (${record.averageWeaningWeight!.toStringAsFixed(2)} kg)' : '';
      lines.add(Text('Sevrés : ${record.kitsWeaned}$weight'));
    }
    return lines;
  }

  String _formatAnimal(Animal? animal, {required String fallbackId}) {
    if (animal == null) {
      return fallbackId;
    }
    if (animal.name != null && animal.name!.isNotEmpty) {
      return '${animal.tagId} · ${animal.name}';
    }
    return animal.tagId;
  }

  IconData _iconForTask(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return Icons.monitor_heart;
      case BreedingTaskType.kindling:
        return Icons.nest_cam_wired_stand;
      case BreedingTaskType.weaning:
        return Icons.child_care_outlined;
    }
  }

  String _labelForTask(BreedingTaskType type) {
    switch (type) {
      case BreedingTaskType.palpation:
        return 'Palpation';
      case BreedingTaskType.kindling:
        return 'Mise-bas';
      case BreedingTaskType.weaning:
        return 'Sevrage';
    }
  }
}