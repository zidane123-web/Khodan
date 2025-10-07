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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _tagController;
  late final TextEditingController _nameController;
  late final TextEditingController _cageController;
  late final TextEditingController _originController;

  late String _selectedSex;
  late String _selectedStatus;
  DateTime? _birthDate;
  DateTime? _entryDate;
  DateTime? _firstBreedingDate;

  @override
  void initState() {
    super.initState();
    final Animal? initial = widget.initial;
    _tagController = TextEditingController(text: initial?.tagId ?? '');
    _nameController = TextEditingController(text: initial?.name ?? '');
    _cageController = TextEditingController(text: initial?.cageNumber ?? '');
    _originController = TextEditingController(text: initial?.origin ?? '');
    _selectedSex = initial?.sex ?? 'Femelle';
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

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ obligatoire';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_birthDate == null || _entryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez renseigner les dates clés.')),
      );
      return;
    }

    final Animal initial = widget.initial ??
        Animal(
          id: 'animal-${DateTime.now().millisecondsSinceEpoch}',
          profileId: 'demo-profile',
          speciesId: 1,
          tagId: '',
          birthDate: DateTime.now(),
          sex: _selectedSex,
          status: _selectedStatus,
        );

    final Animal animal = initial.copyWith(
      tagId: _tagController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      sex: _selectedSex,
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
    );

    Navigator.of(context).pop(animal);
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String? firstBreedingAge = (_firstBreedingDate != null &&
            _birthDate != null)
        ? '${_firstBreedingDate!.difference(_birthDate!).inDays} jours'
        : null;

    return AlertDialog(
      title: Text(widget.initial == null
          ? 'Nouvelle fiche animal'
          : 'Modifier la fiche'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                  hintText: 'Numéro de l’animal',
                ),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSex,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'Femelle', child: Text('Femelle')),
                  DropdownMenuItem<String>(value: 'Mâle', child: Text('Mâle')),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selectedSex = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
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
                label: 'Date de naissance',
                value: _birthDate,
                onTap: () => _pickDate(
                  initialDate: _birthDate,
                  onSelected: (DateTime value) => _birthDate = value,
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
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Date de première saillie',
                value: _firstBreedingDate,
                onTap: () => _pickDate(
                  initialDate: _firstBreedingDate ?? _birthDate,
                  onSelected: (DateTime value) => _firstBreedingDate = value,
                ),
                helper: 'Permet de calculer l’âge à la première saillie.',
                required: false,
              ),
              if (firstBreedingAge != null) ...<Widget>[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Âge à la première saillie : $firstBreedingAge',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Animal entré le ${_entryDate != null ? localizations.formatMediumDate(_entryDate!) : '—'}',
                  style: theme.textTheme.bodySmall,
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
