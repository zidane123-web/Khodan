import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../animals/domain/genealogy_analyzer.dart';

class BreedingRecordFormDialog extends StatefulWidget {
  const BreedingRecordFormDialog({
    required this.animals,
    this.initial,
    this.initialDoeId,
    this.initialBuckId,
    super.key,
  });

  final List<Animal> animals;
  final BreedingRecord? initial;
  final String? initialDoeId;
  final String? initialBuckId;

  static Future<BreedingRecord?> show(
    BuildContext context, {
    required List<Animal> animals,
    BreedingRecord? initial,
    String? initialDoeId,
    String? initialBuckId,
  }) {
    return showDialog<BreedingRecord>(
      context: context,
      builder: (BuildContext context) => BreedingRecordFormDialog(
        animals: animals,
        initial: initial,
        initialDoeId: initialDoeId,
        initialBuckId: initialBuckId,
      ),
    );
  }

  @override
  State<BreedingRecordFormDialog> createState() =>
      _BreedingRecordFormDialogState();
}

class _BreedingRecordFormDialogState extends State<BreedingRecordFormDialog> {
  late final List<GlobalKey<FormState>> _stepKeys;
  late final GenealogyAnalyzer _analyzer;
  final TextEditingController _bornAliveController = TextEditingController();
  final TextEditingController _bornDeadController = TextEditingController();
  final TextEditingController _adoptedController = TextEditingController();
  final TextEditingController _removedController = TextEditingController();
  final TextEditingController _weanedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedDoeId;
  String? _selectedBuckId;
  late DateTime _matingDate;
  DateTime? _palpationDate;
  String _palpationResult = 'unknown';
  DateTime? _kindlingDate;
  DateTime? _weaningDate;
  int _currentStep = 0;
  double? _pairingCoefficient;

  List<Animal> get _does => widget.animals
      .where((Animal animal) =>
          animal.sex.toLowerCase().contains('fem') ||
          animal.sex.toLowerCase().startsWith('f'))
      .toList();

  List<Animal> get _bucks => widget.animals
      .where((Animal animal) =>
          animal.sex.toLowerCase().contains('mâ') ||
          animal.sex.toLowerCase().contains('mal'))
      .toList();

