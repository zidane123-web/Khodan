import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/event_repository.dart';

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

final List<_EventTemplate> _savedEventTemplates = <_EventTemplate>[];

class BatchEventFormDialog extends StatefulWidget {
  const BatchEventFormDialog({
    required this.animals,
    required this.repository,
    super.key,
  });

  final List<Animal> animals;
  final EventRepository repository;

  static Future<List<LivestockEvent>?> show(
    BuildContext context, {
    required List<Animal> animals,
    required EventRepository repository,
  }) {
    return showDialog<List<LivestockEvent>>(
      context: context,
      builder: (BuildContext context) => BatchEventFormDialog(
        animals: animals,
        repository: repository,
      ),
    );
  }

  @override
  State<BatchEventFormDialog> createState() => _BatchEventFormDialogState();
}

class _BatchEventFormDialogState extends State<BatchEventFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _templateNameController = TextEditingController();
  DateTime _eventDate = DateTime.now();
  String? _eventType;
  String? _selectedTemplateName;
  bool _saveAsTemplate = false;

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _treatmentController.dispose();
    _templateNameController.dispose();
    super.dispose();
  }

  String _formatNumber(double? value) {
    if (value == null) {
      return '';
    }
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

  bool get _requiresWeight => _eventType == 'weight';
  bool get _requiresPrice => _eventType == 'sale';
  bool get _requiresTreatment =>
      _eventType == 'treatment' || _eventType == 'vaccination';

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
        final double? effectiveWeight = weight ??
            double.tryParse(_weightController.text.replaceAll(',', '.'));
        if (effectiveWeight != null) {
          details['weightKg'] = effectiveWeight;
        }
        break;
      case 'sale':
        final double? effectivePrice = price ??
            double.tryParse(_priceController.text.replaceAll(',', '.'));
        if (effectivePrice != null) {
          details['salePrice'] = effectivePrice;
        }
        break;
      case 'treatment':
      case 'vaccination':
        final String? effectiveProduct =
            product ?? _treatmentController.text.trim();
        if (effectiveProduct != null && effectiveProduct.isNotEmpty) {
          details['product'] = effectiveProduct;
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
        const SnackBar(content: Text('Choisissez un type d’évènement.')),
      );
      return;
    }

    final double? parsedWeight = _requiresWeight
        ? double.tryParse(_weightController.text.replaceAll(',', '.'))
        : null;
    final double? parsedPrice = _requiresPrice
        ? double.tryParse(_priceController.text.replaceAll(',', '.'))
        : null;
    final String? parsedProduct = _requiresTreatment
        ? (_treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim())
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
      final int existingIndex = _savedEventTemplates
          .indexWhere((_EventTemplate value) => value.name == name);
      if (existingIndex >= 0) {
        _savedEventTemplates[existingIndex] = template;
      } else {
        _savedEventTemplates.add(template);
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

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(createdEvents);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String selectedSummary = widget.animals
        .map((Animal animal) => animal.tagId)
        .join(', ');

    return AlertDialog(
      title: const Text('Nouvel évènement groupé'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.animals.length > 1
                    ? '${widget.animals.length} animaux sélectionnés'
                    : '1 animal sélectionné',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                selectedSummary,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_savedEventTemplates.isNotEmpty) ...<Widget>[
                DropdownButtonFormField<String>(
                  value: _selectedTemplateName,
                  decoration: const InputDecoration(
                    labelText: 'Appliquer un modèle',
                  ),
                  hint: const Text('Choisir un modèle'),
                  items: _savedEventTemplates
                      .map(
                        (_EventTemplate template) => DropdownMenuItem<String>(
                          value: template.name,
                          child: Text(template.name),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value == null) {
                      setState(() {
                        _selectedTemplateName = null;
                        _templateNameController.clear();
                      });
                    } else {
                      final _EventTemplate template = _savedEventTemplates
                          .firstWhere((_EventTemplate element) => element.name == value);
                      _applyTemplate(template);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: const InputDecoration(labelText: 'Type d’évènement'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'weight',
                    child: Text('Pesée'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'vaccination',
                    child: Text('Vaccination'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'treatment',
                    child: Text('Traitement'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'sale',
                    child: Text('Vente'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _eventType = value;
                  });
                },
                validator: (String? value) =>
                    value == null ? 'Sélection obligatoire' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date de l’action'),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Poids (kg)',
                    helperText: 'Valeur appliquée à chaque animal sélectionné',
                  ),
                  validator: (String? value) {
                    if (!_requiresWeight) {
                      return null;
                    }
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Montant (EUR)',
                    helperText: 'Prix appliqué à chaque animal vendu',
                  ),
                  validator: (String? value) {
                    if (!_requiresPrice) {
                      return null;
                    }
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
                    labelText: _eventType == 'vaccination'
                        ? 'Vaccin utilisé'
                        : 'Produit administré',
                  ),
                  validator: (String? value) {
                    if (!_requiresTreatment) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'Précisez le produit administré';
                    }
                    return null;
                  },
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
                subtitle: const Text(
                  'Sauvegarder ces paramètres pour les appliquer en un clic.',
                ),
                value: _saveAsTemplate,
                onChanged: (bool value) {
                  setState(() {
                    _saveAsTemplate = value;
                    if (value && _templateNameController.text.isEmpty) {
                      final String suggestion =
                          _eventType != null ? 'Modèle ${_eventType!}' : '';
                      _templateNameController.text =
                          _selectedTemplateName ?? suggestion;
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
