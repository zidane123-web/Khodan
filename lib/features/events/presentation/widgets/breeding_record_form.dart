import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';

class BreedingRecordFormDialog extends StatefulWidget {
  const BreedingRecordFormDialog({
    required this.animals,
    this.initial,
    super.key,
  });

  final List<Animal> animals;
  final BreedingRecord? initial;

  static Future<BreedingRecord?> show(
    BuildContext context, {
    required List<Animal> animals,
    BreedingRecord? initial,
  }) {
    return showDialog<BreedingRecord>(
      context: context,
      builder: (BuildContext context) =>
          BreedingRecordFormDialog(animals: animals, initial: initial),
    );
  }

  @override
  State<BreedingRecordFormDialog> createState() =>
      _BreedingRecordFormDialogState();
}

class _BreedingRecordFormDialogState extends State<BreedingRecordFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _bornAliveController;
  late final TextEditingController _bornDeadController;
  late final TextEditingController _adoptedController;
  late final TextEditingController _removedController;
  late final TextEditingController _weanedController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  String? _selectedDoeId;
  String? _selectedBuckId;
  late DateTime _matingDate;
  DateTime? _palpationDate;
  String _palpationResult = 'unknown';
  DateTime? _kindlingDate;
  DateTime? _weaningDate;

  List<Animal> get _does => widget.animals
      .where((Animal animal) =>
          animal.sex.toLowerCase().contains('fem') ||
          animal.sex.toLowerCase().startsWith('f'))
      .toList();

  List<Animal> get _bucks => widget.animals
      .where((Animal animal) =>
          animal.sex.toLowerCase().contains('mâ') ||
          animal.sex.toLowerCase().contains('male'))
      .toList();

  @override
  void initState() {
    super.initState();
    final BreedingRecord? initial = widget.initial;
    _selectedDoeId = initial?.doeId;
    _selectedBuckId = initial?.buckId;
    _matingDate = initial?.matingDate ?? DateTime.now();
    _palpationDate = initial?.palpationDate;
    _palpationResult = initial?.palpationPositive == null
        ? 'unknown'
        : (initial!.palpationPositive! ? 'positive' : 'negative');
    _kindlingDate = initial?.kindlingDate;
    _weaningDate = initial?.weaningDate;

    _bornAliveController = TextEditingController(
      text: initial?.kitsBornAlive?.toString() ?? '',
    );
    _bornDeadController = TextEditingController(
      text: initial?.kitsBornDead?.toString() ?? '',
    );
    _adoptedController = TextEditingController(
      text: initial?.adoptedKitsIn?.toString() ?? '',
    );
    _removedController = TextEditingController(
      text: initial?.kitsRemoved?.toString() ?? '',
    );
    _weanedController = TextEditingController(
      text: initial?.kitsWeaned?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: initial?.averageWeaningWeight?.toString() ?? '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');
  }

  @override
  void dispose() {
    _bornAliveController.dispose();
    _bornDeadController.dispose();
    _adoptedController.dispose();
    _removedController.dispose();
    _weanedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime(initialDate.year + 2),
    );
    if (result != null) {
      onSelected(result);
      setState(() {});
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDoeId == null || _selectedBuckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une femelle et un mâle.')),
      );
      return;
    }

    final BreedingRecord base = widget.initial ??
        BreedingRecord(
          id: 'breeding-${DateTime.now().millisecondsSinceEpoch}',
          profileId: 'demo-profile',
          doeId: _selectedDoeId!,
          buckId: _selectedBuckId!,
          matingDate: _matingDate,
        );

    final bool? palpationPositive;
    switch (_palpationResult) {
      case 'positive':
        palpationPositive = true;
        break;
      case 'negative':
        palpationPositive = false;
        break;
      default:
        palpationPositive = null;
    }

    final BreedingRecord record = base.copyWith(
      doeId: _selectedDoeId!,
      buckId: _selectedBuckId!,
      matingDate: _matingDate,
      palpationDate: _palpationDate,
      palpationPositive: palpationPositive,
      kindlingDate: _kindlingDate,
      weaningDate: _weaningDate,
      kitsBornAlive: _parseInt(_bornAliveController.text),
      kitsBornDead: _parseInt(_bornDeadController.text),
      adoptedKitsIn: _parseInt(_adoptedController.text),
      kitsRemoved: _parseInt(_removedController.text),
      kitsWeaned: _parseInt(_weanedController.text),
      averageWeaningWeight: _parseDouble(_weightController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(record);
  }

  int? _parseInt(String value) {
    return value.trim().isEmpty ? null : int.tryParse(value.trim());
  }

  double? _parseDouble(String value) {
    return value.trim().isEmpty ? null : double.tryParse(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.initial == null
          ? 'Nouvelle saillie'
          : 'Modifier la saillie'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedDoeId,
                decoration: const InputDecoration(labelText: 'Femelle'),
                hint: const Text('Sélectionner'),
                validator: (String? value) =>
                    value == null ? 'Sélection obligatoire' : null,
                items: _does
                    .map(
                      (Animal animal) => DropdownMenuItem<String>(
                        value: animal.id,
                        child: Text(
                          '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) => setState(() => _selectedDoeId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBuckId,
                decoration: const InputDecoration(labelText: 'Mâle'),
                hint: const Text('Sélectionner'),
                validator: (String? value) =>
                    value == null ? 'Sélection obligatoire' : null,
                items: _bucks
                    .map(
                      (Animal animal) => DropdownMenuItem<String>(
                        value: animal.id,
                        child: Text(
                          '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) => setState(() => _selectedBuckId = value),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date de saillie'),
                subtitle: Text(localizations.formatMediumDate(_matingDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _pickDate(
                    initialDate: _matingDate,
                    onSelected: (DateTime value) => _matingDate = value,
                  ),
                ),
              ),
              const Divider(height: 32),
              Text('Palpation', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _palpationDate != null
                      ? localizations.formatMediumDate(_palpationDate!)
                      : 'Programmer une date',
                ),
                leading: const Icon(Icons.monitor_heart),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_palpationDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _palpationDate = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: () => _pickDate(
                        initialDate: _palpationDate ?? _matingDate,
                        onSelected: (DateTime value) => _palpationDate = value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _palpationResult,
                decoration: const InputDecoration(labelText: 'Résultat'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'unknown',
                    child: Text('À confirmer'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'positive',
                    child: Text('Gestante'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'negative',
                    child: Text('Non gestante'),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _palpationResult = value);
                  }
                },
              ),
              const Divider(height: 32),
              Text('Mise-bas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _kindlingDate != null
                      ? localizations.formatMediumDate(_kindlingDate!)
                      : 'Date prévue : ${localizations.formatMediumDate(_matingDate.add(const Duration(days: 31)))}',
                ),
                leading: const Icon(Icons.nest_cam_wired_stand),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_kindlingDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _kindlingDate = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: () => _pickDate(
                        initialDate: _kindlingDate ?? _matingDate,
                        onSelected: (DateTime value) => _kindlingDate = value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _bornAliveController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nés vivants',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bornDeadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nés morts',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _adoptedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lapereaux adoptés',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _removedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lapereaux retirés',
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text('Sevrage', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _weaningDate != null
                      ? localizations.formatMediumDate(_weaningDate!)
                      : 'Date prévue : ${localizations.formatMediumDate((_kindlingDate ?? _matingDate.add(const Duration(days: 31))).add(const Duration(days: 28)))}',
                ),
                leading: const Icon(Icons.child_care_outlined),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_weaningDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _weaningDate = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: () => _pickDate(
                        initialDate: _weaningDate ??
                            (_kindlingDate ??
                                _matingDate.add(const Duration(days: 31))),
                        onSelected: (DateTime value) => _weaningDate = value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _weanedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lapereaux sevrés',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Poids moyen (kg)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
