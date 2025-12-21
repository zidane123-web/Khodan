import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key, this.initial});

  final Animal? initial;

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cageController = TextEditingController();
  final TextEditingController _originController = TextEditingController();

  late AnimalSex _selectedSex;
  late String _selectedStatus;
  DateTime? _birthDate;
  DateTime? _entryDate;
  DateTime? _firstBreedingDate;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Parent selection (dropdown lists)
  List<Animal> _allAnimals = <Animal>[];
  List<Animal> _males = <Animal>[];
  List<Animal> _females = <Animal>[];
  String? _selectedSireId;
  String? _selectedDamId;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Animal? initial = widget.initial;
    _tagController.text = initial?.tagId ?? '';
    _nameController.text = initial?.name ?? '';
    _cageController.text = initial?.cageNumber ?? '';
    _originController.text = initial?.origin ?? '';
    _selectedSex = initial?.sexEnum ?? AnimalSex.female;
    _selectedStatus = initial?.status ?? 'Vivant';
    _birthDate = initial?.birthDate ?? DateTime.now();
    _entryDate = initial?.entryDate ?? DateTime.now();
    _firstBreedingDate = initial?.firstBreedingDate;
    _selectedSireId = initial?.sireId;
    _selectedDamId = initial?.damId;
    
    _loadAnimals();
  }
  
  Future<void> _loadAnimals() async {
    try {
      final List<Animal> animals = await SupabaseAnimalRepository().fetchAnimals();
      if (!mounted) return;
      
      setState(() {
        _allAnimals = animals;
        _males = animals
            .where((Animal a) => a.isMale)
            .toList();
        _females = animals
            .where((Animal a) => a.isFemale)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez indiquer la date de naissance.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter d\'abord.')),
        );
        setState(() => _isSaving = false);
        return;
      }
      
      final Animal template = widget.initial ??
          Animal(
            id: const Uuid().v4(),
            profileId: userId,
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
        sireId: _selectedSireId,
        damId: _selectedDamId,
      );

      final AnimalRepository repository = SupabaseAnimalRepository();
      if (_isEditing) {
        await repository.updateAnimal(result);
      } else {
        await repository.createAnimal(result);
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Fiche mise à jour !' : 'Lapin ajouté avec succès !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Modifier la fiche' : 'Nouveau lapin'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la fiche' : 'Nouveau lapin'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: <Widget>[
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Enregistrer',
              onPressed: _submit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            // Section: Identité
            Text(
              'Identité',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Identifiant *',
                hintText: 'Numéro de l\'animal',
                prefixIcon: Icon(Icons.tag),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Optionnel',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AnimalSex>(
              value: _selectedSex,
              decoration: const InputDecoration(
                labelText: 'Sexe *',
                prefixIcon: Icon(Icons.wc),
              ),
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
              label: 'Date de naissance *',
              value: _birthDate,
              onTap: () => _pickDate(
                initialDate: _birthDate,
                onSelected: (DateTime value) => _birthDate = value,
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Emplacement
            Text(
              'Emplacement',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cageController,
              decoration: const InputDecoration(
                labelText: 'Numéro de cage',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut',
                prefixIcon: Icon(Icons.info_outline),
              ),
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
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Origine
            Text(
              'Origine',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origine',
                hintText: 'Fournisseur, élevage, etc.',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            _buildDateField(
              label: 'Date d\'entrée à l\'élevage',
              value: _entryDate,
              onTap: () => _pickDate(
                initialDate: _entryDate,
                onSelected: (DateTime value) => _entryDate = value,
              ),
              helper: 'Permet de suivre la durée de présence.',
              required: false,
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Généalogie
            Text(
              'Généalogie',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez les parents parmi vos animaux existants',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedSireId,
              decoration: const InputDecoration(
                labelText: 'Père',
                hintText: 'Sélectionner (optionnel)',
                prefixIcon: Icon(Icons.male),
              ),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Aucun / Inconnu'),
                ),
                ..._males.map(
                  (Animal animal) => DropdownMenuItem<String?>(
                    value: animal.id,
                    child: Text(
                      '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                    ),
                  ),
                ),
              ],
              onChanged: (String? value) {
                setState(() => _selectedSireId = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedDamId,
              decoration: const InputDecoration(
                labelText: 'Mère',
                hintText: 'Sélectionner (optionnel)',
                prefixIcon: Icon(Icons.female),
              ),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Aucune / Inconnue'),
                ),
                ..._females.map(
                  (Animal animal) => DropdownMenuItem<String?>(
                    value: animal.id,
                    child: Text(
                      '${animal.tagId}${animal.name != null ? ' · ${animal.name}' : ''}',
                    ),
                  ),
                ),
              ],
              onChanged: (String? value) {
                setState(() => _selectedDamId = value);
              },
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
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Mettre à jour' : 'Enregistrer'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
