import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../animals/domain/genealogy_analyzer.dart';

class BreedingFormScreen extends StatefulWidget {
  const BreedingFormScreen({super.key, this.initial});

  final BreedingRecord? initial;

  @override
  State<BreedingFormScreen> createState() => _BreedingFormScreenState();
}

class _BreedingFormScreenState extends State<BreedingFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bornAliveController = TextEditingController();
  final TextEditingController _bornDeadController = TextEditingController();
  final TextEditingController _weanedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Animal> _animals = <Animal>[];
  List<Animal> _does = <Animal>[];
  List<Animal> _bucks = <Animal>[];
  
  String? _selectedDoeId;
  String? _selectedBuckId;
  late DateTime _matingDate;
  DateTime? _palpationDate;
  String _palpationResult = 'unknown';
  DateTime? _kindlingDate;
  DateTime? _weaningDate;
  bool _isLoading = true;
  bool _isSaving = false;
  GenealogyAnalyzer? _analyzer;
  double? _pairingCoefficient;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _matingDate = widget.initial?.matingDate ?? DateTime.now();
    _palpationDate = widget.initial?.palpationDate;
    _palpationResult = widget.initial?.palpationPositive == null
        ? 'unknown'
        : (widget.initial!.palpationPositive! ? 'positive' : 'negative');
    _kindlingDate = widget.initial?.kindlingDate;
    _weaningDate = widget.initial?.weaningDate;
    _selectedDoeId = widget.initial?.doeId;
    _selectedBuckId = widget.initial?.buckId;
    
    _bornAliveController.text = widget.initial?.kitsBornAlive?.toString() ?? '';
    _bornDeadController.text = widget.initial?.kitsBornDead?.toString() ?? '';
    _weanedController.text = widget.initial?.kitsWeaned?.toString() ?? '';
    _notesController.text = widget.initial?.notes ?? '';
    
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      final List<Animal> animals = await SupabaseAnimalRepository().fetchAnimals();
      if (!mounted) return;
      
      final Map<String, Animal> animalsById = <String, Animal>{
        for (final Animal animal in animals) animal.id: animal,
      };
      
      setState(() {
        _animals = animals;
        _does = animals
            .where((Animal a) =>
                a.sex.toLowerCase().contains('fem') ||
                a.sex.toLowerCase().startsWith('f'))
            .toList();
        _bucks = animals
            .where((Animal a) =>
                a.sex.toLowerCase().contains('mâ') ||
                a.sex.toLowerCase().contains('mal'))
            .toList();
        _analyzer = GenealogyAnalyzer(animalsById);
        _isLoading = false;
        _refreshPairingCoefficient();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _refreshPairingCoefficient() {
    if (_analyzer != null && _selectedDoeId != null && _selectedBuckId != null) {
      _pairingCoefficient = _analyzer!.computePairCoefficient(
        _selectedDoeId,
        _selectedBuckId,
      );
    } else {
      _pairingCoefficient = null;
    }
  }

  @override
  void dispose() {
    _bornAliveController.dispose();
    _bornDeadController.dispose();
    _weanedController.dispose();
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

  int? _parseInt(String value) {
    return value.trim().isEmpty ? null : int.tryParse(value.trim());
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedDoeId == null || _selectedBuckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une femelle et un mâle.')),
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
      
      final BreedingRecord base = widget.initial ??
          BreedingRecord(
            id: const Uuid().v4(),
            profileId: userId,
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
        kitsWeaned: _parseInt(_weanedController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final BreedingRepository repository = SupabaseBreedingRepository();
      if (_isEditing) {
        await repository.updateBreedingRecord(record);
      } else {
        await repository.createBreedingRecord(record);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Saillie mise à jour !' : 'Saillie enregistrée !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop(record);
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle saillie'),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_does.isEmpty || _bucks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle saillie'),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Impossible de créer une saillie',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _does.isEmpty && _bucks.isEmpty
                      ? 'Ajoutez au moins un mâle et une femelle.'
                      : _does.isEmpty
                          ? 'Ajoutez au moins une femelle.'
                          : 'Ajoutez au moins un mâle.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool highRisk = (_pairingCoefficient ?? 0) >= 0.0625;
    final String plannedKindling =
        localizations.formatMediumDate(_matingDate.add(const Duration(days: 31)));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la saillie' : 'Nouvelle saillie'),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
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
            // Section: Animaux
            Text(
              'Animaux',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDoeId,
              decoration: const InputDecoration(
                labelText: 'Femelle *',
                prefixIcon: Icon(Icons.female),
              ),
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
              value: _selectedBuckId,
              decoration: const InputDecoration(
                labelText: 'Mâle *',
                prefixIcon: Icon(Icons.male),
              ),
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
              onChanged: (String? value) {
                setState(() {
                  _selectedBuckId = value;
                  _refreshPairingCoefficient();
                });
              },
            ),
            
            if (_pairingCoefficient != null) ...<Widget>[
              const SizedBox(height: 12),
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
                      highRisk ? Icons.warning_amber : Icons.volunteer_activism,
                      color: highRisk
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        highRisk
                            ? 'Consanguinité élevée (${_pairingCoefficient!.toStringAsFixed(3)})'
                            : 'Coefficient : ${_pairingCoefficient!.toStringAsFixed(3)}',
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
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Saillie
            Text(
              'Saillie',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de saillie'),
              subtitle: Text(localizations.formatMediumDate(_matingDate)),
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: () => _pickDate(
                  initialDate: _matingDate,
                  onSelected: (DateTime value) => _matingDate = value,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Palpation
            Text(
              'Palpation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monitor_heart),
              title: Text(
                _palpationDate != null
                    ? localizations.formatMediumDate(_palpationDate!)
                    : 'Non programmée',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_palpationDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _palpationDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _pickDate(
                      initialDate: _palpationDate ?? _matingDate.add(const Duration(days: 14)),
                      onSelected: (DateTime value) => _palpationDate = value,
                    ),
                  ),
                ],
              ),
            ),
            DropdownButtonFormField<String>(
              value: _palpationResult,
              decoration: const InputDecoration(
                labelText: 'Résultat',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'unknown', child: Text('À confirmer')),
                DropdownMenuItem<String>(value: 'positive', child: Text('Gestante')),
                DropdownMenuItem<String>(value: 'negative', child: Text('Non gestante')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _palpationResult = value);
                }
              },
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Mise bas
            Text(
              'Mise bas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date prévue : $plannedKindling',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.nest_cam_wired_stand),
              title: Text(
                _kindlingDate != null
                    ? localizations.formatMediumDate(_kindlingDate!)
                    : 'Non enregistrée',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_kindlingDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _kindlingDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _pickDate(
                      initialDate: _kindlingDate ?? _matingDate.add(const Duration(days: 31)),
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
                      prefixIcon: Icon(Icons.child_care),
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
                      prefixIcon: Icon(Icons.sentiment_dissatisfied),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Sevrage
            Text(
              'Sevrage',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.child_care_outlined),
              title: Text(
                _weaningDate != null
                    ? localizations.formatMediumDate(_weaningDate!)
                    : 'Non enregistré',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_weaningDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _weaningDate = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _pickDate(
                      initialDate: _weaningDate ??
                          (_kindlingDate ?? _matingDate.add(const Duration(days: 31)))
                              .add(const Duration(days: 28)),
                      onSelected: (DateTime value) => _weaningDate = value,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weanedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Lapereaux sevrés',
                prefixIcon: Icon(Icons.groups),
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Section: Notes
            Text(
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observations',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes),
                ),
              ),
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
