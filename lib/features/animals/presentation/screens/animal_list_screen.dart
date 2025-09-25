// lib/features/animals/presentation/screens/animal_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../events/presentation/screens/add_breeding_record_screen.dart';
import '../../../events/presentation/widgets/batch_event_form_dialog.dart';
import '../cubit/animal_cubit.dart';
import '../widgets/animal_card.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';
import 'scan_animal_screen.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalCubit>(
      create: (BuildContext context) =>
          AnimalCubit(InMemoryAnimalRepository())..fetchAnimals(),
      child: const _AnimalListView(),
    );
  }
}

class _AnimalListView extends StatefulWidget {
  const _AnimalListView();

  @override
  State<_AnimalListView> createState() => _AnimalListViewState();
}

class _AnimalListViewState extends State<_AnimalListView> {
  late final TextEditingController _searchController;
  late final EventRepository _eventRepository;
  late final BreedingRepository _breedingRepository;
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _eventRepository = InMemoryEventRepository();
    _breedingRepository = InMemoryBreedingRepository();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AnimalCubit>().updateSearchTerm(_searchController.text);
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _updateSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _selectAll(List<Animal> animals) {
    setState(() {
      if (_selectedIds.length == animals.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(animals.map((Animal animal) => animal.id));
      }
    });
  }

