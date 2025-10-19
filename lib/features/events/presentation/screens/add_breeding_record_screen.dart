import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';

import '../../../../data/models/breeding_record.dart';

import '../../../animals/domain/genealogy_analyzer.dart';

import '../cubit/breeding_cubit.dart';

import 'package:uuid/uuid.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';

import '../cubit/events_cubit.dart';

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

  final Uuid _uuid = const Uuid();

  late List<Animal> _animals;

  bool _isSaving = false;

  String? _selectedDoeId;

  String? _selectedBuckId;

  late DateTime _matingDate;

  DateTime? _palpationDate;

  String _palpationResult = 'unknown';

  DateTime? _kindlingDate;

  DateTime? _weaningDate;

  double? _pairingCoefficient;

  List<Animal> get _does => _animals
      .where(
        (Animal animal) =>
            animal.sex.toLowerCase().contains('fem') ||
            animal.sex.toLowerCase().startsWith('f'),
      )
      .toList();

  List<Animal> get _bucks => _animals.where((Animal animal) {
    final String sex = animal.sex.toLowerCase();
    return sex.contains('m') && !sex.contains('fem');
  }).toList();

  String _resolveProfileId() {
    final AuthState auth = context.read<AuthCubit>().state;
    return auth.profile?.id ?? auth.session?.user.id ?? 'demo-profile';
  }

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

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateBeforeSubmit() {
    final Animal? doe = _findAnimalById(_selectedDoeId);
    if (doe == null) {
      _showError('Femelle introuvable.');
      return false;
    }
    final Animal? buck = _findAnimalById(_selectedBuckId);
    if (buck == null) {
      _showError('Male introuvable.');
      return false;
    }
    if (_palpationDate != null && _palpationDate!.isBefore(_matingDate)) {
      _showError('La date de palpation doit etre posterieure a la saillie.');
      return false;
    }
    if (_kindlingDate != null && _kindlingDate!.isBefore(_matingDate)) {
      _showError('La mise bas ne peut pas preceder la saillie.');
      return false;
    }
    if (_weaningDate != null) {
      final DateTime reference = _kindlingDate ?? _matingDate;
      if (_weaningDate!.isBefore(reference)) {
        _showError('La date de sevrage doit suivre la mise bas.');
        return false;
      }
    }
    final Map<String, int?> counts = <String, int?>{
      'Nombre de nes vivants': _parseInt(_bornAliveController.text),
      'Nombre de nes morts': _parseInt(_bornDeadController.text),
      'Adoptions': _parseInt(_adoptedController.text),
      'Retraits': _parseInt(_removedController.text),
      'Sevres': _parseInt(_weanedController.text),
    };
    for (final MapEntry<String, int?> entry in counts.entries) {
      final int? value = entry.value;
      if (value != null && value < 0) {
        _showError(' doit etre positif.');
        return false;
      }
    }
    final double? avgWeight = _parseDouble(_weightController.text);
    if (avgWeight != null && avgWeight < 0) {
      _showError('Le poids moyen doit etre positif.');
      return false;
    }
    return true;
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

  bool _validateAllSteps() {
    bool isValid = true;

    for (final GlobalKey<FormState> key in _stepKeys) {
      final FormState? form = key.currentState;
      if (form != null && !form.validate()) {
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _submit() async {
    if (!_validateAllSteps()) {
      return;
    }

    if (_selectedDoeId == null || _selectedBuckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectionnez une femelle et un male.')),
      );

      return;
    }
    if (!_validateBeforeSubmit()) {
      return;
    }

    setState(() => _isSaving = true);

    final DateTime matingUtc = _matingDate.toUtc();
    final DateTime? palpationUtc = _palpationDate?.toUtc();
    final DateTime? kindlingUtc = _kindlingDate?.toUtc();
    final DateTime? weaningUtc = _weaningDate?.toUtc();

    final BreedingRecord base =
        widget.initialRecord ??
        BreedingRecord(
          id: _uuid.v4(),

          profileId: _resolveProfileId(),

          doeId: _selectedDoeId!,

          buckId: _selectedBuckId!,

          matingDate: matingUtc,
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

      matingDate: matingUtc,

      palpationDate: palpationUtc,

      palpationPositive: palpationPositive,

      kindlingDate: kindlingUtc,

      weaningDate: weaningUtc,

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
      try {
        context.read<EventsCubit>().refresh();
      } catch (_) {
        // EventsCubit not available in this scope.
      }
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

  List<Step> _buildSteps(
    ThemeData theme,
    MaterialLocalizations localizations, {
    required bool isWideLayout,
  }) {
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
    final Widget? pairingSummary = _buildPairingSummaryCard(theme, highRisk);

    return <Step>[
      Step(
        title: const Text('Saillie'),
        isActive: true,
        state: StepState.indexed,
        content: Form(
          key: _stepKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (pairingSummary != null) pairingSummary,
              _FormSectionCard(
                title: 'Reproducteurs',
                subtitle:
                    'Sélectionnez la femelle et le mâle pour démarrer la saillie.',
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
                    validator: (_) => _selectedBuckId == null
                        ? 'Sélection obligatoire'
                        : null,
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
                ],
              ),
              const SizedBox(height: 16),
              _FormSectionCard(
                title: 'Détails de la saillie',
                children: <Widget>[
                  _buildDateTile(
                    theme: theme,
                    icon: Icons.calendar_today_outlined,
                    title: 'Date de saillie',
                    subtitle: localizations.formatMediumDate(_matingDate),
                    onPick: () => _pickDate(
                      initialDate: _matingDate,
                      onSelected: (DateTime value) => _matingDate = value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Palpation'),
        isActive: true,
        state: StepState.indexed,
        content: Form(
          key: _stepKeys[1],
          child: _FormSectionCard(
            title: 'Suivi de la palpation',
            subtitle:
                'Planifiez la date de palpation et enregistrez le résultat.',
            children: <Widget>[
              _buildDateTile(
                theme: theme,
                icon: Icons.monitor_heart,
                title: 'Date de palpation',
                subtitle: _palpationDate != null
                    ? localizations.formatMediumDate(_palpationDate!)
                    : 'Programmer une date',
                isPlaceholder: _palpationDate == null,
                onClear: _palpationDate != null
                    ? () => setState(() => _palpationDate = null)
                    : null,
                onPick: () => _pickDate(
                  initialDate: _palpationDate ?? _matingDate,
                  onSelected: (DateTime value) => _palpationDate = value,
                ),
              ),
              DropdownMenu<String>(
                initialSelection: _palpationResult,
                label: const Text('Résultat'),
                dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                  DropdownMenuEntry<String>(
                    value: 'unknown',
                    label: 'À confirmer',
                  ),
                  DropdownMenuEntry<String>(
                    value: 'positive',
                    label: 'Gestante',
                  ),
                  DropdownMenuEntry<String>(
                    value: 'negative',
                    label: 'Non gestante',
                  ),
                ],
                onSelected: (String? value) {
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
        isActive: true,
        state: StepState.indexed,
        content: Form(
          key: _stepKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _FormSectionCard(
                title: 'Mise bas',
                subtitle: 'Enregistrez les informations sur la portée.',
                children: <Widget>[
                  _buildDateTile(
                    theme: theme,
                    icon: Icons.nest_cam_wired_stand,
                    title: 'Date de mise bas',
                    subtitle: _kindlingDate != null
                        ? localizations.formatMediumDate(_kindlingDate!)
                        : 'Date prévue : $plannedKindling',
                    isPlaceholder: _kindlingDate == null,
                    onClear: _kindlingDate != null
                        ? () => setState(() => _kindlingDate = null)
                        : null,
                    onPick: () => _pickDate(
                      initialDate: _kindlingDate ?? _matingDate,
                      onSelected: (DateTime value) => _kindlingDate = value,
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: <Widget>[
                      _buildNumberField(
                        controller: _bornAliveController,
                        label: 'Nés vivants',
                        compact: isWideLayout,
                      ),
                      _buildNumberField(
                        controller: _bornDeadController,
                        label: 'Nés morts',
                        compact: isWideLayout,
                      ),
                      _buildNumberField(
                        controller: _adoptedController,
                        label: 'Lapereaux adoptés',
                        compact: isWideLayout,
                      ),
                      _buildNumberField(
                        controller: _removedController,
                        label: 'Lapereaux retirés',
                        compact: isWideLayout,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FormSectionCard(
                title: 'Sevrage',
                subtitle: 'Complétez les informations après la mise bas.',
                children: <Widget>[
                  _buildDateTile(
                    theme: theme,
                    icon: Icons.child_care_outlined,
                    title: 'Date de sevrage',
                    subtitle: _weaningDate != null
                        ? localizations.formatMediumDate(_weaningDate!)
                        : 'Date prévue : $plannedWeaning',
                    isPlaceholder: _weaningDate == null,
                    onClear: _weaningDate != null
                        ? () => setState(() => _weaningDate = null)
                        : null,
                    onPick: () => _pickDate(
                      initialDate:
                          _weaningDate ??
                          (_kindlingDate ??
                              _matingDate.add(const Duration(days: 31))),
                      onSelected: (DateTime value) => _weaningDate = value,
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: <Widget>[
                      _buildNumberField(
                        controller: _weanedController,
                        label: 'Lapereaux sevrés',
                        compact: isWideLayout,
                      ),
                      _buildNumberField(
                        controller: _weightController,
                        label: 'Poids moyen (kg)',
                        compact: isWideLayout,
                        decimal: true,
                      ),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
    ];
  }

  Widget? _buildPairingSummaryCard(ThemeData theme, bool highRisk) {
    final Animal? doe = _findAnimalById(_selectedDoeId);
    final Animal? buck = _findAnimalById(_selectedBuckId);

    if (doe == null && buck == null && _pairingCoefficient == null) {
      return null;
    }

    final Color badgeColor = highRisk
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final Color badgeOnColor = highRisk
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Résumé du croisement', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (doe != null)
              _SummaryEntry(
                label: 'Femelle',
                value: _buildAnimalDisplayName(doe),
                helper: _buildAnimalHelperText(doe),
              ),
            if (buck != null)
              _SummaryEntry(
                label: 'Mâle',
                value: _buildAnimalDisplayName(buck),
                helper: _buildAnimalHelperText(buck),
              ),
            if (_pairingCoefficient != null) ...<Widget>[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        highRisk ? Icons.warning_amber : Icons.favorite_outline,
                        color: badgeOnColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          highRisk
                              ? 'Coefficient de consanguinité élevé (${_pairingCoefficient!.toStringAsFixed(3)}). Évitez ce croisement ou surveillez la portée.'
                              : 'Coefficient de consanguinité estimé : ${_pairingCoefficient!.toStringAsFixed(3)}.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: badgeOnColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPlaceholder = false,
    VoidCallback? onClear,
    required VoidCallback onPick,
  }) {
    final TextStyle? subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isPlaceholder ? theme.colorScheme.onSurfaceVariant : null,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: subtitleStyle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (onClear != null)
            IconButton(
              tooltip: 'Effacer',
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
          IconButton(
            tooltip: 'Choisir une date',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: onPick,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required bool compact,
    bool decimal = false,
  }) {
    final TextFormField field = TextFormField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );

    if (!compact) {
      return field;
    }

    return SizedBox(width: 220, child: field);
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
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool isWideLayout = constraints.maxWidth >= 640;

                          final List<Step> sections = _buildSteps(
                            theme,
                            localizations,
                            isWideLayout: isWideLayout,
                          );

                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                32,
                              ),
                              children: <Widget>[
                                for (final Step section
                                    in sections) ...<Widget>[
                                  if (section.title is Text)
                                    Text(
                                      (section.title as Text).data ?? '',
                                      style: theme.textTheme.titleLarge,
                                    )
                                  else
                                    section.title,
                                  const SizedBox(height: 12),
                                  section.content,
                                  const SizedBox(height: 24),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: _isSaving
                                          ? null
                                          : () => Navigator.of(
                                              context,
                                            ).maybePop(),
                                      child: const Text('Fermer'),
                                    ),
                                    const SizedBox(width: 12),
                                    FilledButton(
                                      onPressed: _isSaving ? null : _submit,
                                      child: const Text('Enregistrer'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> spacedChildren = <Widget>[];

    for (int index = 0; index < children.length; index += 1) {
      spacedChildren.add(children[index]);
      if (index != children.length - 1) {
        spacedChildren.add(const SizedBox(height: 12));
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (spacedChildren.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              ...spacedChildren,
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryEntry extends StatelessWidget {
  const _SummaryEntry({required this.label, required this.value, this.helper});

  final String label;
  final String value;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: theme.textTheme.titleSmall),
                if (helper != null)
                  Text(
                    helper!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
