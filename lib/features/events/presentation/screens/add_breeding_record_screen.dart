import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../animals/domain/genealogy_analyzer.dart';
import '../cubit/breeding_cubit.dart';

class AddBreedingRecordScreen extends StatefulWidget {
  const AddBreedingRecordScreen({
    this.initialRecord,
    this.initialDoeId,
    this.initialBuckId,
    super.key,
  });

  final BreedingRecord? initialRecord;
  final String? initialDoeId;
  final String? initialBuckId;

  @override
  State<AddBreedingRecordScreen> createState() =>
      _AddBreedingRecordScreenState();
}

class _AddBreedingRecordScreenState extends State<AddBreedingRecordScreen> {
  late final List<GlobalKey<FormState>> _stepKeys;
  late GenealogyAnalyzer _analyzer;
  final TextEditingController _bornAliveController = TextEditingController();
  final TextEditingController _bornDeadController = TextEditingController();
  final TextEditingController _adoptedController = TextEditingController();
  final TextEditingController _removedController = TextEditingController();
  final TextEditingController _weanedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late List<Animal> _animals;
  bool _isSaving = false;

  String? _selectedDoeId;
  String? _selectedBuckId;
  late DateTime _matingDate;
  DateTime? _palpationDate;
  String _palpationResult = 'unknown';
  DateTime? _kindlingDate;
  DateTime? _weaningDate;
  int _currentStep = 0;
  double? _pairingCoefficient;

  List<Animal> get _does => _animals
      .where(
        (Animal animal) =>
            animal.sex.toLowerCase().contains('fem') ||
            animal.sex.toLowerCase().startsWith('f'),
      )
      .toList();

  List<Animal> get _bucks => _animals
      .where(
        (Animal animal) =>
            animal.sex.toLowerCase().contains('mÃƒÂ¢') ||
            animal.sex.toLowerCase().contains('mal'),
      )
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
                '${animal.tagId}${animal.name != null ? ' Ã‚Â· ${animal.name}' : ''}',
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
    final BreedingState breedingState = context.read<BreedingCubit>().state;
    _animals = List<Animal>.from(breedingState.animals);
    final BreedingRecord? initial = widget.initialRecord;
    _selectedDoeId = initial?.doeId ?? widget.initialDoeId;
    _selectedBuckId = initial?.buckId ?? widget.initialBuckId;
    _matingDate = initial?.matingDate ?? DateTime.now();
    _palpationDate = initial?.palpationDate;
    _palpationResult = initial?.palpationPositive == null
        ? 'unknown'
        : (initial!.palpationPositive! ? 'positive' : 'negative');
    _kindlingDate = initial?.kindlingDate;
    _weaningDate = initial?.weaningDate;

    _bornAliveController.text = initial?.kitsBornAlive?.toString() ?? '';
    _bornDeadController.text = initial?.kitsBornDead?.toString() ?? '';
    _adoptedController.text = initial?.adoptedKitsIn?.toString() ?? '';
    _removedController.text = initial?.kitsRemoved?.toString() ?? '';
    _weanedController.text = initial?.kitsWeaned?.toString() ?? '';
    _weightController.text = initial?.averageWeaningWeight?.toString() ?? '';
    final Map<String, Animal> animalsById = breedingState.animalsById;
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
        ? _analyzer.computePairCoefficient(_selectedDoeId, _selectedBuckId)
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

