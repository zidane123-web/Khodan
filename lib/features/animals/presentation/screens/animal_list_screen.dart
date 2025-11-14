// lib/features/animals/presentation/screens/animal_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:khodan/features/account/presentation/cubit/subscription_cubit.dart';
import 'package:khodan/features/account/presentation/widgets/subscription_quota_banner.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/services/breeder_import_service.dart';
import '../../../../data/local/local_data_sources.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
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
      create: (BuildContext context) => AnimalCubit(
        context.read<AnimalRepository>(),
        localDataSource: context.read<LocalAnimalDataSource>(),
      )..fetchAnimals(),
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
  late final BreedingRepository _breedingRepository;
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};
  final BreederImportService _importService = BreederImportService();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _breedingRepository = context.read<BreedingRepository>();
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
    final SubscriptionState subscription =
        context.read<SubscriptionCubit>().state;
    if (subscription.breedersLimitReached) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Limite d'éleveurs atteinte. Passez à un plan supérieur pour créer une nouvelle fiche.",
          ),
        ),
      );
      context.push('/settings/account');
      return;
    }
    final Animal? created = await Navigator.of(context).push<Animal>(
      MaterialPageRoute<Animal>(
        builder: (_) => BlocProvider.value(
          value: context.read<AnimalCubit>(),
          child: const AnimalFormScreen(),
        ),
      ),
    );

    if (created != null && mounted) {
      await context.read<AnimalCubit>().fetchAnimals();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiche animal creee.')),
      );
    }
  }

  Future<void> _openQuickBreeding(Animal animal, AnimalState state) async {
    final BreedingRecord? record = await Navigator.of(context)
        .push<BreedingRecord>(
          MaterialPageRoute<BreedingRecord>(
            builder: (_) => AddBreedingRecordScreen(initialDoeId: animal.id),
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
            'Saillie enregistree pour ${animal.name ?? animal.tagId}.',
          ),
        ),
      );
    }
  }

  Future<void> _openBatchEventForm(List<Animal> animals) async {
    final List<LivestockEvent>? created = await BatchEventFormDialog.show(
      context,
      animals: animals,
    );

    if (created != null && created.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created.length > 1
                ? '${created.length} evenements crees.'
                : 'Evenement cree.',
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
      MaterialPageRoute<Animal>(
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
        const SnackBar(content: Text('Fiche animal mise a jour.')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fiche animal supprimee.')));
    }
  }

  void _openFilters(AnimalState state) async {
    final AnimalFilters? result = await showModalBottomSheet<AnimalFilters>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => _AnimalFiltersSheet(
        initialFilters: state.filters,
        animals: state.allAnimals,
      ),
    );

    if (result != null && mounted) {
      context.read<AnimalCubit>().setFilters(result);
    }
  }

  Future<void> _importBreeders() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final PlatformFile file = result.files.first;
    final List<int>? bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecture du fichier impossible.')),
      );
      return;
    }

    final BreederImportPreview preview = _importService.previewFromBytes(
      bytes,
      sourceName: file.name,
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          BreederImportPreviewDialog(preview: preview),
    );
  }

  Future<void> _handleGroupAction(
    _GroupAction action,
    List<Animal> animals,
  ) async {
    if (animals.isEmpty) {
      return;
    }
    final Map<_GroupAction, String> titles = <_GroupAction, String>{
      _GroupAction.breeding: 'Confirmer la saillie groupee',
      _GroupAction.archive: 'Confirmer l archivage',
      _GroupAction.sell: 'Confirmer la vente',
    };
    final Map<_GroupAction, String> placeholders = <_GroupAction, String>{
      _GroupAction.breeding:
          'Planification de saillie groupee a finaliser avec Supabase.',
      _GroupAction.archive:
          'Archivage en attente de la connexion a la base distante.',
      _GroupAction.sell:
          'Marquage comme vendu a completer dans la synchronisation.',
    };
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titles[action]!),
          content: Text(
            'Vous etes sur le point d appliquer cette action a ${animals.length} eleveur(s). Cette action sera finalisee lorsque la connexion Supabase sera disponible.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(placeholders[action]!)),
      );
    }
  }

  List<_SearchSuggestion> _buildSearchSuggestions(
    List<Animal> animals,
    String query,
  ) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.length < 2) {
      return const <_SearchSuggestion>[];
    }
    final Set<String> seen = <String>{};
    final List<_SearchSuggestion> matches = <_SearchSuggestion>[];
    for (final Animal animal in animals) {
      final List<String?> fields = <String?>[
        animal.name,
        animal.tagId,
        animal.cageNumber,
        animal.breed,
      ];
      bool match = false;
      for (final String? field in fields) {
        if (field != null && field.toLowerCase().contains(normalized)) {
          match = true;
          break;
        }
      }
      if (!match) {
        continue;
      }
      if (!seen.add(animal.id)) {
        continue;
      }
      final String label =
          (animal.name != null && animal.name!.isNotEmpty) ? animal.name! : animal.tagId;
      final List<String> secondaryParts = <String>[
        'ID ${animal.tagId}',
        if (animal.cageNumber != null && animal.cageNumber!.isNotEmpty)
          'Cage ${animal.cageNumber!}',
        if (animal.breed != null && animal.breed!.isNotEmpty)
          animal.breed!,
      ];
      matches.add(
        _SearchSuggestion(
          label: label,
          secondary: secondaryParts.isEmpty
              ? null
              : secondaryParts.join(' - '),
          animal: animal,
        ),
      );
    }
    matches.sort((_SearchSuggestion a, _SearchSuggestion b) => a.label.compareTo(b.label));
    return matches.length > 6 ? matches.sublist(0, 6) : matches;
  }

  Widget _buildSuggestionsPanel(List<_SearchSuggestion> suggestions) {
    final ThemeData theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final _SearchSuggestion suggestion = suggestions[index];
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(suggestion.label),
              subtitle:
                  suggestion.secondary == null ? null : Text(suggestion.secondary!),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) =>
                        AnimalDetailScreen(animal: suggestion.animal),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFiltersSummary(AnimalState state) {
    final AnimalFilters filters = state.filters;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> chips = <Widget>[];
    void addChip(String label, VoidCallback onDeleted) {
      chips.add(InputChip(label: Text(label), onDeleted: onDeleted));
    }

    if (filters.sex != null) {
      addChip(
        'Sexe: ${filters.sex}',
        () => context.read<AnimalCubit>().setFilters(
              filters.copyWith(clearSex: true),
            ),
      );
    }

    if (filters.statuses != null) {
      for (final String status in filters.statuses!) {
        addChip(
          'Statut: $status',
          () {
            final Set<String> updated =
                Set<String>.from(filters.statuses!)..remove(status);
            context.read<AnimalCubit>().setFilters(
                  filters.copyWith(
                    statuses: updated,
                    clearStatuses: updated.isEmpty,
                  ),
                );
          },
        );
      }
    }

    if (filters.breeds != null) {
      for (final String breed in filters.breeds!) {
        addChip(
          'Race: $breed',
          () {
            final Set<String> updated =
                Set<String>.from(filters.breeds!)..remove(breed);
            context.read<AnimalCubit>().setFilters(
                  filters.copyWith(
                    breeds: updated,
                    clearBreeds: updated.isEmpty,
                  ),
                );
          },
        );
      }
    }

    if (filters.categories != null) {
      for (final String category in filters.categories!) {
        addChip(
          'Categorie: $category',
          () {
            final Set<String> updated =
                Set<String>.from(filters.categories!)..remove(category);
            context.read<AnimalCubit>().setFilters(
                  filters.copyWith(
                    categories: updated,
                    clearCategories: updated.isEmpty,
                  ),
                );
          },
        );
      }
    }

    if (filters.birthStart != null || filters.birthEnd != null) {
      final String start = filters.birthStart == null
          ? ''
          : localizations.formatMediumDate(filters.birthStart!);
      final String end = filters.birthEnd == null
          ? ''
          : localizations.formatMediumDate(filters.birthEnd!);
      addChip(
        filters.birthStart != null && filters.birthEnd != null
            ? 'Naissance: $start -> $end'
            : filters.birthStart != null
                ? 'Naissance apres $start'
                : 'Naissance avant $end',
        () => context.read<AnimalCubit>().setFilters(
              filters.copyWith(
                clearBirthStart: true,
                clearBirthEnd: true,
              ),
            ),
      );
    }

    if (filters.entryStart != null || filters.entryEnd != null) {
      final String start = filters.entryStart == null
          ? ''
          : localizations.formatMediumDate(filters.entryStart!);
      final String end = filters.entryEnd == null
          ? ''
          : localizations.formatMediumDate(filters.entryEnd!);
      addChip(
        filters.entryStart != null && filters.entryEnd != null
            ? 'Entree: $start -> $end'
            : filters.entryStart != null
                ? 'Entree apres $start'
                : 'Entree avant $end',
        () => context.read<AnimalCubit>().setFilters(
              filters.copyWith(
                clearEntryStart: true,
                clearEntryEnd: true,
              ),
            ),
      );
    }

    if (filters.onlyRecentLitters) {
      addChip(
        'Portees < 90 jours',
        () => context.read<AnimalCubit>().setFilters(
              filters.copyWith(onlyRecentLitters: false),
            ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
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
    final List<_SearchSuggestion> suggestions = _buildSearchSuggestions(
      state.allAnimals,
      state.filters.searchTerm,
    );

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
        BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (BuildContext context, SubscriptionState subscriptionState) {
            if (!subscriptionState.showQuotaBanner) {
              return const SizedBox.shrink();
            }
            return SubscriptionQuotaBanner(
              state: subscriptionState,
              onAction: () => context.push('/settings/account'),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher nom, tatouage, cage ou race',
              suffixIcon: state.filters.searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<AnimalCubit>().updateSearchTerm('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSuggestionsPanel(suggestions),
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
    return MultiBlocListener(
      listeners: <BlocListener<AnimalCubit, AnimalState>>[
        BlocListener<AnimalCubit, AnimalState>(
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
        ),
        BlocListener<AnimalCubit, AnimalState>(
          listenWhen: (AnimalState previous, AnimalState current) =>
              previous.allAnimals.length != current.allAnimals.length,
          listener: (BuildContext context, AnimalState state) {
            context.read<SubscriptionCubit>().reportUsage(
                  breeders: state.allAnimals.length,
                );
          },
        ),
      ],
      child: BlocBuilder<AnimalCubit, AnimalState>(
        builder: (BuildContext context, AnimalState state) {
          final List<Animal> currentAnimals = state.animals;
          final bool hasSelection = _selectedIds.isNotEmpty;
          return Scaffold(
            appBar: AppBar(
              leading: _selectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Fermer la selection',
                      onPressed: _toggleSelectionMode,
                    )
                  : null,
              title: Text(
                _selectionMode
                    ? 'Selection (${_selectedIds.length})'
                    : 'Eleveurs',
              ),
              actions: <Widget>[
                if (!_selectionMode &&
                    (state.filters.searchTerm.isNotEmpty ||
                        state.filters.hasAdvancedFilters))
                  IconButton(
                    tooltip: 'Reinitialiser les filtres',
                    icon: const Icon(Icons.filter_alt_off),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AnimalCubit>().clearAllFilters();
                    },
                  ),
                if (!_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.upload_file),
                    tooltip: 'Importer CSV',
                    onPressed: _importBreeders,
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
                    tooltip: 'Tout selectionner',
                    onPressed: () => _selectAll(currentAnimals),
                  ),
                if (_selectionMode && hasSelection)
                  PopupMenuButton<_GroupAction>(
                    icon: const Icon(Icons.more_horiz),
                    tooltip: 'Actions groupees',
                    onSelected: (_GroupAction action) {
                      final List<Animal> selected = currentAnimals
                          .where(
                            (Animal animal) =>
                                _selectedIds.contains(animal.id),
                          )
                          .toList();
                      _handleGroupAction(action, selected);
                    },
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<_GroupAction>>[
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.breeding,
                        child: Text('Saillie groupee'),
                      ),
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.archive,
                        child: Text('Archiver'),
                      ),
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.sell,
                        child: Text('Marquer vendu'),
                      ),
                    ],
                  ),
                IconButton(
                  icon: Icon(
                    _selectionMode ? Icons.check_box : Icons.check_box_outlined,
                  ),
                  tooltip: _selectionMode
                      ? 'Quitter la selection'
                      : 'Selection multiple',
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
                            ? 'Evenement groupe (${_selectedIds.length})'
                            : 'Selectionner des eleveurs',
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
                  ? 'Aucun animal ne correspond a votre recherche.'
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
                      child: const Text('Reinitialiser les filtres'),
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
  const _AnimalFiltersSheet({required this.initialFilters, required this.animals});

  final AnimalFilters initialFilters;
  final List<Animal> animals;

  @override
  State<_AnimalFiltersSheet> createState() => _AnimalFiltersSheetState();
}

class _AnimalFiltersSheetState extends State<_AnimalFiltersSheet> {
  static const List<String> _statusOptions = <String>['Actif', 'Repos', 'Archive', 'Vendu'];
  static const List<String> _categoryOptions = <String>[
    'Lapine',
    'Lapin',
    'Remplacante',
    'Reproducteur',
    'Reforme',
  ];

  late String? _selectedSex;
  late Set<String> _selectedStatuses;
  late Set<String> _selectedBreeds;
  late Set<String> _selectedCategories;
  DateTime? _birthStart;
  DateTime? _birthEnd;
  DateTime? _entryStart;
  DateTime? _entryEnd;
  bool _onlyRecent = false;
  late final TextEditingController _breedController;
  late final List<String> _knownBreeds;

  @override
  void initState() {
    super.initState();
    _selectedSex = widget.initialFilters.sex;
    _selectedStatuses = widget.initialFilters.statuses == null
        ? <String>{}
        : Set<String>.from(widget.initialFilters.statuses!);
    _selectedBreeds = widget.initialFilters.breeds == null
        ? <String>{}
        : Set<String>.from(widget.initialFilters.breeds!);
    _selectedCategories = widget.initialFilters.categories == null
        ? <String>{}
        : Set<String>.from(widget.initialFilters.categories!);
    _birthStart = widget.initialFilters.birthStart;
    _birthEnd = widget.initialFilters.birthEnd;
    _entryStart = widget.initialFilters.entryStart;
    _entryEnd = widget.initialFilters.entryEnd;
    _onlyRecent = widget.initialFilters.onlyRecentLitters;
    _breedController = TextEditingController();
    final Set<String> breeds = <String>{};
    for (final Animal animal in widget.animals) {
      if (animal.breed != null && animal.breed!.trim().isNotEmpty) {
        breeds.add(animal.breed!.trim());
      }
    }
    _knownBreeds = breeds.toList()..sort();
  }

  @override
  void dispose() {
    _breedController.dispose();
    super.dispose();
  }

  void _toggleValue(Set<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  Future<void> _pickBirthRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange: _birthStart != null && _birthEnd != null
          ? DateTimeRange(start: _birthStart!, end: _birthEnd!)
          : null,
    );
    if (range != null) {
      setState(() {
        _birthStart = range.start;
        _birthEnd = range.end;
      });
    }
  }

  Future<void> _pickEntryRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _entryStart != null && _entryEnd != null
          ? DateTimeRange(start: _entryStart!, end: _entryEnd!)
          : null,
    );
    if (range != null) {
      setState(() {
        _entryStart = range.start;
        _entryEnd = range.end;
      });
    }
  }

  void _addCustomBreed() {
    final String value = _breedController.text.trim();
    if (value.isEmpty) {
      return;
    }
    setState(() {
      _selectedBreeds.add(value);
      if (!_knownBreeds.contains(value)) {
        _knownBreeds.add(value);
        _knownBreeds.sort();
      }
      _breedController.clear();
    });
  }

  void _reset() {
    setState(() {
      _selectedSex = null;
      _selectedStatuses.clear();
      _selectedBreeds.clear();
      _selectedCategories.clear();
      _birthStart = null;
      _birthEnd = null;
      _entryStart = null;
      _entryEnd = null;
      _onlyRecent = false;
      _breedController.clear();
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      AnimalFilters(
        searchTerm: widget.initialFilters.searchTerm,
        sex: _selectedSex,
        statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses,
        breeds: _selectedBreeds.isEmpty ? null : _selectedBreeds,
        categories: _selectedCategories.isEmpty ? null : _selectedCategories,
        birthStart: _birthStart,
        birthEnd: _birthEnd,
        entryStart: _entryStart,
        entryEnd: _entryEnd,
        onlyRecentLitters: _onlyRecent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Filtres eleveurs', style: theme.textTheme.titleMedium),
                ),
                TextButton(onPressed: _reset, child: const Text('Reinitialiser')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedSex,
              decoration: const InputDecoration(labelText: 'Sexe'),
              hint: const Text('Tous'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Femelle', child: Text('Femelle')),
                DropdownMenuItem<String>(value: 'Male', child: Text('Male')),
              ],
              onChanged: (String? value) => setState(() => _selectedSex = value),
            ),
            const SizedBox(height: 16),
            Text('Statuts', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions
                  .map(
                    (String status) => FilterChip(
                      selected: _selectedStatuses.contains(status),
                      label: Text(status),
                      onSelected: (_) => _toggleValue(_selectedStatuses, status),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Categories', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categoryOptions
                  .map(
                    (String category) => FilterChip(
                      selected: _selectedCategories.contains(category),
                      label: Text(category),
                      onSelected: (_) => _toggleValue(_selectedCategories, category),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Races', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_knownBreeds.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _knownBreeds
                    .map(
                      (String breed) => FilterChip(
                        selected: _selectedBreeds.contains(breed),
                        label: Text(breed),
                        onSelected: (_) => _toggleValue(_selectedBreeds, breed),
                      ),
                    )
                    .toList(),
              ),
            TextField(
              controller: _breedController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Ajouter une race',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCustomBreed,
                ),
              ),
              onSubmitted: (_) => _addCustomBreed(),
            ),
            const SizedBox(height: 16),
            Text('Naissance', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickBirthRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _birthStart == null || _birthEnd == null
                          ? 'Selectionner une periode'
                          : '${localizations.formatMediumDate(_birthStart!)} -> ${localizations.formatMediumDate(_birthEnd!)}',
                    ),
                  ),
                ),
                if (_birthStart != null || _birthEnd != null)
                  IconButton(
                    tooltip: 'Effacer',
                    onPressed: () => setState(() {
                      _birthStart = null;
                      _birthEnd = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Entree', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEntryRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _entryStart == null || _entryEnd == null
                          ? 'Selectionner une periode'
                          : '${localizations.formatMediumDate(_entryStart!)} -> ${localizations.formatMediumDate(_entryEnd!)}',
                    ),
                  ),
                ),
                if (_entryStart != null || _entryEnd != null)
                  IconButton(
                    tooltip: 'Effacer',
                    onPressed: () => setState(() {
                      _entryStart = null;
                      _entryEnd = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Derniere portee inferieure a 90 jours'),
              value: _onlyRecent,
              onChanged: (bool value) => setState(() => _onlyRecent = value),
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

class BreederImportPreviewDialog extends StatelessWidget {
  const BreederImportPreviewDialog({required this.preview, super.key});

  final BreederImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<BreederImportRow> sampleRows = preview.rows.take(10).toList();
    final List<String> headers = preview.headers;

    return AlertDialog(
      title: Text(preview.sourceName ?? 'Apercu import CSV'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Fichier: ${preview.sourceName ?? 'inconnu'}'),
              Text('Lignes valides: ${preview.validCount}'),
              Text('Lignes en erreur: ${preview.invalidCount}'),
              if (preview.errors.isNotEmpty) ...preview.errors
                  .map((String error) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          error,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )),
              const SizedBox(height: 16),
              if (sampleRows.isEmpty)
                const Text('Aucune ligne a afficher pour le moment.')
              else ...<Widget>[
                const Text('Apercu des 10 premieres lignes:'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: headers
                        .map((String header) => DataColumn(label: Text(header)))
                        .toList(),
                    rows: sampleRows
                        .map(
                          (BreederImportRow row) => DataRow(
                            color: row.isValid
                                ? null
                                : WidgetStatePropertyAll<Color>(
                                    theme.colorScheme.errorContainer.withValues(alpha: 0.35),
                                  ),
                            cells: headers
                                .map((String header) => DataCell(
                                      Text(row.values[header] ?? ''),
                                    ))
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (preview.invalidCount > 0) ...<Widget>[
                const Text('Details des erreurs (limite 5 lignes):'),
                const SizedBox(height: 8),
                ...preview.rows
                    .where((BreederImportRow row) => row.issues.isNotEmpty)
                    .take(5)
                    .map(
                      (BreederImportRow row) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Ligne ${row.index}: ${row.issues.join('; ')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                if (preview.invalidCount > 5)
                  Text(
                    '... ${preview.invalidCount - 5} lignes supplementaires comportent des erreurs.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Remarque: cette previsualisation ne lance pas encore la creation des eleveurs sur Supabase.',
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

enum _GroupAction { breeding, archive, sell }

class _SearchSuggestion {
  const _SearchSuggestion({
    required this.label,
    required this.secondary,
    required this.animal,
  });

  final String label;
  final String? secondary;
  final Animal animal;
}

