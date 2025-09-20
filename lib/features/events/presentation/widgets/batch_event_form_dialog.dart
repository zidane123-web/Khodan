import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/event_repository.dart';

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
  DateTime _eventDate = DateTime.now();
  String? _eventType;

  @override
  void dispose() {
    _notesController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _treatmentController.dispose();
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

  bool get _requiresWeight => _eventType == 'weight';
  bool get _requiresPrice => _eventType == 'sale';
  bool get _requiresTreatment =>
      _eventType == 'treatment' || _eventType == 'vaccination';

  Map<String, dynamic> _buildDetails(Animal animal) {
    final Map<String, dynamic> details = <String, dynamic>{
      'animalIds': <String>[animal.id],
      'animalTag': animal.tagId,
      'animalName': animal.name,
    };

    switch (_eventType) {
      case 'weight':
        final double? weight =
            double.tryParse(_weightController.text.replaceAll(',', '.'));
        if (weight != null) {
          details['weightKg'] = weight;
        }
        break;
      case 'sale':
        final double? price =
            double.tryParse(_priceController.text.replaceAll(',', '.'));
        if (price != null) {
          details['salePrice'] = price;
        }
        break;
      case 'treatment':
      case 'vaccination':
        if (_treatmentController.text.trim().isNotEmpty) {
          details['product'] = _treatmentController.text.trim();
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

    final List<LivestockEvent> createdEvents = <LivestockEvent>[];

    for (final Animal animal in widget.animals) {
      final LivestockEvent draft = LivestockEvent(
        id: 'event-${DateTime.now().millisecondsSinceEpoch}-${animal.id}',
        profileId: animal.profileId,
        eventType: _eventType!,
        eventDate: _eventDate,
        details: _buildDetails(animal),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
