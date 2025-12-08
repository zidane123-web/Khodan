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

  final TextEditingController _selectedDoeController = TextEditingController();

  final TextEditingController _selectedBuckController = TextEditingController();

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
            animal.sex.toLowerCase().contains('mâ') ||
            animal.sex.toLowerCase().contains('mal'),
      )
      .toList();

  Animal? _findAnimalById(String? id) {
    if (id == null) {
      return null;
    }

    for (final Animal animal in _animals) {
      if (animal.id == id) {
        return animal;
      }
    }

    return null;
  }

  void _syncSelectedAnimalControllers() {
    final Animal? doe = _findAnimalById(_selectedDoeId);

    final Animal? buck = _findAnimalById(_selectedBuckId);

    _selectedDoeController.text = doe == null
        ? ''
        : _buildAnimalDisplayName(doe);

    _selectedBuckController.text = buck == null
        ? ''
        : _buildAnimalDisplayName(buck);
  }

  String _buildAnimalDisplayName(Animal animal) {
    if (animal.name == null || animal.name!.trim().isEmpty) {
      return animal.tagId;
    }

    return '${animal.tagId} · ${animal.name}';
  }

  String _buildAnimalHelperText(Animal animal) {
    final String age = _formatAnimalAge(animal);

    return 'Âge : $age · Statut : ${animal.status}';
  }

  String _formatAnimalAge(Animal animal) {
    final Duration difference = DateTime.now().difference(animal.birthDate);

    final int days = difference.inDays;

    if (days < 30) {
      return days <= 1 ? '$days jour' : '$days jours';
    }

    final int months = days ~/ 30;

    if (months < 12) {
      return months <= 1 ? '1 mois' : '$months mois';
    }

    final int years = months ~/ 12;

    final int remainingMonths = months % 12;

    if (remainingMonths == 0) {
      return years <= 1 ? '1 an' : '$years ans';
    }

    final String yearsPart = years <= 1 ? '1 an' : '$years ans';

    final String monthsPart = remainingMonths <= 1
        ? '1 mois'
        : '$remainingMonths mois';

    return '$yearsPart $monthsPart';
  }

  Future<String?> _openDoePicker() {
    if (_does.isEmpty) {
      return Future<String?>.value(null);
    }

    return _showAnimalPicker(
      title: 'Sélectionner la femelle',

      animals: _does,

      selectedId: _selectedDoeId,

      searchHint: 'Rechercher par bague, nom ou statut',

      emptyLabel: 'Aucune femelle disponible.',

      subtitleBuilder: _buildAnimalHelperText,
    );
  }

  Future<String?> _openBuckPicker() {
    if (_bucks.isEmpty) {
      return Future<String?>.value(null);
    }

    return _showAnimalPicker(
      title: 'Sélectionner le mâle',

      animals: _bucks,

      selectedId: _selectedBuckId,

      searchHint: 'Rechercher par bague, nom ou statut',

      emptyLabel: 'Aucun mâle disponible.',

      subtitleBuilder: _buildAnimalHelperText,

      trailingBuilder: (BuildContext context, Animal animal) {
        if (_selectedDoeId == null) {
          return null;
        }

        final double coefficient = _analyzer.computePairCoefficient(
          _selectedDoeId,
          animal.id,
        );

        return _buildCoefficientChip(context, coefficient);
      },
    );
  }

  Future<String?> _showAnimalPicker({
    required String title,

    required List<Animal> animals,

    required String? selectedId,

    required String searchHint,

    required String emptyLabel,

    String? Function(Animal)? subtitleBuilder,

    Widget? Function(BuildContext, Animal)? trailingBuilder,
  }) {
    return showModalBottomSheet<String>(
      context: context,

      isScrollControlled: true,

      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,

          child: Material(
            color: Theme.of(context).colorScheme.surface,

            child: _AnimalPickerContent(
              title: title,

              animals: animals,

              initialSelectedId: selectedId,

              searchHint: searchHint,

              emptyLabel: emptyLabel,

              subtitleBuilder: subtitleBuilder,

              trailingBuilder: trailingBuilder,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoefficientChip(BuildContext context, double coefficient) {
    final bool highRisk = coefficient >= 0.0625;

    final ThemeData theme = Theme.of(context);

    final ColorScheme colors = theme.colorScheme;

    final Color background = highRisk
        ? colors.errorContainer
        : colors.secondaryContainer;

    final Color foreground = highRisk
        ? colors.onErrorContainer
        : colors.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: background,

        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        coefficient.toStringAsFixed(3),

        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,

          fontWeight: highRisk ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
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

    _syncSelectedAnimalControllers();
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

    _selectedDoeController.dispose();

    _selectedBuckController.dispose();

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
        const SnackBar(content: Text('Sélectionnez une femelle et un mâle.')),
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

    final Animal? selectedDoe = _findAnimalById(_selectedDoeId);

    final Animal? selectedBuck = _findAnimalById(_selectedBuckId);

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
              TextFormField(
                controller: _selectedDoeController,

                readOnly: true,

                showCursor: false,

                decoration: InputDecoration(
                  labelText: 'Femelle',

                  hintText: 'Sélectionner',

                  helperText: selectedDoe != null
                      ? _buildAnimalHelperText(selectedDoe)
                      : 'Choisissez la reproductrice',

                  suffixIcon: const Icon(Icons.expand_more),
                ),

                validator: (_) =>
                    _selectedDoeId == null ? 'Sélection obligatoire' : null,

                onTap: () async {
                  final String? newDoeId = await _openDoePicker();

                  if (!mounted) {
                    return;
                  }

                  if (newDoeId != null && newDoeId != _selectedDoeId) {
                    setState(() {
                      _selectedDoeId = newDoeId;

                      _syncSelectedAnimalControllers();

                      _refreshPairingCoefficient();
                    });

                    _stepKeys[0].currentState?.validate();
                  }
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _selectedBuckController,

                readOnly: true,

                showCursor: false,

                decoration: InputDecoration(
                  labelText: 'Mâle',

                  hintText: 'Sélectionner',

                  helperText: _selectedDoeId == null
                      ? "Sélectionnez d'abord une femelle"
                      : selectedBuck != null
                      ? _buildAnimalHelperText(selectedBuck)
                      : 'Choisissez un mâle compatible',

                  suffixIcon: const Icon(Icons.expand_more),
                ),

                validator: (_) =>
                    _selectedBuckId == null ? 'Sélection obligatoire' : null,

                onTap: () async {
                  if (_selectedDoeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Sélectionnez d'abord une femelle pour calculer la compatibilité.",
                        ),
                      ),
                    );

                    return;
                  }

                  final String? newBuckId = await _openBuckPicker();

                  if (!mounted) {
                    return;
                  }

                  if (newBuckId != null && newBuckId != _selectedBuckId) {
                    setState(() {
                      _selectedBuckId = newBuckId;

                      _syncSelectedAnimalControllers();

                      _refreshPairingCoefficient();
                    });

                    _stepKeys[0].currentState?.validate();
                  }
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

          _syncSelectedAnimalControllers();
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

              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
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

class _AnimalPickerContent extends StatefulWidget {
  const _AnimalPickerContent({
    required this.title,

    required this.animals,

    required this.initialSelectedId,

    required this.searchHint,

    required this.emptyLabel,

    this.subtitleBuilder,

    this.trailingBuilder,
  });

  final String title;

  final List<Animal> animals;

  final String? initialSelectedId;

  final String searchHint;

  final String emptyLabel;

  final String? Function(Animal)? subtitleBuilder;

  final Widget? Function(BuildContext, Animal)? trailingBuilder;

  @override
  State<_AnimalPickerContent> createState() => _AnimalPickerContentState();
}

class _AnimalPickerContentState extends State<_AnimalPickerContent> {
  late final TextEditingController _searchController;

  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<Animal> get _filteredAnimals {
    if (_query.isEmpty) {
      return widget.animals;
    }

    final String normalized = _query.toLowerCase();

    return widget.animals.where((Animal animal) {
      final String haystack =
          '${animal.tagId} ${animal.name ?? ''} ${animal.status}'.toLowerCase();

      return haystack.contains(normalized);
    }).toList();
  }

  void _handleSelect(Animal animal) {
    Navigator.of(context).pop(animal.id);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final List<Animal> animals = _filteredAnimals;

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),

            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.titleLarge),
                ),

                IconButton(
                  icon: const Icon(Icons.close),

                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: TextField(
              controller: _searchController,

              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),

                hintText: widget.searchHint,
              ),

              onChanged: (String value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: animals.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),

                      child: Text(
                        widget.emptyLabel,

                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: animals.length,

                    separatorBuilder: (_, __) => const Divider(height: 0),

                    itemBuilder: (BuildContext context, int index) {
                      final Animal animal = animals[index];

                      final bool isSelected =
                          animal.id == widget.initialSelectedId;

                      final Widget? trailing = widget.trailingBuilder?.call(
                        context,
                        animal,
                      );

                      final String title =
                          animal.name == null || animal.name!.trim().isEmpty
                          ? animal.tagId
                          : '${animal.tagId} · ${animal.name}';

                      final String? subtitle = widget.subtitleBuilder?.call(
                        animal,
                      );

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,

                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),

                        title: Text(title),

                        subtitle: subtitle != null ? Text(subtitle) : null,

                        trailing: trailing,

                        onTap: () => _handleSelect(animal),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
