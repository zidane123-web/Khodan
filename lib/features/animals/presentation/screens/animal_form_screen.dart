// lib/features/animals/presentation/screens/animal_form_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_media.dart';
import '../../../../data/models/species_config.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../../../data/repositories/species_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/animal_cubit.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key, this.animal});

  final Animal? animal;

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tagController;
  late final TextEditingController _nameController;
  late final TextEditingController _cageController;
  late final TextEditingController _originController;

  late String _selectedSex;
  late String _selectedStatus;
  DateTime? _birthDate;
  DateTime? _entryDate;
  DateTime? _firstBreedingDate;
  String? _sireId;
  String? _damId;
  String? _photoPath;
  String? _pendingPhotoPath;
  String? _coverPreviewUrl;
  bool _isSaving = false;

  // Referentials
  List<SpeciesConfig> _species = <SpeciesConfig>[];
  int? _selectedSpeciesId;
  bool _loadingSpecies = false;

  @override
  void initState() {
    super.initState();
    _initializeForm(widget.animal);
  }

  void _initializeForm(Animal? initial) {
    _tagController = TextEditingController(text: initial?.tagId ?? '');
    _nameController = TextEditingController(text: initial?.name ?? '');
    _cageController = TextEditingController(text: initial?.cageNumber ?? '');
    _originController = TextEditingController(text: initial?.origin ?? '');
    _selectedSex = initial?.sex ?? 'Femelle';
    _selectedStatus = initial?.status ?? 'Vivant';
    _birthDate = initial?.birthDate ?? DateTime.now();
    _entryDate = initial?.entryDate ?? DateTime.now();
    _firstBreedingDate = initial?.firstBreedingDate;
    _sireId = initial?.sireId;
    _damId = initial?.damId;
    _photoPath = null;
    _pendingPhotoPath = null;
    _coverPreviewUrl = initial?.imageUrl;
    _selectedSpeciesId = initial?.speciesId;
    _loadSpecies();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _cageController.dispose();
    _originController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    setState(() => _loadingSpecies = true);
    try {
      final AuthState auth = context.read<AuthCubit>().state;
      final String? profileId = auth.profile?.id ?? auth.session?.user.id;
      if (profileId == null) {
        setState(() => _loadingSpecies = false);
        return;
      }
      final SpeciesRepository repo = context.read<SpeciesRepository>();
      final List<SpeciesConfig> all = await repo.fetchSpecies(profileId);
      all.sort(
        (SpeciesConfig a, SpeciesConfig b) =>
            a.speciesName.compareTo(b.speciesName),
      );
      setState(() {
        _species = all;
        if (_selectedSpeciesId == null && _species.isNotEmpty) {
          _selectedSpeciesId = _species.first.id;
        }
        _loadingSpecies = false;
      });
    } catch (_) {
      setState(() => _loadingSpecies = false);
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked == null || !mounted) {
      return;
    }

    CroppedFile? cropped;
    try {
      cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: <CropAspectRatioPreset>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Recadrer la photo',
            aspectRatioLockEnabled: false,
            aspectRatioPresets: <CropAspectRatioPreset>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );
    } catch (_) {
      cropped = null;
    }

    final String targetPath = cropped?.path ?? picked.path;
    if (!mounted) {
      return;
    }
    setState(() {
      _photoPath = targetPath;
      _pendingPhotoPath = targetPath;
      _coverPreviewUrl = null;
    });

    if (cropped != null && cropped.path != picked.path) {
      final File original = File(picked.path);
      try {
        if (await original.exists()) {
          await original.delete();
        }
      } catch (_) {}
    }
  }

  Animal? _buildAnimal() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }

    if (_selectedSpeciesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une espèce.')),
      );
      return null;
    }

    // --- Date Validation ---
    if (_entryDate!.isBefore(_birthDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La date d'entrée ne peut pas être antérieure à la date de naissance.",
          ),
        ),
      );
      return null;
    }
    if (_firstBreedingDate != null &&
        _firstBreedingDate!.isBefore(_birthDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La date de première saillie ne peut pas être antérieure à la date de naissance.',
          ),
        ),
      );
      return null;
    }

    final AuthState auth = context.read<AuthCubit>().state;
    final String profileId =
        auth.profile?.id ?? auth.session?.user.id ?? 'demo-profile';

    final Animal baseAnimal =
        widget.animal ??
        Animal(
          id: 'animal-${DateTime.now().millisecondsSinceEpoch}',
          profileId: profileId,
          speciesId: _selectedSpeciesId!,
          tagId: '',
          birthDate: _birthDate!,
          sex: _selectedSex,
          status: _selectedStatus,
        );

    final Animal result = baseAnimal.copyWith(
      tagId: _tagController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      sex: _selectedSex,
      status: _selectedStatus,
      birthDate: _birthDate,
      entryDate: _entryDate,
      firstBreedingDate: _firstBreedingDate,
      cageNumber: _cageController.text.trim().isEmpty
          ? null
          : _cageController.text.trim(),
      origin: _originController.text.trim().isEmpty
          ? null
          : _originController.text.trim(),
      sireId: _sireId,
      damId: _damId,
      imageUrl: _pendingPhotoPath != null ? null : _coverPreviewUrl,
    );

    return result;
  }

  Future<Animal?> _submit() async {
    if (_isSaving) {
      return null;
    }
    final Animal? built = _buildAnimal();
    if (built == null) {
      return null;
    }

    setState(() => _isSaving = true);
    try {
      final AnimalRepository repository = context.read<AnimalRepository>();
      final MediaRepository mediaRepository = context.read<MediaRepository>();
      Animal saved = widget.animal == null
          ? await repository.createAnimal(built)
          : await repository.updateAnimal(built);

      if (_pendingPhotoPath != null && _pendingPhotoPath!.isNotEmpty) {
        try {
          final AnimalMedia uploaded = await mediaRepository.uploadAnimalPhoto(
            profileId: saved.profileId,
            animalId: saved.id,
            filePath: _pendingPhotoPath!,
          );
          saved = saved.copyWith(
            imageUrl: uploaded.signedUrl ?? saved.imageUrl,
          );
          if (mounted) {
            setState(() {
              _coverPreviewUrl = uploaded.signedUrl ?? _coverPreviewUrl;
              _photoPath = uploaded.localPath ?? _photoPath;
              _pendingPhotoPath = null;
            });
          }
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    "Photo mise en file d'attente pour synchronisation.",
                  ),
                ),
              );
          }
        }
      }

      if (mounted) {
        unawaited(context.read<AnimalCubit>().fetchAnimals());
      }
      return saved;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Enregistrement impossible : $error')),
          );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _submitAndClose() async {
    final Animal? animal = await _submit();
    if (animal != null && mounted) {
      Navigator.of(context).pop(animal);
    }
  }

  Future<void> _submitAndReset() async {
    final Animal? animal = await _submit();
    if (animal != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${animal.tagId} a ete enregistre.')),
        );
      setState(() {
        _formKey.currentState?.reset();
        _initializeForm(null);
      });
    }
  }

  Widget _buildCoverPreview(ThemeData theme) {
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      final File file = File(_photoPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    if (_coverPreviewUrl != null && _coverPreviewUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _coverPreviewUrl!,
        fit: BoxFit.cover,
        placeholder: (BuildContext context, String _) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const CircularProgressIndicator.adaptive(),
        ),
        errorWidget: (BuildContext context, String _, Object __) =>
            _coverPlaceholder(theme),
      );
    }

    return _coverPlaceholder(theme);
  }

  Widget _coverPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add_a_photo_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          const Text('Ajouter une photo'),
        ],
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    if (result != null) {
      setState(() {
        onSelected(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.animal != null;
    final ThemeData theme = Theme.of(context);

    final allAnimals = context.read<AnimalCubit>().state.allAnimals;
    final males = allAnimals
        .where(
          (a) =>
              a.sex.toLowerCase().contains('mâ') ||
              a.sex.toLowerCase().contains('mal'),
        )
        .toList();
    final females = allAnimals
        .where((a) => a.sex.toLowerCase().contains('fem'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la fiche' : 'Nouvel animal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Enregistrer',
            onPressed: _isSaving ? null : () => _submitAndClose(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (_isSaving) ...<Widget>[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            // --- Section Photo ---
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _buildCoverPreview(theme),
                      if (_isSaving)
                        Container(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.45,
                          ),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator.adaptive(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Section Espèce ---
            Text('Espèce', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedSpeciesId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner une espèce',
                  ),
                  items: _species
                      .map(
                        (SpeciesConfig s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.speciesName),
                        ),
                      )
                      .toList(),
                  onChanged: _loadingSpecies
                      ? null
                      : (int? value) {
                          setState(() {
                            _selectedSpeciesId = value;
                          });
                        },
                  validator: (int? v) =>
                      v == null ? 'Sélection obligatoire' : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Section Identification ---
            Text('Identification', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Identifiant (Tag)',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom (Optionnel)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Sexe'),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Femelle', label: Text('Femelle')),
                        ButtonSegment(value: 'Mâle', label: Text('Mâle')),
                      ],
                      selected: {_selectedSex},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedSex = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Vivant',
                          child: Text('Vivant'),
                        ),
                        DropdownMenuItem(value: 'Vendu', child: Text('Vendu')),
                        DropdownMenuItem(value: 'Mort', child: Text('Mort')),
                        DropdownMenuItem(
                          value: 'Réformé',
                          child: Text('Réformé'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Section Généalogie ---
            Text('Généalogie', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _sireId,
                      decoration: const InputDecoration(
                        labelText: 'Père (Sire)',
                      ),
                      items: males
                          .map(
                            (animal) => DropdownMenuItem(
                              value: animal.id,
                              child: Text(animal.tagId),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _sireId = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _damId,
                      decoration: const InputDecoration(
                        labelText: 'Mère (Dam)',
                      ),
                      items: females
                          .map(
                            (animal) => DropdownMenuItem(
                              value: animal.id,
                              child: Text(animal.tagId),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _damId = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Section Dates et Origine ---
            Text('Dates et Origine', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DateField(
                      label: 'Date de naissance',
                      date: _birthDate,
                      onTap: () => _pickDate(
                        initialDate: _birthDate,
                        onSelected: (date) => _birthDate = date,
                      ),
                      validator: (value) =>
                          value == null ? 'Date obligatoire' : null,
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: "Date d'entrée",
                      date: _entryDate,
                      onTap: () => _pickDate(
                        initialDate: _entryDate,
                        onSelected: (date) => _entryDate = date,
                      ),
                      validator: (value) =>
                          value == null ? 'Date obligatoire' : null,
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: 'Première saillie (Optionnel)',
                      date: _firstBreedingDate,
                      onTap: () => _pickDate(
                        initialDate: _firstBreedingDate,
                        onSelected: (date) => _firstBreedingDate = date,
                      ),
                      validator: (_) => null, // Not required
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _originController,
                      decoration: const InputDecoration(
                        labelText: 'Origine (Optionnel)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cageController,
                      decoration: const InputDecoration(
                        labelText: 'Cage (Optionnel)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Section Actions ---
            if (!isEditing) // Show only on new animal screen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      onPressed: _isSaving ? null : () => _submitAndReset(),
                      label: const Text('Enregistrer et Ajouter'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : () => _submitAndClose(),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : () => _submitAndClose(),
                  child: const Text('Enregistrer les modifications'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for date fields to avoid repetition
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.validator,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final FormFieldValidator<DateTime?>? validator;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: date != null ? localizations.formatMediumDate(date!) : '',
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      onTap: onTap,
      validator: (value) {
        if (validator != null) {
          return validator!(date);
        }
        return null;
      },
    );
  }
}
