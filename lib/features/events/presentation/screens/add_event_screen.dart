import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_event.dart';
import '../../../../data/models/event.dart';
import '../../../../data/models/event_template.dart';
import '../../../../data/models/food_type.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/repositories/event_template_repository.dart';
import '../../../../data/repositories/food_inventory_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/events_cubit.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({
    required this.animals,
    this.category, // 'health' | 'other' | null
    super.key,
  });

  final List<Animal> animals;
  final String? category;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _eventTypeFieldKey =
      GlobalKey<FormFieldState<String>>();
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
  final TextEditingController _inventoryScopeController =
      TextEditingController();
  final TextEditingController _inventoryDescriptionController =
      TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  // Champs supplémentaires pour "Autres"
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  // Nettoyage / Désinfection
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _cleaningProductController =
      TextEditingController();
  final TextEditingController _concentrationController =
      TextEditingController();
  final TextEditingController _contactTimeController = TextEditingController();
  // Maintenance
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _maintenanceActionController =
      TextEditingController();
  // Achat / Arrivage
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _purchaseLotController = TextEditingController();
  DateTime? _quarantineStartDate;
  DateTime? _quarantineEndDate;
  // Décès / Réforme
  final TextEditingController _deathCauseController = TextEditingController();
  final TextEditingController _deathMethodController = TextEditingController();
  final TextEditingController _deathWeightController = TextEditingController();
  final TextEditingController _handledByController = TextEditingController();
  // Changement de bague / ID
  final TextEditingController _oldTagController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  // Changement d'alimentation
  final TextEditingController _feedNameController = TextEditingController();
  final TextEditingController _rationController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _feedReasonController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  String? _eventType;
  String? _selectedTemplateName;
  bool _saveAsTemplate = false;
  DateTime? _nextDueDate;
  bool _isGlobalEvent = false;
  late Set<String> _selectedAnimalIds;

  final Uuid _uuid = const Uuid();
  late final EventRepository _eventRepository;
  bool _isSubmitting = false;

  // Simple in-memory templates for this session/screen
  static final List<_EventTemplate> _savedTemplates = <_EventTemplate>[];

  // Referentials
  List<EventTemplate> _templates = <EventTemplate>[];
  List<FoodType> _foodTypes = <FoodType>[];
  int? _selectedFoodTypeId;
  // No explicit loading indicator here; screen-level context remains responsive.

  @override
  void initState() {
    super.initState();
    _eventRepository = context.read<EventRepository>();
    if (widget.category == 'health' && _eventType == null) {
      _eventType = 'vaccination';
    } else if (widget.category == 'other' && _eventType == null) {
      _eventType = 'cage_change';
    }
    _selectedAnimalIds = widget.animals.map((Animal a) => a.id).toSet();
    _loadReferentials();
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
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _operatorController.dispose();
    _costController.dispose();
    _zoneController.dispose();
    _cleaningProductController.dispose();
    _concentrationController.dispose();
    _contactTimeController.dispose();
    _equipmentController.dispose();
    _maintenanceActionController.dispose();
    _supplierController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _purchaseLotController.dispose();
    _deathCauseController.dispose();
    _deathMethodController.dispose();
    _deathWeightController.dispose();
    _handledByController.dispose();
    _oldTagController.dispose();
    _newTagController.dispose();
    _reasonController.dispose();
    _feedNameController.dispose();
    _rationController.dispose();
    _frequencyController.dispose();
    _feedReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadReferentials() async {
    // no-op loading flag
    try {
      final AuthState auth = context.read<AuthCubit>().state;
      final String? profileId = auth.profile?.id ?? auth.session?.user.id;
      if (profileId != null) {
        final EventTemplateRepository tplRepo = context
            .read<EventTemplateRepository>();
        FoodInventoryRepository? foodRepo;
        try {
          foodRepo = context.read<FoodInventoryRepository>();
        } catch (_) {
          foodRepo = null;
        }
        final List<EventTemplate> templates = await tplRepo.fetchTemplates(
          profileId,
        );
        templates.sort(
          (EventTemplate a, EventTemplate b) =>
              a.templateName.compareTo(b.templateName),
        );

        List<FoodType> foodTypes = <FoodType>[];
        if (foodRepo != null) {
          try {
            foodTypes = await foodRepo.fetchFoodTypes(profileId);
            foodTypes.sort(
              (FoodType a, FoodType b) => a.name.compareTo(b.name),
            );
          } catch (_) {
            foodTypes = <FoodType>[];
          }
        }

        if (!mounted) return;
        setState(() {
          _templates = templates;
          _foodTypes = foodTypes;
          if (_selectedFoodTypeId != null &&
              _foodTypes.every(
                (FoodType type) => type.id != _selectedFoodTypeId,
              )) {
            _selectedFoodTypeId = null;
          }
        });
      } else {
        // not signed in; ignore
      }
    } catch (_) {
      // ignore errors and keep screen usable
    }
  }

  String _resolveProfileId() {
    final AuthState auth = context.read<AuthCubit>().state;
    return auth.profile?.id ?? auth.session?.user.id ?? 'demo-profile';
  }

  void _applyTemplateFromModel(EventTemplate tpl) {
    setState(() {
      _eventType = tpl.eventType;
      _selectedTemplateName = tpl.templateName;
      final Map<String, dynamic> d = tpl.defaultDetails;
      _weightController.text = (d['weight'] ?? '').toString();
      _priceController.text = (d['price'] ?? '').toString();
      _treatmentController.text = (d['product'] ?? d['treatment'] ?? '')
          .toString();
      _notesController.text = (d['notes'] ?? '').toString();
      _doseController.text = (d['dose'] ?? '').toString();
      _doseUnitController.text = (d['doseUnit'] ?? '').toString();
      _lotNumberController.text = (d['lotNumber'] ?? '').toString();
      _fromCageController.text = (d['from'] ?? '').toString();
      _toCageController.text = (d['to'] ?? '').toString();
      _inventoryScopeController.text = (d['scope'] ?? '').toString();
      _inventoryDescriptionController.text = (d['description'] ?? '')
          .toString();
      _noteTitleController.text = (d['title'] ?? '').toString();
      _fromLocationController.text = (d['from'] ?? '').toString();
      _toLocationController.text = (d['to'] ?? '').toString();
      _operatorController.text = (d['operator'] ?? '').toString();
      _zoneController.text = (d['zone'] ?? '').toString();
      _cleaningProductController.text = (d['product'] ?? '').toString();
      _concentrationController.text = (d['concentration'] ?? '').toString();
      _contactTimeController.text = (d['contactTimeMin'] ?? '').toString();
      _equipmentController.text = (d['equipment'] ?? '').toString();
      _maintenanceActionController.text = (d['action'] ?? '').toString();
      _supplierController.text = (d['supplier'] ?? '').toString();
      _quantityController.text = (d['quantity'] ?? '').toString();
      _unitPriceController.text = (d['unitPrice'] ?? '').toString();
      _purchaseLotController.text = (d['lot'] ?? '').toString();
      _deathCauseController.text = (d['cause'] ?? '').toString();
      _deathMethodController.text = (d['method'] ?? '').toString();
      _deathWeightController.text = (d['weightKg'] ?? '').toString();
      _handledByController.text = (d['handledBy'] ?? '').toString();
      _oldTagController.text = (d['oldTag'] ?? '').toString();
      _newTagController.text = (d['newTag'] ?? '').toString();
      _reasonController.text = (d['reason'] ?? '').toString();
      _feedNameController.text = (d['feed'] ?? d['feedName'] ?? '').toString();
      _rationController.text = (d['ration'] ?? '').toString();
      _frequencyController.text = (d['frequency'] ?? '').toString();
      _feedReasonController.text = (d['reason'] ?? '').toString();
      if (tpl.eventType == 'feed_change') {
        final Object? rawFoodTypeId = d['foodTypeId'] ?? d['food_type_id'];
        int? parsedFoodTypeId;
        if (rawFoodTypeId is int) {
          parsedFoodTypeId = rawFoodTypeId;
        } else if (rawFoodTypeId is String) {
          parsedFoodTypeId = int.tryParse(rawFoodTypeId);
        }
        _selectedFoodTypeId = parsedFoodTypeId;
      } else {
        _selectedFoodTypeId = null;
      }
      final String? nextDue = d['nextDueDate'] as String?;
      _nextDueDate = nextDue == null ? null : DateTime.tryParse(nextDue);
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

  Future<void> _pickQuarantineDate({required bool start}) async {
    final DateTime now = DateTime.now();
    final DateTime? initial = start ? _quarantineStartDate : _quarantineEndDate;
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (selected != null) {
      setState(() {
        if (start) {
          _quarantineStartDate = selected;
        } else {
          _quarantineEndDate = selected;
        }
      });
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
      if (template.eventType != 'feed_change') {
        _selectedFoodTypeId = null;
      }
    });
    _eventTypeFieldKey.currentState?.didChange(_eventType);
  }

  Map<String, dynamic> _buildDetails(
    Animal animal, {
    double? weight,
    double? price,
    String? product,
  }) {
    final Map<String, dynamic> details = <String, dynamic>{};
    if (!_isGlobalEvent) {
      details.addAll(<String, dynamic>{
        'animalIds': <String>[animal.id],
        'animalTag': animal.tagId,
        'animalName': animal.name,
      });
    }

    switch (_eventType) {
      case 'weight':
        final double? effectiveWeight =
            weight ??
            double.tryParse(_weightController.text.replaceAll(',', '.'));
        if (effectiveWeight != null) {
          details['weightKg'] = effectiveWeight;
        }
        break;
      case 'sale':
        final double? effectivePrice =
            price ??
            double.tryParse(_priceController.text.replaceAll(',', '.'));
        if (effectivePrice != null) {
          details['salePrice'] = effectivePrice;
        }
        break;
      case 'treatment':
      case 'vaccination':
        final String effectiveProduct = (product ?? _treatmentController.text)
            .trim();
        if (effectiveProduct.isNotEmpty) {
          details['product'] = effectiveProduct;
        }
        if (_veterinarianController.text.trim().isNotEmpty) {
          details['veterinarian'] = _veterinarianController.text.trim();
        }
        if (_doseController.text.trim().isNotEmpty) {
          final double? dose = double.tryParse(
            _doseController.text.replaceAll(',', '.'),
          );
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
      case 'transfer':
        final String from = _fromLocationController.text.trim();
        final String to = _toLocationController.text.trim();
        if (from.isNotEmpty) details['from'] = from;
        if (to.isNotEmpty) details['to'] = to;
        if (_operatorController.text.trim().isNotEmpty) {
          details['operator'] = _operatorController.text.trim();
        }
        break;
      case 'cleaning':
        if (_zoneController.text.trim().isNotEmpty) {
          details['zone'] = _zoneController.text.trim();
        }
        if (_cleaningProductController.text.trim().isNotEmpty) {
          details['product'] = _cleaningProductController.text.trim();
        }
        if (_concentrationController.text.trim().isNotEmpty) {
          final double? c = double.tryParse(
            _concentrationController.text.replaceAll(',', '.'),
          );
          if (c != null) details['concentration'] = c;
        }
        if (_contactTimeController.text.trim().isNotEmpty) {
          final int? t = int.tryParse(_contactTimeController.text);
          if (t != null) details['contactTimeMin'] = t;
        }
        if (_operatorController.text.trim().isNotEmpty) {
          details['operator'] = _operatorController.text.trim();
        }
        break;
      case 'maintenance':
        if (_equipmentController.text.trim().isNotEmpty) {
          details['equipment'] = _equipmentController.text.trim();
        }
        if (_maintenanceActionController.text.trim().isNotEmpty) {
          details['action'] = _maintenanceActionController.text.trim();
        }
        if (_nextDueDate != null) {
          details['nextMaintenance'] = _nextDueDate!.toIso8601String();
        }
        break;
      case 'purchase':
        if (_supplierController.text.trim().isNotEmpty) {
          details['supplier'] = _supplierController.text.trim();
        }
        if (_quantityController.text.trim().isNotEmpty) {
          final double? q = double.tryParse(
            _quantityController.text.replaceAll(',', '.'),
          );
          if (q != null) details['quantity'] = q;
        }
        if (_unitPriceController.text.trim().isNotEmpty) {
          final double? p = double.tryParse(
            _unitPriceController.text.replaceAll(',', '.'),
          );
          if (p != null) details['unitPrice'] = p;
        }
        if (_purchaseLotController.text.trim().isNotEmpty) {
          details['lot'] = _purchaseLotController.text.trim();
        }
        if (_quarantineStartDate != null) {
          details['quarantineStart'] = _quarantineStartDate!.toIso8601String();
        }
        if (_quarantineEndDate != null) {
          details['quarantineEnd'] = _quarantineEndDate!.toIso8601String();
        }
        break;
      case 'death':
        if (_deathCauseController.text.trim().isNotEmpty) {
          details['cause'] = _deathCauseController.text.trim();
        }
        if (_deathMethodController.text.trim().isNotEmpty) {
          details['method'] = _deathMethodController.text.trim();
        }
        if (_deathWeightController.text.trim().isNotEmpty) {
          final double? w = double.tryParse(
            _deathWeightController.text.replaceAll(',', '.'),
          );
          if (w != null) details['weightKg'] = w;
        }
        if (_handledByController.text.trim().isNotEmpty) {
          details['handledBy'] = _handledByController.text.trim();
        }
        break;
      case 'tag_change':
        if (_oldTagController.text.trim().isNotEmpty) {
          details['oldTag'] = _oldTagController.text.trim();
        }
        if (_newTagController.text.trim().isNotEmpty) {
          details['newTag'] = _newTagController.text.trim();
        }
        if (_reasonController.text.trim().isNotEmpty) {
          details['reason'] = _reasonController.text.trim();
        }
        break;
      case 'feed_change':
        if (_feedNameController.text.trim().isNotEmpty) {
          details['feed'] = _feedNameController.text.trim();
        }
        if (_rationController.text.trim().isNotEmpty) {
          details['ration'] = _rationController.text.trim();
        }
        if (_frequencyController.text.trim().isNotEmpty) {
          details['frequency'] = _frequencyController.text.trim();
        }
        if (_selectedFoodTypeId != null) {
          details['foodTypeId'] = _selectedFoodTypeId;
        }
        if (_feedReasonController.text.trim().isNotEmpty) {
          details['reason'] = _feedReasonController.text.trim();
        }
        break;
    }

    if (_costController.text.trim().isNotEmpty) {
      final double? cost = double.tryParse(
        _costController.text.replaceAll(',', '.'),
      );
      if (cost != null) {
        details['cost'] = cost;
      }
    }

    return details;
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_eventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un type d\'evenement.')),
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
    final String? trimmedNotes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (_requiresWeight && (parsedWeight == null || parsedWeight <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un poids positif.')),
      );
      return;
    }
    if (_requiresPrice && (parsedPrice == null || parsedPrice <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un montant positif.')),
      );
      return;
    }
    if (_requiresTreatment &&
        (parsedProduct == null || parsedProduct.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precisez le produit utilise.')),
      );
      return;
    }

    final Set<String> availableIds = widget.animals
        .map((Animal animal) => animal.id)
        .toSet();
    final List<String> missingIds = _isGlobalEvent
        ? const <String>[]
        : _selectedAnimalIds
              .where((String id) => !availableIds.contains(id))
              .toList();
    if (missingIds.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Certains animaux selectionnes ne sont plus disponibles.',
          ),
        ),
      );
      return;
    }

    if (_isGlobalEvent && widget.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins un animal avant de continuer.'),
        ),
      );
      return;
    }

    if (_saveAsTemplate) {
      final String name = _templateNameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Indiquez un nom pour enregistrer le modele.'),
          ),
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
      final int existingIndex = _savedTemplates.indexWhere(
        (_EventTemplate t) => t.name == name,
      );
      if (existingIndex >= 0) {
        _savedTemplates[existingIndex] = template;
      } else {
        _savedTemplates.add(template);
      }
      _selectedTemplateName = name;
    }

    final String profileId = _resolveProfileId();
    final DateTime eventDateUtc = _eventDate.toUtc();
    final List<LivestockEvent> createdEvents = <LivestockEvent>[];

    setState(() => _isSubmitting = true);
    try {
      if (_isGlobalEvent) {
        final Animal representative = widget.animals.first;
        final LivestockEvent draft = LivestockEvent(
          id: _uuid.v4(),
          profileId: representative.profileId.isEmpty
              ? profileId
              : representative.profileId,
          eventType: _eventType!,
          eventDate: eventDateUtc,
          details: _buildDetails(
            representative,
            weight: parsedWeight,
            price: parsedPrice,
            product: parsedProduct,
          ),
          notes: trimmedNotes,
        );
        final LivestockEvent created = await _eventRepository.createEvent(
          draft,
          links: const <AnimalEventLink>[],
        );
        createdEvents.add(created);
      } else {
        final List<Animal> targetAnimals = widget.animals
            .where((Animal animal) => _selectedAnimalIds.contains(animal.id))
            .toList();
        if (targetAnimals.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selectionnez au moins un animal.')),
          );
          return;
        }
        for (final Animal animal in targetAnimals) {
          final LivestockEvent draft = LivestockEvent(
            id: _uuid.v4(),
            profileId: animal.profileId.isEmpty ? profileId : animal.profileId,
            eventType: _eventType!,
            eventDate: eventDateUtc,
            details: _buildDetails(
              animal,
              weight: parsedWeight,
              price: parsedPrice,
              product: parsedProduct,
            ),
            notes: trimmedNotes,
          );

          final LivestockEvent created = await _eventRepository.createEvent(
            draft,
            links: <AnimalEventLink>[
              AnimalEventLink(
                eventId: draft.id,
                animalId: animal.id,
                role: 'subject',
              ),
            ],
          );
          createdEvents.add(created);
        }
      }

      if (!mounted) {
        return;
      }
      try {
        context.read<EventsCubit>().refresh();
      } catch (_) {
        // EventsCubit absent in this scope.
      }
      Navigator.of(context).pop(createdEvents);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'enregistrer l\'evenement: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String selectedSummary = widget.animals
        .map((Animal a) => a.tagId)
        .join(', ');

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
                // Sélection des animaux et mode global
                if (!_isGlobalEvent) ...<Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: <Widget>[
                      for (final Animal animal in widget.animals)
                        FilterChip(
                          label: Text(animal.tagId),
                          selected: _selectedAnimalIds.contains(animal.id),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedAnimalIds.add(animal.id);
                              } else {
                                _selectedAnimalIds.remove(animal.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedAnimalIds = widget.animals
                                .map((Animal a) => a.id)
                                .toSet();
                          });
                        },
                        child: const Text('Tout selectionner'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedAnimalIds.clear();
                          });
                        },
                        child: const Text('Tout deselectionner'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Etat global (sans animaux)'),
                  subtitle: const Text(
                    'Cree un seul evenement non lie aux animaux',
                  ),
                  value: _isGlobalEvent,
                  onChanged: (bool value) {
                    setState(() {
                      _isGlobalEvent = value;
                    });
                  },
                ),
                if (_templates.isNotEmpty) ...<Widget>[
                  DropdownMenu<int>(
                    label: const Text('Appliquer un modele (referentiels)'),
                    hintText: 'Choisir un modele',
                    dropdownMenuEntries: _templates
                        .map(
                          (EventTemplate tpl) => DropdownMenuEntry<int>(
                            value: tpl.id,
                            label: tpl.templateName,
                          ),
                        )
                        .toList(),
                    onSelected: (int? id) {
                      if (id == null) return;
                      final EventTemplate tpl = _templates.firstWhere(
                        (EventTemplate t) => t.id == id,
                      );
                      _applyTemplateFromModel(tpl);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                if (_savedTemplates.isNotEmpty) ...<Widget>[
                  DropdownMenu<String>(
                    initialSelection: _selectedTemplateName,
                    label: const Text('Appliquer un modèle'),
                    hintText: 'Choisir un modèle',
                    dropdownMenuEntries: _savedTemplates
                        .map(
                          (_EventTemplate template) =>
                              DropdownMenuEntry<String>(
                                value: template.name,
                                label: template.name,
                              ),
                        )
                        .toList(),
                    onSelected: (String? value) {
                      if (value == null) {
                        setState(() {
                          _selectedTemplateName = null;
                          _templateNameController.clear();
                        });
                        return;
                      }
                      final _EventTemplate template = _savedTemplates
                          .firstWhere(
                            (_EventTemplate entry) => entry.name == value,
                          );
                      _applyTemplate(template);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  key: _eventTypeFieldKey,
                  initialValue:
                      _eventType ??
                      (widget.category == 'health'
                          ? 'vaccination'
                          : (widget.category == 'other'
                                ? 'cage_change'
                                : null)),
                  decoration: const InputDecoration(
                    labelText: "Type d'évènement",
                  ),
                  items: <DropdownMenuItem<String>>[
                    if (widget.category == 'health' ||
                        widget.category ==
                            null) ...const <DropdownMenuItem<String>>[
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
                        value: 'health_check',
                        child: Text('Contrôle de santé'),
                      ),
                    ],
                    if (widget.category == 'other' ||
                        widget.category ==
                            null) ...const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'cage_change',
                        child: Text('Changement de cage'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'inventory',
                        child: Text('Inventaire'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'note',
                        child: Text('Note'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'sale',
                        child: Text('Vente'),
                      ),
                    ],
                    if (widget.category == 'other' ||
                        widget.category ==
                            null) ...const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'transfer',
                        child: Text('Transfert'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'cleaning',
                        child: Text('Nettoyage / Désinfection'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'maintenance',
                        child: Text('Entretien / Maintenance'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'purchase',
                        child: Text('Achat / Arrivage'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'death',
                        child: Text('Décès / Réforme'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'tag_change',
                        child: Text('Changement de bague / ID'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'feed_change',
                        child: Text("Changement d'alimentation"),
                      ),
                    ],
                  ],
                  onChanged: (String? value) => setState(() {
                    _eventType = value;
                    if (value != 'feed_change') {
                      _selectedFoodTypeId = null;
                    }
                  }),
                  validator: (String? value) =>
                      value == null ? 'Sélection obligatoire' : null,
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Poids (kg)',
                      helperText:
                          'Valeur appliquée à chaque animal sélectionné',
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                      labelText: _eventType == 'vaccination'
                          ? 'Vaccin utilisé'
                          : 'Produit administré',
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    decoration: const InputDecoration(labelText: 'N° de lot'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(labelText: 'Vétérinaire'),
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
                    decoration: const InputDecoration(labelText: 'Description'),
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
                if (_eventType == 'transfer') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fromLocationController,
                    decoration: const InputDecoration(
                      labelText: 'De (lieu/section/batiment)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _toLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Vers (lieu/section/batiment)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _operatorController,
                    decoration: const InputDecoration(labelText: 'Operateur'),
                  ),
                ],
                if (_eventType == 'cleaning') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _zoneController,
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      hintText: 'Cage, salle, batiment…',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cleaningProductController,
                    decoration: const InputDecoration(labelText: 'Produit'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _concentrationController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Concentration (%)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contactTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Temps de contact (min)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _operatorController,
                    decoration: const InputDecoration(labelText: 'Operateur'),
                  ),
                ],
                if (_eventType == 'maintenance') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _equipmentController,
                    decoration: const InputDecoration(labelText: 'Equipement'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _maintenanceActionController,
                    decoration: const InputDecoration(
                      labelText: 'Action realisee',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prochaine maintenance'),
                    subtitle: Text(
                      _nextDueDate == null
                          ? 'Aucune'
                          : localizations.formatMediumDate(_nextDueDate!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_note_outlined),
                      onPressed: _pickNextDueDate,
                    ),
                  ),
                ],
                if (_eventType == 'purchase') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _supplierController,
                    decoration: const InputDecoration(labelText: 'Fournisseur'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantite'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _unitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _purchaseLotController,
                    decoration: const InputDecoration(labelText: 'N° de lot'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Debut quarantaine'),
                    subtitle: Text(
                      _quarantineStartDate == null
                          ? '—'
                          : localizations.formatMediumDate(
                              _quarantineStartDate!,
                            ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_note_outlined),
                      onPressed: () => _pickQuarantineDate(start: true),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fin quarantaine'),
                    subtitle: Text(
                      _quarantineEndDate == null
                          ? '—'
                          : localizations.formatMediumDate(_quarantineEndDate!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_note_outlined),
                      onPressed: () => _pickQuarantineDate(start: false),
                    ),
                  ),
                ],
                if (_eventType == 'death') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deathCauseController,
                    decoration: const InputDecoration(labelText: 'Cause'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deathMethodController,
                    decoration: const InputDecoration(
                      labelText: 'Methode / gestion',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deathWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Poids (kg)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _handledByController,
                    decoration: const InputDecoration(labelText: 'Gere par'),
                  ),
                ],
                if (_eventType == 'tag_change') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _oldTagController,
                    decoration: const InputDecoration(
                      labelText: 'Ancienne bague / ID',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      labelText: 'Nouvelle bague / ID',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(labelText: 'Raison'),
                  ),
                ],
                if (_eventType == 'feed_change') ...<Widget>[
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Type d'aliment",
                    ),
                    isEmpty:
                        !(_selectedFoodTypeId != null &&
                            _foodTypes.any(
                              (FoodType type) => type.id == _selectedFoodTypeId,
                            )),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value:
                            _selectedFoodTypeId != null &&
                                _foodTypes.any(
                                  (FoodType type) =>
                                      type.id == _selectedFoodTypeId,
                                )
                            ? _selectedFoodTypeId
                            : null,
                        isExpanded: true,
                        hint: const Text('Type non defini'),
                        items: <DropdownMenuItem<int?>>[
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Type non defini'),
                          ),
                          ..._foodTypes.map(
                            (FoodType type) => DropdownMenuItem<int?>(
                              value: type.id,
                              child: Text(type.name),
                            ),
                          ),
                        ],
                        onChanged: (int? value) =>
                            setState(() => _selectedFoodTypeId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _feedNameController,
                    decoration: const InputDecoration(labelText: 'Aliment'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rationController,
                    decoration: const InputDecoration(
                      labelText: 'Ration',
                      hintText: 'Ex: 120 g/j',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _frequencyController,
                    decoration: const InputDecoration(
                      labelText: 'Frequence',
                      hintText: 'Ex: 2x par jour',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _feedReasonController,
                    decoration: const InputDecoration(labelText: 'Raison'),
                  ),
                ],
                if (_eventType == 'health_check') ...<Widget>[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(labelText: 'Vétérinaire'),
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
                  subtitle: const Text(
                    'Sauvegarder ces paramètres pour les appliquer en un clic.',
                  ),
                  value: _saveAsTemplate,
                  onChanged: (bool value) {
                    setState(() {
                      _saveAsTemplate = value;
                      if (value && _templateNameController.text.isEmpty) {
                        final String suggestion = _eventType != null
                            ? 'Modèle ${_eventType!}'
                            : '';
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
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
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
