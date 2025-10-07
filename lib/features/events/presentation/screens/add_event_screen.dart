import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/event_repository.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({
    required this.animals,
    required this.repository,
    this.category, // 'health' | 'other' | null
    super.key,
  });

  final List<Animal> animals;
  final EventRepository repository;
  final String? category;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _veterinarianController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _doseUnitController = TextEditingController();
  final TextEditingController _lotNumberController = TextEditingController();
  final TextEditingController _fromCageController = TextEditingController();
  final TextEditingController _toCageController = TextEditingController();
  final TextEditingController _inventoryScopeController = TextEditingController();
  final TextEditingController _inventoryDescriptionController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  
  DateTime _eventDate = DateTime.now();
  String? _eventType;
  String? _selectedTemplateName;
  bool _saveAsTemplate = false;
  DateTime? _nextDueDate;

  // Simple in-memory templates for this session/screen
  static final List<_EventTemplate> _savedTemplates = <_EventTemplate>[];

  @override
  void initState() {
    super.initState();
    if (widget.category == 'health' && _eventType == null) {
      _eventType = 'vaccination';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _treatmentController.dispose();
    _templateNameController.dispose();
    _veterinarianController.dispose();
    _doseController.dispose();
    _doseUnitController.dispose();
    _lotNumberController.dispose();
    _fromCageController.dispose();
    _toCageController.dispose();
    _inventoryScopeController.dispose();
    _inventoryDescriptionController.dispose();
    _noteTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      setState(() => _eventDate = selected);
    }
  }

  Future<void> _pickNextDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _nextDueDate ?? now;
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null) {
      setState(() => _nextDueDate = selected);
    }
  }

  bool get _requiresWeight => _eventType == 'weight';
  bool get _requiresPrice => _eventType == 'sale';
  bool get _requiresTreatment =>
      _eventType == 'treatment' || _eventType == 'vaccination';

  String _formatNumber(double? value) {
    if (value == null) return '';
    final bool isInteger = (value - value.round()).abs() < 0.001;
    return isInteger ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  void _applyTemplate(_EventTemplate template) {
    setState(() {
      _selectedTemplateName = template.name;
      _eventType = template.eventType;
      _weightController.text = _formatNumber(template.weight);
      _priceController.text = _formatNumber(template.price);
      _treatmentController.text = template.product ?? '';
      _notesController.text = template.notes ?? '';
      _templateNameController.text = template.name;
    });
  }

  Map<String, dynamic> _buildDetails(
    Animal animal, {
    double? weight,
    double? price,
    String? product,
  }) {
    final Map<String, dynamic> details = <String, dynamic>{
      'animalIds': <String>[animal.id],
      'animalTag': animal.tagId,
      'animalName': animal.name,
    };

    switch (_eventType) {
      case 'weight':
        final double? effectiveWeight =
            weight ?? double.tryParse(_weightController.text.replaceAll(',', '.'));
        if (effectiveWeight != null) {
          details['weightKg'] = effectiveWeight;
        }
        break;
      case 'sale':
        final double? effectivePrice =
            price ?? double.tryParse(_priceController.text.replaceAll(',', '.'));
        if (effectivePrice != null) {
          details['salePrice'] = effectivePrice;
        }
        break;
      case 'treatment':
      case 'vaccination':
        final String effectiveProduct = (product ?? _treatmentController.text).trim();
        if (effectiveProduct.isNotEmpty) {
          details['product'] = effectiveProduct;
        }
        if (_veterinarianController.text.trim().isNotEmpty) {
          details['veterinarian'] = _veterinarianController.text.trim();
        }
        if (_doseController.text.trim().isNotEmpty) {
          final double? dose = double.tryParse(_doseController.text.replaceAll(',', '.'));
          if (dose != null) {
            details['dose'] = dose;
          }
        }
        if (_doseUnitController.text.trim().isNotEmpty) {
          details['doseUnit'] = _doseUnitController.text.trim();
        }
        if (_lotNumberController.text.trim().isNotEmpty) {
          details['lotNumber'] = _lotNumberController.text.trim();
        }
        if (_nextDueDate != null) {
          details['nextDueDate'] = _nextDueDate!.toIso8601String();
        }
        break;
      case 'health_check':
        if (_veterinarianController.text.trim().isNotEmpty) {
          details['veterinarian'] = _veterinarianController.text.trim();
        }
        if (_nextDueDate != null) {
          details['nextDueDate'] = _nextDueDate!.toIso8601String();
        }
        break;
      case 'cage_change':
        final String from = _fromCageController.text.trim();
        final String to = _toCageController.text.trim();
        if (from.isNotEmpty) {
          details['from'] = from;
        }
        if (to.isNotEmpty) {
          details['to'] = to;
        }
        break;
      case 'inventory':
        final String scope = _inventoryScopeController.text.trim();
        final String desc = _inventoryDescriptionController.text.trim();
        if (scope.isNotEmpty) {
          details['scope'] = scope;
        }
        if (desc.isNotEmpty) {
          details['description'] = desc;
        }
        break;
      case 'note':
        final String title = _noteTitleController.text.trim();
        if (title.isNotEmpty) {
          details['title'] = title;
        }
        break;
    }

    return details;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_eventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un type d\'évènement.')),
      );
      return;
    }

    final double? parsedWeight =
        _requiresWeight ? double.tryParse(_weightController.text.replaceAll(',', '.')) : null;
    final double? parsedPrice =
        _requiresPrice ? double.tryParse(_priceController.text.replaceAll(',', '.')) : null;
    final String? parsedProduct = _requiresTreatment
        ? (_treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim())
        : null;
    final String? trimmedNotes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (_saveAsTemplate) {
      final String name = _templateNameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indiquez un nom pour enregistrer le modèle.')),
        );
        return;
      }
      final _EventTemplate template = _EventTemplate(
        name: name,
        eventType: _eventType!,
        weight: parsedWeight,
        price: parsedPrice,
        product: parsedProduct,
        notes: trimmedNotes,
      );
      final int existingIndex =
          _savedTemplates.indexWhere((_EventTemplate t) => t.name == name);
      if (existingIndex >= 0) {
        _savedTemplates[existingIndex] = template;
      } else {
        _savedTemplates.add(template);
      }
      _selectedTemplateName = name;
    }

    final List<LivestockEvent> createdEvents = <LivestockEvent>[];
    for (final Animal animal in widget.animals) {
      final LivestockEvent draft = LivestockEvent(
        id: 'event-${DateTime.now().millisecondsSinceEpoch}-${animal.id}',
        profileId: animal.profileId,
        eventType: _eventType!,
        eventDate: _eventDate,
        details: _buildDetails(
          animal,
          weight: parsedWeight,
          price: parsedPrice,
          product: parsedProduct,
        ),
        notes: trimmedNotes,
      );

      final LivestockEvent created = await widget.repository.createEvent(
        draft,
        links: <AnimalEventLink>[
          AnimalEventLink(eventId: draft.id, animalId: animal.id, role: 'subject'),
        ],
      );
      createdEvents.add(created);
    }

    if (!mounted) return;
    Navigator.of(context).pop(createdEvents);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String selectedSummary = widget.animals.map((Animal a) => a.tagId).join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == 'health'
              ? 'Nouvel événement santé'
              : (widget.category == 'other'
                  ? 'Nouvel événement (autres)'
                  : 'Ajouter un événement'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.animals.length > 1
                      ? '${widget.animals.length} animaux sélectionnés'
                      : '1 animal sélectionné',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(selectedSummary, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                if (_savedTemplates.isNotEmpty) ...<Widget>[
                  DropdownButtonFormField<String>(
                    value: _selectedTemplateName,
                    decoration: const InputDecoration(labelText: 'Appliquer un modèle'),
                    hint: const Text('Choisir un modèle'),
                    items: _savedTemplates
                        .map((
                          _EventTemplate t,
                        ) => DropdownMenuItem<String>(value: t.name, child: Text(t.name)))
                        .toList(),
                    onChanged: (String? value) {
                      if (value == null) {
                        setState(() {
                          _selectedTemplateName = null;
                          _templateNameController.clear();
                        });
                      } else {
                        final _EventTemplate template =
                            _savedTemplates.firstWhere((_EventTemplate el) => el.name == value);
                        _applyTemplate(template);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: _eventType ?? (widget.category == 'health' ? 'vaccination' : (widget.category == 'other' ? 'cage_change' : null)),
                  decoration: const InputDecoration(labelText: "Type d'évènement"),
                  items: <DropdownMenuItem<String>>[
                    if (widget.category == 'health' || widget.category == null) ...const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(value: 'weight', child: Text('Pesée')),
                      DropdownMenuItem<String>(value: 'vaccination', child: Text('Vaccination')),
                      DropdownMenuItem<String>(value: 'treatment', child: Text('Traitement')),
                      DropdownMenuItem<String>(value: 'health_check', child: Text('Contrôle de santé')),
                    ],
                    if (widget.category == 'other' || widget.category == null) ...const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(value: 'cage_change', child: Text('Changement de cage')),
                      DropdownMenuItem<String>(value: 'inventory', child: Text('Inventaire')),
                      DropdownMenuItem<String>(value: 'note', child: Text('Note')),
                      DropdownMenuItem<String>(value: 'sale', child: Text('Vente')),
                    ],
                  ],
                  onChanged: (String? value) => setState(() => _eventType = value),
                  validator: (String? value) => value == null ? 'Sélection obligatoire' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Date de l'action"),
                  subtitle: Text(localizations.formatMediumDate(_eventDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _pickDate,
                  ),
                ),
                if (_requiresWeight) ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Poids (kg)',
                      helperText: 'Valeur appliquée à chaque animal sélectionné',
                    ),
                    validator: (String? value) {
                      if (!_requiresWeight) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Renseignez le poids mesuré';
                      }
                      return double.tryParse(value.replaceAll(',', '.')) == null
                          ? 'Format invalide'
                          : null;
                    },
                  ),
                ],
                if (_requiresPrice) ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Montant (EUR)',
                      helperText: 'Prix appliqué à chaque animal vendu',
                    ),
                    validator: (String? value) {
                      if (!_requiresPrice) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Indiquez le montant';
                      }
                      return double.tryParse(value.replaceAll(',', '.')) == null
                          ? 'Format invalide'
                          : null;
                    },
                  ),
                ],
                if (_requiresTreatment) ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _treatmentController,
                    decoration: InputDecoration(
                      labelText: _eventType == 'vaccination' ? 'Vaccin utilisé' : 'Produit administré',
                    ),
                    validator: (String? value) {
                      if (!_requiresTreatment) return null;
                      if (value == null || value.trim().isEmpty) {
                        return 'Précisez le produit administré';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _doseController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      hintText: 'Ex: 2.0',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _doseUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Unité (mg, ml, …)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lotNumberController,
                    decoration: const InputDecoration(
                      labelText: 'N° de lot',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(
                      labelText: 'Vétérinaire',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date de rappel / suivi'),
                    subtitle: Text(
                      _nextDueDate == null
                          ? 'Aucun'
                          : localizations.formatMediumDate(_nextDueDate!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_note_outlined),
                      onPressed: _pickNextDueDate,
                    ),
                  ),
                ],
                if (_eventType == 'cage_change') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fromCageController,
                    decoration: const InputDecoration(
                      labelText: 'De la cage',
                      hintText: 'Ex: C-102',
                    ),
                    validator: (String? v) {
                      if (_eventType != 'cage_change') return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Champ obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _toCageController,
                    decoration: const InputDecoration(
                      labelText: 'Vers la cage',
                      hintText: 'Ex: C-108',
                    ),
                    validator: (String? v) {
                      if (_eventType != 'cage_change') return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Champ obligatoire';
                      }
                      return null;
                    },
                  ),
                ],
                if (_eventType == 'inventory') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _inventoryScopeController,
                    decoration: const InputDecoration(
                      labelText: 'Périmètre (scope)',
                      hintText: 'Ex: farm, alimentation, matériel…',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _inventoryDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                ],
                if (_eventType == 'note') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre de la note',
                    ),
                  ),
                ],
                if (_eventType == 'health_check') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(
                      labelText: 'Vétérinaire',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date de suivi'),
                    subtitle: Text(
                      _nextDueDate == null
                          ? 'Aucun'
                          : localizations.formatMediumDate(_nextDueDate!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_note_outlined),
                      onPressed: _pickNextDueDate,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enregistrer comme modèle'),
                  subtitle: const Text('Sauvegarder ces paramètres pour les appliquer en un clic.'),
                  value: _saveAsTemplate,
                  onChanged: (bool value) {
                    setState(() {
                      _saveAsTemplate = value;
                      if (value && _templateNameController.text.isEmpty) {
                        final String suggestion = _eventType != null ? 'Modèle ${_eventType!}' : '';
                        _templateNameController.text = _selectedTemplateName ?? suggestion;
                      }
                    });
                  },
                ),
                if (_saveAsTemplate) ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _templateNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du modèle',
                      hintText: 'Vaccination trimestrielle, pesée mensuelle…',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTemplate {
  const _EventTemplate({
    required this.name,
    required this.eventType,
    this.weight,
    this.price,
    this.product,
    this.notes,
  });

  final String name;
  final String eventType;
  final double? weight;
  final double? price;
  final String? product;
  final String? notes;
}
