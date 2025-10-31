import 'package:flutter/material.dart';

import '../../../../data/models/litter.dart';

Future<LitterDraft?> showCreateLitterDialog(BuildContext context) {
  return showDialog<LitterDraft>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const _LitterFormDialog(),
  );
}

Future<LitterBatchUpdate?> showBatchEditSheet(
  BuildContext context,
  List<String> litterIds,
) {
  return showModalBottomSheet<LitterBatchUpdate>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _BatchEditSheet(litterIds: litterIds),
  );
}

Future<LitterBatchUpdate?> showAssignHousingDialog(
  BuildContext context,
  Litter litter,
) {
  return showDialog<LitterBatchUpdate>(
    context: context,
    builder: (BuildContext context) => _AssignHousingDialog(litter: litter),
  );
}

Future<List<LitterKitWeightInput>?> showKitWeightsSheet(
  BuildContext context,
  Litter litter,
) {
  return showModalBottomSheet<List<LitterKitWeightInput>>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _KitWeightsSheet(litter: litter),
  );
}

class _LitterFormDialog extends StatefulWidget {
  const _LitterFormDialog();

  @override
  State<_LitterFormDialog> createState() => _LitterFormDialogState();
}

class _LitterFormDialogState extends State<_LitterFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _doeController;
  late final TextEditingController _buckController;
  late final TextEditingController _bornAliveController;
  late final TextEditingController _bornDeadController;
  late final TextEditingController _expectedWeanedController;
  late final TextEditingController _cageController;
  late final TextEditingController _enclosureController;
  late final TextEditingController _tasksController;
  late final TextEditingController _notesController;
  DateTime _breedingDate = DateTime.now().subtract(const Duration(days: 31));
  DateTime _kindlingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _codeController = TextEditingController(
      text: 'P-${now.year}-${now.month.toString().padLeft(2, '0')}',
    );
    _doeController = TextEditingController();
    _buckController = TextEditingController();
    _bornAliveController = TextEditingController(text: '8');
    _bornDeadController = TextEditingController(text: '0');
    _expectedWeanedController = TextEditingController(text: '8');
    _cageController = TextEditingController();
    _enclosureController = TextEditingController();
    _tasksController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _doeController.dispose();
    _buckController.dispose();
    _bornAliveController.dispose();
    _bornDeadController.dispose();
    _expectedWeanedController.dispose();
    _cageController.dispose();
    _enclosureController.dispose();
    _tasksController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle portee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Numero de portee'),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty ? 'Champ obligatoire' : null,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _doeController,
                      decoration:
                          const InputDecoration(labelText: 'Femelle (tatouage)'),
                      validator: (String? value) =>
                          value == null || value.trim().isEmpty
                              ? 'Champ obligatoire'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _buckController,
                      decoration: const InputDecoration(labelText: 'Male (tatouage)'),
                      validator: (String? value) =>
                          value == null || value.trim().isEmpty
                              ? 'Champ obligatoire'
                              : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _DatePickerField(
                      label: 'Date saillie',
                      initialDate: _breedingDate,
                      onChanged: (DateTime value) => setState(() {
                        _breedingDate = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Date mise bas',
                      initialDate: _kindlingDate,
                      onChanged: (DateTime value) => setState(() {
                        _kindlingDate = value;
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _bornAliveController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nes vivants'),
                      validator: (String? value) =>
                          _validateInt(value, min: 0, requiredField: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bornDeadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nes morts'),
                      validator: (String? value) => _validateInt(value, min: 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _expectedWeanedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sevres prevus'),
                      validator: (String? value) =>
                          _validateInt(value, min: 0, requiredField: true),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cageController,
                decoration: const InputDecoration(labelText: 'Numero de cage'),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _enclosureController,
                decoration: const InputDecoration(labelText: 'Enclos (optionnel)'),
              ),
              TextFormField(
                controller: _tasksController,
                decoration: const InputDecoration(
                  labelText: 'Gabarit de taches',
                  helperText: 'Exemple : Cycle reproduction standard',
                ),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            if (_kindlingDate.isBefore(_breedingDate)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('La date de mise bas doit etre posterieure a la saillie.'),
                ),
              );
              return;
            }
            final int bornAlive = int.parse(_bornAliveController.text.trim());
            final int bornDead = int.parse(_bornDeadController.text.trim());
            final int expectedWeaned =
                int.parse(_expectedWeanedController.text.trim());
            if (expectedWeaned > bornAlive) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Les sevres prevus ne peuvent pas depasser les nes vivants.'),
                ),
              );
              return;
            }
            Navigator.of(context).pop(
              LitterDraft(
                code: _codeController.text.trim(),
                doeTag: _doeController.text.trim(),
                buckTag: _buckController.text.trim(),
                breedingDate: _breedingDate,
                kindlingDate: _kindlingDate,
                bornAlive: bornAlive,
                bornDead: bornDead,
                expectedWeaned: expectedWeaned,
                cage: _cageController.text.trim(),
                enclosure: _enclosureController.text.trim().isEmpty
                    ? null
                    : _enclosureController.text.trim(),
                taskTemplateName: _tasksController.text.trim().isEmpty
                    ? null
                    : _tasksController.text.trim(),
                notes:
                    _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  String? _validateInt(String? value, {int min = 0, bool requiredField = false}) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (requiredField) {
        return 'Champ obligatoire';
      }
      return null;
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < min) {
      return 'Valeur invalide';
    }
    return null;
  }
}

class _DatePickerField extends StatefulWidget {
  const _DatePickerField({
    required this.label,
    required this.initialDate,
    required this.onChanged,
  });

  final String label;
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void didUpdateWidget(covariant _DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedDate = widget.initialDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      controller: TextEditingController(text: _formatDate(_selectedDate)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2015),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
          widget.onChanged(picked);
        }
      },
    );
  }
}

