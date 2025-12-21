import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../animals/domain/genealogy_analyzer.dart';

/// Dialog simplifié pour enregistrer une saillie rapidement
/// Optimisé pour utilisation terrain (gros boutons, workflow minimal)
class QuickBreedDialog extends StatefulWidget {
  const QuickBreedDialog({
    required this.does,
    required this.bucks,
    required this.analyzer,
    required this.profileId,
    this.preselectedDoe,
    this.onSave,
    super.key,
  });

  final List<Animal> does;
  final List<Animal> bucks;
  final GenealogyAnalyzer analyzer;
  final String profileId;
  final Animal? preselectedDoe;
  final Future<void> Function(BreedingRecord)? onSave;

  static Future<BreedingRecord?> show(
    BuildContext context, {
    required List<Animal> does,
    required List<Animal> bucks,
    required GenealogyAnalyzer analyzer,
    required String profileId,
    Animal? preselectedDoe,
    Future<void> Function(BreedingRecord)? onSave,
  }) {
    return showModalBottomSheet<BreedingRecord>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => QuickBreedDialog(
        does: does,
        bucks: bucks,
        analyzer: analyzer,
        profileId: profileId,
        preselectedDoe: preselectedDoe,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickBreedDialog> createState() => _QuickBreedDialogState();
}

class _QuickBreedDialogState extends State<QuickBreedDialog> {
  Animal? _selectedDoe;
  Animal? _selectedBuck;
  bool _isSaving = false;
  double? _pairingCoefficient;

  @override
  void initState() {
    super.initState();
    _selectedDoe = widget.preselectedDoe;
    // Auto-sélectionner le premier mâle disponible
    if (widget.bucks.isNotEmpty) {
      _selectedBuck = widget.bucks.first;
    }
    _refreshPairingCoefficient();
  }

  void _refreshPairingCoefficient() {
    if (_selectedDoe != null && _selectedBuck != null) {
      _pairingCoefficient = widget.analyzer.computePairCoefficient(
        _selectedDoe!.id,
        _selectedBuck!.id,
      );
    } else {
      _pairingCoefficient = null;
    }
  }

  Future<void> _submit() async {
    if (_selectedDoe == null || _selectedBuck == null) return;

    setState(() => _isSaving = true);

    final BreedingRecord record = BreedingRecord(
      id: const Uuid().v4(),
      profileId: widget.profileId,
      doeId: _selectedDoe!.id,
      buckId: _selectedBuck!.id,
      matingDate: DateTime.now(),
    );

    try {
      if (widget.onSave != null) {
        await widget.onSave!(record);
      }

      if (mounted) {
        Navigator.of(context).pop(record);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets bottomPadding = EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    );

    final bool highRisk = (_pairingCoefficient ?? 0) >= 0.0625;
    final bool canSubmit =
        _selectedDoe != null && _selectedBuck != null && !_isSaving;

    return Container(
      padding: bottomPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle de glissement
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Row(
                children: <Widget>[
                  Icon(Icons.favorite, color: theme.colorScheme.secondary),
                  const SizedBox(width: 12),
                  Text(
                    'Saillie Rapide',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sélection femelle
              _AnimalSelector(
                label: 'Femelle',
                icon: Icons.female,
                color: theme.colorScheme.secondary,
                animals: widget.does,
                selected: _selectedDoe,
                onSelected: (Animal? animal) {
                  setState(() {
                    _selectedDoe = animal;
                    _refreshPairingCoefficient();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Icône cœur central
              Icon(
                Icons.favorite,
                size: 32,
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              ),

              const SizedBox(height: 16),

              // Sélection mâle
              _AnimalSelector(
                label: 'Mâle',
                icon: Icons.male,
                color: theme.colorScheme.primary,
                animals: widget.bucks,
                selected: _selectedBuck,
                onSelected: (Animal? animal) {
                  setState(() {
                    _selectedBuck = animal;
                    _refreshPairingCoefficient();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Alerte coefficient de consanguinité
              if (_pairingCoefficient != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: highRisk
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        highRisk ? Icons.warning_amber : Icons.check_circle,
                        color: highRisk
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          highRisk
                              ? 'Consanguinité élevée : ${_pairingCoefficient!.toStringAsFixed(3)}'
                              : 'Coefficient OK : ${_pairingCoefficient!.toStringAsFixed(3)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: highRisk
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Date (aujourd'hui par défaut)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Aujourd'hui",
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton enregistrer (grand pour utilisation terrain)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: canSubmit ? _submit : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSaving ? 'Enregistrement...' : 'ENREGISTRER LA SAILLIE',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de sélection d'animal optimisé pour le terrain
class _AnimalSelector extends StatelessWidget {
  const _AnimalSelector({
    required this.label,
    required this.icon,
    required this.color,
    required this.animals,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<Animal> animals;
  final Animal? selected;
  final ValueChanged<Animal?> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected != null ? color : theme.dividerColor,
            width: selected != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selected != null ? color.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected != null
                        ? selected!.displayName
                        : 'Sélectionner',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          selected != null ? FontWeight.w600 : FontWeight.normal,
                      color: selected != null ? null : theme.colorScheme.outline,
                    ),
                  ),
                  if (selected != null && selected!.race != null)
                    Text(
                      selected!.race!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sélectionner un $label',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: animals.length,
                itemBuilder: (BuildContext context, int index) {
                  final Animal animal = animals[index];
                  final bool isSelected = animal.id == selected?.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? color : null,
                      child: Text(
                        animal.tagId.length > 2
                            ? animal.tagId.substring(0, 2)
                            : animal.tagId,
                      ),
                    ),
                    title: Text(animal.displayName),
                    subtitle: Text(
                      <String>[
                        animal.formattedAge,
                        if (animal.race != null) animal.race!,
                        if (animal.cageNumber != null)
                          'Cage ${animal.cageNumber}',
                      ].join(' · '),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: color)
                        : null,
                    onTap: () {
                      onSelected(animal);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