  Future<void> _createAnimal() async {
    // Pass the cubit to the new screen
    final newAnimal = await Navigator.of(context).push<Animal>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AnimalCubit>(),
          child: const AnimalFormScreen(),
        ),
      ),
    );

    if (newAnimal != null && mounted) {
      // The create logic is now handled inside the form screen
      // So we just refresh the list
      await context.read<AnimalCubit>().fetchAnimals();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiche animal créée.')),
      );
    }
  }

  Future<void> _openQuickBreeding(Animal animal, AnimalState state) async {
    final BreedingRecord? record = await Navigator.of(context).push<BreedingRecord>(
      MaterialPageRoute<BreedingRecord>(
        builder: (_) => AddBreedingRecordScreen(
          animals: state.allAnimals,
          initialDoeId: animal.id,
        ),
      ),
    );

    if (record != null && mounted) {
      await _breedingRepository.createBreedingRecord(record);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saillie enregistrée pour ${animal.name ?? animal.tagId}.',
          ),
        ),
      );
    }
  }

  Future<void> _openBatchEventForm(List<Animal> animals) async {
    final List<LivestockEvent>? created = await BatchEventFormDialog.show(
      context,
      animals: animals,
      repository: _eventRepository,
    );

    if (created != null && created.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created.length > 1
                ? '${created.length} évènements créés.'
                : 'Évènement créé.',
          ),
        ),
      );
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
    }
  }

  Future<void> _openScanner(AnimalState state) async {
    final Animal? result = await Navigator.of(context).push<Animal>(
      MaterialPageRoute<Animal>(
        builder: (BuildContext context) =>
            ScanAnimalScreen(animals: state.allAnimals),
      ),
    );
    if (result != null && mounted) {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => AnimalDetailScreen(animal: result),
        ),
      );
    }
  }

  Future<void> _editAnimal(Animal animal) async {
    // Pass the cubit to the new screen
    final updatedAnimal = await Navigator.of(context).push<Animal>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AnimalCubit>(),
          child: AnimalFormScreen(animal: animal),
        ),
      ),
    );
    if (updatedAnimal != null && mounted) {
      // The update logic is now handled inside the form screen
      // So we just refresh the list
      await context.read<AnimalCubit>().fetchAnimals();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiche animal mise à jour.')),
      );
    }
  }

  Future<void> _deleteAnimal(Animal animal) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer cette fiche ?'),
          content: Text(
            'Confirmer la suppression de ${animal.name ?? animal.tagId} ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<AnimalCubit>().deleteAnimal(animal.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiche animal supprimée.')),
      );
    }
  }

  void _openFilters(AnimalState state) async {
    final AnimalFilters? result = await showModalBottomSheet<AnimalFilters>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          _AnimalFiltersSheet(initialFilters: state.filters),
    );

    if (result != null && mounted) {
      context.read<AnimalCubit>().setFilters(result);
    }
  }

  Widget _buildFiltersSummary(AnimalState state) {
    final List<Widget> chips = <Widget>[
      if (state.filters.sex != null)
        InputChip(
          label: Text('Sexe : ${state.filters.sex}'),
          onDeleted: () => context
              .read<AnimalCubit>()
              .setFilters(state.filters.copyWith(clearSex: true)),
        ),
      if (state.filters.origin != null && state.filters.origin!.isNotEmpty)
        InputChip(
          label: Text('Origine : ${state.filters.origin}'),
          onDeleted: () => context
              .read<AnimalCubit>()
              .setFilters(state.filters.copyWith(clearOrigin: true)),
        ),
      if (state.filters.cageNumber != null &&
          state.filters.cageNumber!.isNotEmpty)
        InputChip(
          label: Text('Cage : ${state.filters.cageNumber}'),
          onDeleted: () => context
              .read<AnimalCubit>()
              .setFilters(state.filters.copyWith(clearCageNumber: true)),
        ),
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildBody(AnimalState state) {
    if (state.status == AnimalStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AnimalStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage ?? 'Impossible de charger les animaux.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final List<Animal> animals = state.animals;
    final bool hasFilters =
        state.filters.searchTerm.isNotEmpty || state.filters.hasAdvancedFilters;

    final Widget listContent = animals.isEmpty
        ? _EmptyAnimalsPlaceholder(
            hasFilters: hasFilters,
            onClearFilters: hasFilters
                ? () {
                    _searchController.clear();
                    context.read<AnimalCubit>().clearAllFilters();
                  }
                : null,
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: animals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Animal animal = animals[index];
              return AnimalCard(
                animal: animal,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) =>
                        AnimalDetailScreen(animal: animal),
                  ),
                ),
                onEdit: _selectionMode ? null : () => _editAnimal(animal),
                onDelete: _selectionMode ? null : () => _deleteAnimal(animal),
                onQuickBreed: _selectionMode
                    ? null
                    : () => _openQuickBreeding(animal, state),
                selectionEnabled: _selectionMode,
                isSelected: _selectedIds.contains(animal.id),
                onSelectionChanged: _selectionMode
                    ? (bool selected) => _updateSelection(animal.id, selected)
                    : null,
              );
            },
          );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher par identifiant, origine ou cage',
              suffixIcon: state.filters.searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<AnimalCubit>()
                            .updateSearchTerm('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (state.filters.hasAdvancedFilters)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFiltersSummary(state),
          ),
        Expanded(child: listContent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimalCubit, AnimalState>(
      listenWhen: (AnimalState previous, AnimalState current) =>
          previous.filters.searchTerm != current.filters.searchTerm,
      listener: (BuildContext context, AnimalState state) {
        if (_searchController.text != state.filters.searchTerm) {
          _searchController.value = TextEditingValue(
            text: state.filters.searchTerm,
            selection: TextSelection.collapsed(
              offset: state.filters.searchTerm.length,
            ),
          );
        }
      },
      child: BlocBuilder<AnimalCubit, AnimalState>(
        builder: (BuildContext context, AnimalState state) {
          final List<Animal> currentAnimals = state.animals;
          final bool hasSelection = _selectedIds.isNotEmpty;
          return Scaffold(
            appBar: AppBar(
              leading: _selectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Fermer la sélection',
                      onPressed: _toggleSelectionMode,
                    )
                  : null,
              title: Text(
                _selectionMode
                    ? '${_selectedIds.length} sélectionné(s)'
                    : 'Mes animaux',
              ),
              actions: <Widget>[
                if (!_selectionMode &&
                    (state.filters.searchTerm.isNotEmpty ||
                        state.filters.hasAdvancedFilters))
                  IconButton(
                    tooltip: 'Réinitialiser les filtres',
                    icon: const Icon(Icons.filter_alt_off),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AnimalCubit>().clearAllFilters();
                    },
                  ),
                if (!_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    tooltip: 'Filtres',
                    onPressed: () => _openFilters(state),
                  ),
                if (!_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scanner un identifiant',
                    onPressed: () => _openScanner(state),
                  ),
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    tooltip: 'Tout sélectionner',
                    onPressed: () => _selectAll(currentAnimals),
                  ),
                IconButton(
                  icon: Icon(
                    _selectionMode ? Icons.check_box : Icons.check_box_outlined,
                  ),
                  tooltip:
                      _selectionMode ? 'Quitter la sélection' : 'Sélection multiple',
                  onPressed: _toggleSelectionMode,
                ),
              ],
            ),
            body: _buildBody(state),
            floatingActionButton: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectionMode
                  ? FloatingActionButton.extended(
                      key: const ValueKey<String>('batch-event'),
                      onPressed: hasSelection
                          ? () {
                              final List<Animal> selected = currentAnimals
                                  .where(
                                    (Animal animal) =>
                                        _selectedIds.contains(animal.id),
                                  )
                                  .toList();
                              _openBatchEventForm(selected);
                            }
                          : null,
                      icon: const Icon(Icons.playlist_add_check),
                      label: Text(
                        hasSelection
                            ? 'Évènement groupé (${_selectedIds.length})'
                            : 'Sélectionner des animaux',
                      ),
                    )
                  : FloatingActionButton.extended(
                      key: const ValueKey<String>('new-animal'),
                      onPressed: _createAnimal,
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle fiche'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyAnimalsPlaceholder extends StatelessWidget {
  const _EmptyAnimalsPlaceholder({
    this.hasFilters = false,
    this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.pets_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'Aucun animal ne correspond à votre recherche.'
                  : 'Ajoutez vos premiers animaux pour suivre votre cheptel.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (hasFilters)
              Column(
                children: <Widget>[
                  const Text(
                    'Modifiez vos filtres pour afficher d’autres animaux.',
                    textAlign: TextAlign.center,
                  ),
                  if (onClearFilters != null) ...<Widget>[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onClearFilters,
                      child: const Text('Réinitialiser les filtres'),
                    ),
                  ],
                ],
              )
            else
              Text(
                'Appuyez sur le bouton + pour enregistrer un animal.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimalFiltersSheet extends StatefulWidget {
  const _AnimalFiltersSheet({required this.initialFilters});

  final AnimalFilters initialFilters;

  @override
  State<_AnimalFiltersSheet> createState() => _AnimalFiltersSheetState();
}

class _AnimalFiltersSheetState extends State<_AnimalFiltersSheet> {
  String? _selectedSex;
  late final TextEditingController _originController;
  late final TextEditingController _cageController;

  @override
  void initState() {
    super.initState();
    _selectedSex = widget.initialFilters.sex;
    _originController =
        TextEditingController(text: widget.initialFilters.origin ?? '');
    _cageController =
        TextEditingController(text: widget.initialFilters.cageNumber ?? '');
  }

  @override
  void dispose() {
    _originController.dispose();
    _cageController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selectedSex = null;
      _originController.clear();
      _cageController.clear();
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      AnimalFilters(
        searchTerm: widget.initialFilters.searchTerm,
        sex: _selectedSex,
        origin: _originController.text.trim().isEmpty
            ? null
            : _originController.text.trim(),
        cageNumber: _cageController.text.trim().isEmpty
            ? null
            : _cageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Filtres avancés',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: const InputDecoration(labelText: 'Sexe'),
              hint: const Text('Tous'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Femelle', child: Text('Femelle')),
                DropdownMenuItem<String>(value: 'Mâle', child: Text('Mâle')),
              ],
              onChanged: (String? value) => setState(() => _selectedSex = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origine',
                hintText: 'Ferme, fournisseur…',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cageController,
              decoration: const InputDecoration(
                labelText: 'Numéro de cage',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check),
                label: const Text('Appliquer les filtres'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