class _BatchEditSheet extends StatefulWidget {
  const _BatchEditSheet({required this.litterIds});

  final List<String> litterIds;

  @override
  State<_BatchEditSheet> createState() => _BatchEditSheetState();
}

class _BatchEditSheetState extends State<_BatchEditSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LitterStatus? _status;
  final TextEditingController _cageController = TextEditingController();
  final TextEditingController _enclosureController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _reminderDate;

  @override
  void dispose() {
    _cageController.dispose();
    _enclosureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: padding.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Edition groupee (${widget.litterIds.length} portees)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LitterStatus>(
              decoration: const InputDecoration(labelText: 'Statut'),
              initialValue: _status,
              items: LitterStatus.values
                  .map(
                    (LitterStatus status) => DropdownMenuItem<LitterStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (LitterStatus? value) {
                setState(() {
                  _status = value;
                });
              },
            ),
            TextFormField(
              controller: _cageController,
              decoration: const InputDecoration(labelText: 'Cage'),
            ),
            TextFormField(
              controller: _enclosureController,
              decoration: const InputDecoration(labelText: 'Enclos'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final DateTime initial = _reminderDate ?? DateTime.now();
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _reminderDate = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.notification_add_outlined),
                    label: Text(
                      _reminderDate == null
                          ? 'Ajouter rappel'
                          : 'Rappel ${_formatDate(_reminderDate!)}',
                    ),
                  ),
                ),
                if (_reminderDate != null) ...<Widget>[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Supprimer rappel',
                    onPressed: () => setState(() => _reminderDate = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    Navigator.of(context).pop(
                      LitterBatchUpdate(
                        litterIds: widget.litterIds,
                        status: _status,
                        cage: _cageController.text.trim().isEmpty
                            ? null
                            : _cageController.text.trim(),
                        enclosure: _enclosureController.text.trim().isEmpty
                            ? null
                            : _enclosureController.text.trim(),
                        notes: _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                        nextReminder: _reminderDate,
                      ),
                    );
                  },
                  child: const Text('Appliquer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AssignHousingDialog extends StatefulWidget {
  const _AssignHousingDialog({required this.litter});

  final Litter litter;

  @override
  State<_AssignHousingDialog> createState() => _AssignHousingDialogState();
}

class _AssignHousingDialogState extends State<_AssignHousingDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _cageController;
  late final TextEditingController _enclosureController;

  @override
  void initState() {
    super.initState();
    _cageController = TextEditingController(text: widget.litter.cage);
    _enclosureController =
        TextEditingController(text: widget.litter.enclosure ?? '');
  }

  @override
  void dispose() {
    _cageController.dispose();
    _enclosureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assigner cage - ${widget.litter.code}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _cageController,
              decoration: const InputDecoration(labelText: 'Cage'),
              validator: (String? value) =>
                  value == null || value.trim().isEmpty ? 'Champ obligatoire' : null,
            ),
            TextFormField(
              controller: _enclosureController,
              decoration: const InputDecoration(labelText: 'Enclos (optionnel)'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              LitterBatchUpdate(
                litterIds: <String>[widget.litter.id],
                cage: _cageController.text.trim(),
                enclosure: _enclosureController.text.trim().isEmpty
                    ? null
                    : _enclosureController.text.trim(),
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _KitWeightsSheet extends StatefulWidget {
  const _KitWeightsSheet({required this.litter});

  final Litter litter;

  @override
  State<_KitWeightsSheet> createState() => _KitWeightsSheetState();
}

class _KitWeightsSheetState extends State<_KitWeightsSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _weaningControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _preSlaughterControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _carcassControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _marketValueControllers =
      <String, TextEditingController>{};
  final Map<String, String?> _destinationValues = <String, String?>{};

  @override
  void initState() {
    super.initState();
    for (final LitterKit kit in widget.litter.kits) {
      _weaningControllers[kit.id] = TextEditingController(
        text: kit.weaningWeightGrams != null
            ? kit.weaningWeightGrams!.toStringAsFixed(0)
            : '',
      );
      _preSlaughterControllers[kit.id] = TextEditingController(
        text: kit.preSlaughterWeightGrams != null
            ? kit.preSlaughterWeightGrams!.toStringAsFixed(0)
            : '',
      );
      _carcassControllers[kit.id] = TextEditingController(
        text: kit.carcassWeightKg != null
            ? kit.carcassWeightKg!.toStringAsFixed(2)
            : '',
      );
      _marketValueControllers[kit.id] = TextEditingController(
        text: kit.marketValue != null ? kit.marketValue!.toStringAsFixed(0) : '',
      );
      _destinationValues[kit.id] = kit.destination;
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _weaningControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller in _preSlaughterControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller in _carcassControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller
        in _marketValueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: insets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Enregistrer les poids - ${widget.litter.code}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.litter.kits
                      .map(
                        (LitterKit kit) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildKitSection(context, kit),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final List<LitterKitWeightInput> payload =
                        widget.litter.kits.map((LitterKit kit) {
                      return LitterKitWeightInput(
                        kitId: kit.id,
                        weaningWeightGrams:
                            _parseDouble(_weaningControllers[kit.id]!.text),
                        preSlaughterWeightGrams:
                            _parseDouble(_preSlaughterControllers[kit.id]!.text),
                        carcassWeightKg:
                            _parseDouble(_carcassControllers[kit.id]!.text),
                        marketValue:
                            _parseDouble(_marketValueControllers[kit.id]!.text),
                        destination: _destinationValues[kit.id],
                      );
                    }).toList(growable: false);
                    Navigator.of(context).pop(payload);
                  },
                  child: const Text('Enregistrer les poids'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKitSection(BuildContext context, LitterKit kit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${kit.tag} • ${kit.sex}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _weaningControllers[kit.id],
                decoration: const InputDecoration(labelText: 'Poids sevrage (g)'),
                keyboardType: TextInputType.number,
                validator: _validatePositive,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _preSlaughterControllers[kit.id],
                decoration:
                    const InputDecoration(labelText: 'Poids pre-abattage (g)'),
                keyboardType: TextInputType.number,
                validator: _validatePositive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _carcassControllers[kit.id],
                decoration: const InputDecoration(labelText: 'Poids carcasse (kg)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositive,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _marketValueControllers[kit.id],
                decoration: const InputDecoration(
                  labelText: 'Valeur marchande (FCFA)',
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Destination'),
          initialValue: _destinationValues[kit.id],
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: 'Abattu', child: Text('Abattu')),
            DropdownMenuItem<String>(value: 'Vendu', child: Text('Vendu')),
            DropdownMenuItem<String>(value: 'Garde', child: Text('Garde')),
            DropdownMenuItem<String>(value: 'Autre', child: Text('Autre')),
          ],
          onChanged: (String? value) {
            setState(() {
              _destinationValues[kit.id] = value;
            });
          },
        ),
      ],
    );
  }

  String? _validatePositive(String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final double? parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Valeur invalide';
    }
    return null;
  }

  double? _parseDouble(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }
}

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}
