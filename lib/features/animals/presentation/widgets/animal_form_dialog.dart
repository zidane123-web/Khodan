import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';

class AnimalFormDialog extends StatefulWidget {
  const AnimalFormDialog({super.key, this.initial});

  final Animal? initial;

  static Future<Animal?> show(
    BuildContext context, {
    Animal? initial,
  }) {
    return showDialog<Animal>(
      context: context,
      builder: (BuildContext context) => AnimalFormDialog(initial: initial),
    );
  }

  @override
  State<AnimalFormDialog> createState() => _AnimalFormDialogState();
}

class _AnimalFormDialogState extends State<AnimalFormDialog> {
  late final List<GlobalKey<FormState>> _stepKeys;
  late final TextEditingController _tagController;
  late final TextEditingController _nameController;
  late final TextEditingController _cageController;
  late final TextEditingController _originController;
  late final TextEditingController _sireController;
  late final TextEditingController _damController;

  int _currentStep = 0;
  late AnimalSex _selectedSex;
  late String _selectedStatus;
  DateTime? _birthDate;
  DateTime? _entryDate;
  DateTime? _firstBreedingDate;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _stepKeys = List<GlobalKey<FormState>>.generate(
      2,
      (_) => GlobalKey<FormState>(),
    );
    final Animal? initial = widget.initial;
    _tagController = TextEditingController(text: initial?.tagId ?? '');
    _nameController = TextEditingController(text: initial?.name ?? '');
    _cageController = TextEditingController(text: initial?.cageNumber ?? '');
    _originController = TextEditingController(text: initial?.origin ?? '');
    _sireController = TextEditingController(text: initial?.sireId ?? '');
    _damController = TextEditingController(text: initial?.damId ?? '');
    _selectedSex = initial?.sexEnum ?? AnimalSex.female;
    _selectedStatus = initial?.status ?? 'Vivant';
    _birthDate = initial?.birthDate ?? DateTime.now();
    _entryDate = initial?.entryDate ?? DateTime.now();
    _firstBreedingDate = initial?.firstBreedingDate;
  }

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _cageController.dispose();
    _originController.dispose();
    _sireController.dispose();
    _damController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 10);
    final DateTime lastDate = DateTime(now.year + 1);
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null) {
      onSelected(result);
      setState(() {});
    }
  }

  bool _validateStep(int index) {
    final FormState? form = _stepKeys[index].currentState;
    return form == null || form.validate();
  }

  void _handleContinue() {
    if (!_validateStep(_currentStep)) {
      return;
    }
    if (_currentStep == _stepKeys.length - 1) {
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

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ obligatoire';
    }
    return null;
  }

  void _submit() {
    if (!_validateStep(_currentStep)) {
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez indiquer la date de naissance.')),
      );
      return;
    }

    final Animal template = widget.initial ??
        Animal(
          id: 'animal-${DateTime.now().millisecondsSinceEpoch}',
          profileId: 'demo-profile',
          speciesId: 1,
          tagId: '',
          birthDate: _birthDate!,
          sexEnum: _selectedSex,
          status: _selectedStatus,
        );

    final Animal result = template.copyWith(
      tagId: _tagController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      sexEnum: _selectedSex,
      status: _selectedStatus,
      birthDate: _birthDate,
      cageNumber: _cageController.text.trim().isEmpty
          ? null
          : _cageController.text.trim(),
      origin: _originController.text.trim().isEmpty
          ? null
          : _originController.text.trim(),
      entryDate: _entryDate,
      firstBreedingDate: _firstBreedingDate,
      sireId: _sireController.text.trim().isEmpty
          ? null
          : _sireController.text.trim(),
      damId: _damController.text.trim().isEmpty
          ? null
          : _damController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    String? helper,
    bool required = true,
  }) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String? displayValue =
        value != null ? localizations.formatMediumDate(value) : null;
    return TextFormField(
      readOnly: true,
      key: ValueKey<String>('date-$label-${displayValue ?? ''}'),
      initialValue: displayValue,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: onTap,
      validator: (String? _) =>
          !required || displayValue != null ? null : 'Champ obligatoire',
    );
  }

  List<Step> _buildSteps(
    ThemeData theme,
    MaterialLocalizations localizations,
  ) {
    final String? firstBreedingAge = (_firstBreedingDate != null &&
            _birthDate != null)
        ? '${_firstBreedingDate!.difference(_birthDate!).inDays} jours'
        : null;

    return <Step>[
      Step(
        title: const Text('Base'),
        subtitle: const Text('Identité et naissance'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _stepKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Commencez par les informations essentielles afin de créer la fiche.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                  hintText: 'Numéro de l’animal',
                ),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AnimalSex>(
                value: _selectedSex,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: AnimalSex.values.map((AnimalSex sex) {
                  return DropdownMenuItem<AnimalSex>(
                    value: sex,
                    child: Text(sex.label),
                  );
                }).toList(),
                onChanged: (AnimalSex? value) {
                  if (value != null) {
                    setState(() => _selectedSex = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Date de naissance',
                value: _birthDate,
                onTap: () => _pickDate(
                  initialDate: _birthDate,
                  onSelected: (DateTime value) => _birthDate = value,
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Profil complet'),
        subtitle: const Text('Informations facultatives'),
        isActive: _currentStep >= 1,
        state: _currentStep == 1 ? StepState.editing : StepState.indexed,
        content: Form(
          key: _stepKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Affinez la fiche avec les détails utiles pour le suivi quotidien.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Optionnel',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'Vivant', child: Text('Vivant')),
                  DropdownMenuItem<String>(value: 'Vendu', child: Text('Vendu')),
                  DropdownMenuItem<String>(value: 'Mort', child: Text('Mort')),
                  DropdownMenuItem<String>(value: 'Réformé', child: Text('Réformé')),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cageController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de cage',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origine',
                  hintText: 'Fournisseur, élevage, etc.',
                ),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Date d’entrée à l’élevage',
                value: _entryDate,
                onTap: () => _pickDate(
                  initialDate: _entryDate,
                  onSelected: (DateTime value) => _entryDate = value,
                ),
                helper: 'Permet de suivre la durée de présence.',
                required: false,
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Date de première saillie',
                value: _firstBreedingDate,
                onTap: () => _pickDate(
                  initialDate: _firstBreedingDate ?? _birthDate,
                  onSelected: (DateTime value) => _firstBreedingDate = value,
                ),
                helper: 'Optionnel mais utile pour évaluer la précocité.',
                required: false,
              ),
              if (firstBreedingAge != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Âge à la première saillie : $firstBreedingAge',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _sireController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant du père',
                  hintText: 'Optionnel',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _damController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant de la mère',
                  hintText: 'Optionnel',
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
      title: Text(_isEditing ? 'Modifier la fiche' : 'Nouvelle fiche animal'),
      content: SizedBox(
        width: 520,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          onStepContinue: _handleContinue,
          onStepCancel: _handleCancel,
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            final bool isLast = _currentStep == _stepKeys.length - 1;
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
          steps: _buildSteps(theme, localizations),
        ),
      ),
    );
  }
}