  List<DropdownMenuItem<String>> _buildBuckItems(ThemeData theme) {
    final TextStyle baseStyle =
        theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    return _bucks.map((Animal animal) {
      final double? coefficient = _selectedDoeId == null
          ? null
          : _analyzer.computePairCoefficient(_selectedDoeId, animal.id);
      final bool risky = coefficient != null && coefficient >= 0.0625;
      final Color indicatorColor = risky
          ? theme.colorScheme.error
          : theme.colorScheme.onSurfaceVariant;
      return DropdownMenuItem<String>(
        value: animal.id,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (coefficient != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  coefficient.toStringAsFixed(3),
                  style: baseStyle.copyWith(
                    color: indicatorColor,
                    fontWeight: risky ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _stepKeys = List<GlobalKey<FormState>>.generate(
      3,
      (_) => GlobalKey<FormState>(),
    );
    final BreedingRecord? initial = widget.initial;
    _selectedDoeId = initial?.doeId ?? widget.initialDoeId;
    _selectedBuckId = initial?.buckId ?? widget.initialBuckId;
    _matingDate = initial?.matingDate ?? DateTime.now();
    _palpationDate = initial?.palpationDate;
    _palpationResult = initial?.palpationPositive == null
        ? 'unknown'
        : (initial!.palpationPositive! ? 'positive' : 'negative');
    _kindlingDate = initial?.kindlingDate;
    _weaningDate = initial?.weaningDate;

    _bornAliveController.text =
        initial?.kitsBornAlive?.toString() ?? '';
    _bornDeadController.text =
        initial?.kitsBornDead?.toString() ?? '';
    _adoptedController.text =
        initial?.adoptedKitsIn?.toString() ?? '';
    _removedController.text =
        initial?.kitsRemoved?.toString() ?? '';
    _weanedController.text =
        initial?.kitsWeaned?.toString() ?? '';
    _weightController.text =
        initial?.averageWeaningWeight?.toString() ?? '';
    _notesController.text = initial?.notes ?? '';

    final Map<String, Animal> animalsById = <String, Animal>{
      for (final Animal animal in widget.animals) animal.id: animal,
    };
    _analyzer = GenealogyAnalyzer(animalsById);
    _pairingCoefficient = (_selectedDoeId != null && _selectedBuckId != null)
        ? _analyzer.computePairCoefficient(_selectedDoeId, _selectedBuckId)
        : null;
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

  void _refreshPairingCoefficient() {
    _pairingCoefficient = (_selectedDoeId != null && _selectedBuckId != null)
        ? _analyzer.computePairCoefficient(
            _selectedDoeId,
            _selectedBuckId,
          )
        : null;
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

  bool _validateStep(int index) {
    if (index == 0) {
      final FormState? form = _stepKeys[0].currentState;
      return form == null || form.validate();
    }
    if (index == 1) {
      final FormState? form = _stepKeys[1].currentState;
      return form == null || form.validate();
    }
    final FormState? form = _stepKeys[2].currentState;
    return form == null || form.validate();
  }

  void _handleContinue() {
    if (!_validateStep(_currentStep)) {
      return;
    }
    if (_currentStep == 2) {
      _submit();
    } else {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _handleCancel() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _submit() {
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

  List<Step> _buildSteps(
    ThemeData theme,
    MaterialLocalizations localizations,
  ) {
    final bool highRisk = (_pairingCoefficient ?? 0) >= 0.0625;
    final String plannedKindling =
        localizations.formatMediumDate(_matingDate.add(const Duration(days: 31)));
    final String plannedWeaning = localizations.formatMediumDate(
      (_kindlingDate ?? _matingDate.add(const Duration(days: 31)))
          .add(const Duration(days: 28)),
    );

    return <Step>[
      Step(
        title: const Text('Saillie'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _stepKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: _selectedDoeId,
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
                onChanged: (String? value) {
                  setState(() {
                    _selectedDoeId = value;
                    _refreshPairingCoefficient();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBuckId,
                decoration: InputDecoration(
                  labelText: 'Mâle',
                  helperText: _selectedDoeId == null
                      ? 'Sélectionnez d’abord une femelle'
                      : 'Coefficient affiché à droite',
                ),
                hint: const Text('Sélectionner'),
                validator: (String? value) =>
                    value == null ? 'Sélection obligatoire' : null,
                items: _buildBuckItems(theme),
                onChanged: (String? value) {
                  setState(() {
                    _selectedBuckId = value;
                    _refreshPairingCoefficient();
                  });
                },
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
              if (_pairingCoefficient != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: highRisk
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            highRisk
                                ? Icons.warning_amber
                                : Icons.volunteer_activism,
                            color: highRisk
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              highRisk
                                  ? 'Coefficient de consanguinité élevé (${_pairingCoefficient!.toStringAsFixed(3)}). Évitez ce croisement ou surveillez la portée.'
                                  : 'Coefficient de consanguinité estimé : ${_pairingCoefficient!.toStringAsFixed(3)}.',
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
                  ),
                ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Palpation'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _stepKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                initialValue: _palpationResult,
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
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Mise bas & sevrage'),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.indexed,
        content: Form(
          key: _stepKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _kindlingDate != null
                      ? localizations.formatMediumDate(_kindlingDate!)
                      : 'Date prévue : $plannedKindling',
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
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _weaningDate != null
                      ? localizations.formatMediumDate(_weaningDate!)
                      : 'Date prévue : $plannedWeaning',
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
    ];
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
      content: SizedBox(
        width: 520,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            final bool isLast = _currentStep == 2;
            return Row(
              children: <Widget>[
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'Enregistrer' : 'Continuer'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Fermer' : 'Retour'),
                ),
              ],
            );
          },
          onStepContinue: _handleContinue,
          onStepCancel: _handleCancel,
          steps: _buildSteps(theme, localizations),
        ),
      ),
    );
  }
}