  Future<void> _handleContinue() async {
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

  Future<void> _submit() async {
    if (_selectedDoeId == null || _selectedBuckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SÃ©lectionnez une femelle et un mÃ¢le.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final BreedingRecord base =
        widget.initialRecord ??
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

    final bool success = await _persistRecord(record);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _persistRecord(BreedingRecord record) async {
    final BreedingCubit cubit = context.read<BreedingCubit>();
    if (widget.initialRecord != null) {
      await cubit.updateRecord(record);
    } else {
      await cubit.addRecord(record);
    }

    final BreedingState state = cubit.state;
    if (state.status == BreedingStatus.failure) {
      final String message =
          state.errorMessage ?? 'Impossible d\'enregistrer la saillie.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    }
    return true;
  }

  int? _parseInt(String value) {
    return value.trim().isEmpty ? null : int.tryParse(value.trim());
  }

  double? _parseDouble(String value) {
    return value.trim().isEmpty ? null : double.tryParse(value.trim());
  }

  List<Step> _buildSteps(ThemeData theme, MaterialLocalizations localizations) {
    final bool highRisk = (_pairingCoefficient ?? 0) >= 0.0625;
    final String plannedKindling = localizations.formatMediumDate(
      _matingDate.add(const Duration(days: 31)),
    );
    final String plannedWeaning = localizations.formatMediumDate(
      (_kindlingDate ?? _matingDate.add(const Duration(days: 31))).add(
        const Duration(days: 28),
      ),
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
                value: _selectedDoeId,
                decoration: const InputDecoration(labelText: 'Femelle'),
                hint: const Text('SÃƒÂ©lectionner'),
                validator: (String? value) =>
                    value == null ? 'SÃƒÂ©lection obligatoire' : null,
                items: _does
                    .map(
                      (Animal animal) => DropdownMenuItem<String>(
                        value: animal.id,
                        child: Text(
                          '${animal.tagId}${animal.name != null ? ' Ã‚Â· ${animal.name}' : ''}',
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
                value: _selectedBuckId,
                decoration: InputDecoration(
                  labelText: 'MÃƒÂ¢le',
                  helperText: _selectedDoeId == null
                      ? 'SÃƒÂ©lectionnez dÃ¢â‚¬â„¢abord une femelle'
                      : 'Coefficient affichÃƒÂ© ÃƒÂ  droite',
                ),
                hint: const Text('SÃƒÂ©lectionner'),
                validator: (String? value) =>
                    value == null ? 'SÃƒÂ©lection obligatoire' : null,
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
                                  ? 'Coefficient de consanguinitÃƒÂ© ÃƒÂ©levÃƒÂ© (${_pairingCoefficient!.toStringAsFixed(3)}). Ãƒâ€°vitez ce croisement ou surveillez la portÃƒÂ©e.'
                                  : 'Coefficient de consanguinitÃƒÂ© estimÃƒÂ© : ${_pairingCoefficient!.toStringAsFixed(3)}.',
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
                value: _palpationResult,
                decoration: const InputDecoration(labelText: 'RÃƒÂ©sultat'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'unknown',
                    child: Text('Ãƒâ‚¬ confirmer'),
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
                      : 'Date prÃƒÂ©vue : $plannedKindling',
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
                        labelText: 'NÃƒÂ©s vivants',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bornDeadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NÃƒÂ©s morts',
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
                        labelText: 'Lapereaux adoptÃƒÂ©s',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _removedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lapereaux retirÃƒÂ©s',
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
                      : 'Date prÃƒÂ©vue : $plannedWeaning',
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
                        initialDate:
                            _weaningDate ??
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
                        labelText: 'Lapereaux sevrÃƒÂ©s',
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
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final BreedingState state = context.watch<BreedingCubit>().state;
    final bool isInitialLoading =
        state.status == BreedingStatus.loading && _animals.isEmpty;
    final bool hasBlockingError =
        state.status == BreedingStatus.failure && _animals.isEmpty;

    return BlocListener<BreedingCubit, BreedingState>(
      listenWhen: (BreedingState previous, BreedingState current) =>
          previous.animals != current.animals,
      listener: (BuildContext context, BreedingState newState) {
        setState(() {
          _animals = List<Animal>.from(newState.animals);
          _analyzer = GenealogyAnalyzer(newState.animalsById);
          _refreshPairingCoefficient();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initialRecord == null
                ? 'Nouvelle saillie'
                : 'Modifier la saillie',
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              if (isInitialLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasBlockingError)
                _BreedingErrorMessage(
                  message:
                      state.errorMessage ??
                      'Impossible de charger les animaux.',
                  onRetry: () => context.read<BreedingCubit>().loadData(),
                )
              else if (_animals.isEmpty)
                const _BreedingErrorMessage(
                  message:
                      "Ajoutez d'abord des animaux pour enregistrer une saillie.",
                )
              else
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Stepper(
                      currentStep: _currentStep,
                      type: StepperType.vertical,
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                            final bool isLast = _currentStep == 2;
                            return Row(
                              children: <Widget>[
                                FilledButton(
                                  onPressed: _isSaving
                                      ? null
                                      : details.onStepContinue,
                                  child: Text(
                                    isLast ? 'Enregistrer' : 'Continuer',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: _isSaving
                                      ? null
                                      : details.onStepCancel,
                                  child: Text(
                                    _currentStep == 0 ? 'Fermer' : 'Retour',
                                  ),
                                ),
                              ],
                            );
                          },
                      onStepContinue: () async => _handleContinue(),
                      onStepCancel: _handleCancel,
                      steps: _buildSteps(theme, localizations),
                    ),
                  ),
                ),
              if (_isSaving) const _SavingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreedingErrorMessage extends StatelessWidget {
  const _BreedingErrorMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('RÃ©essayer')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavingOverlay extends StatelessWidget {
  const _SavingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Enregistrement en cours...'),
          ],
        ),
      ),
    );
  }
}
