import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khodan/data/local/local_data_sources.dart';
import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/features/animals/presentation/cubit/animal_cubit.dart';
import 'package:khodan/features/animals/presentation/screens/animal_form_screen.dart';
import 'package:khodan/features/events/presentation/cubit/breeding_cubit.dart';
import 'package:khodan/features/events/presentation/cubit/events_cubit.dart';
import 'package:khodan/features/events/presentation/screens/add_breeding_record_screen.dart';
import 'package:khodan/features/events/presentation/screens/add_event_screen.dart';
import 'package:khodan/features/litters/presentation/screens/litters_and_hutches_screen.dart';
import 'package:khodan/features/planning/presentation/screens/planning_screen.dart';

/// Écran principal du tableau de bord Khodan.
///
/// Contient :
/// - message d'accueil,
/// - actions rapides,
/// - menu + ouvrant un bottom sheet,
/// - cartes d'indicateurs avec valeurs temporaires,
/// - section planning mockée.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        tooltip: 'Ajouts rapides',
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >= 900;
          final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: isWide ? 24 : 16,
          );

          final Widget content = _DashboardContent(
            isWide: isWide,
          );

          return SafeArea(
            child: Padding(
              padding: padding,
              child: isWide
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: content,
                      ),
                    )
                  : content,
            ),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<Widget> leftColumnChildren = <Widget>[
      const _WelcomeMessage(),
      const SizedBox(height: 24),
      _QuickActions(isWide: isWide),
      const SizedBox(height: 24),
      _IndicatorsGrid(isWide: isWide),
    ];

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: leftColumnChildren,
            ),
          ),
          const SizedBox(width: 32),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: _PlanningSection(isWide: isWide),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...leftColumnChildren,
          const SizedBox(height: 24),
          _PlanningSection(isWide: isWide),
        ],
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'Bienvenue sur Khodan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Retrouvez vos elevages, vos actions rapides et les prochains evenements en un coup d\'oeil.',
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {

    final List<_DashboardAction> actions = _DashboardMockData.quickActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double availableWidth = constraints.maxWidth;
            if (availableWidth < 360) {
              final double itemWidth =
                  ((availableWidth * 0.9).clamp(220, 320)).toDouble();
              return SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: actions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: itemWidth,
                      child: _QuickActionButton(action: actions[index]),
                    );
                  },
                ),
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions
                  .map(
                    (_DashboardAction action) => SizedBox(
                      width: _computeButtonWidth(availableWidth),
                      child: _QuickActionButton(action: action),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  double _computeButtonWidth(double maxWidth) {
    if (maxWidth >= 1080) {
      return (((maxWidth - 36) / 4).clamp(220, 320)).toDouble();
    }
    if (maxWidth >= 760) {
      return (((maxWidth - 24) / 3).clamp(220, 320)).toDouble();
    }
    return (((maxWidth - 12) / 2).clamp(200, maxWidth)).toDouble();
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
  });

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      key: Key(action.semanticKey),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.centerLeft,
      ),
      onPressed: () => action.onTap(context),
      icon: Icon(action.icon),
      label: Text(action.label),
    );
  }
}

class _IndicatorsGrid extends StatelessWidget {
  const _IndicatorsGrid({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = isWide ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Indicateurs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 2.4 : 2.2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: _DashboardMockData.indicators
              .map((DashboardIndicator indicator) {
            return _IndicatorCard(indicator: indicator);
          }).toList(),
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({
    required this.indicator,
  });

  final DashboardIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((255 * 0.15).round()),
              child: Icon(
                indicator.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    indicator.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    indicator.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    indicator.helper,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningSection extends StatelessWidget {
  const _PlanningSection({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<PlanningItem> items = _DashboardMockData.planning;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Planning des 7 prochains jours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Text('Aucune tâche à venir pour le moment.')
            else
              ...items.map((PlanningItem item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.event_note,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(item.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 12),
            Align(
              alignment: isWide ? Alignment.centerLeft : Alignment.center,
              child: OutlinedButton(
                onPressed: () => DashboardQuickActions.openPlanningTasks(context),
                child: const Text('Voir tout le planning'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardIndicator {
  const DashboardIndicator({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;
}

class PlanningItem {
  const PlanningItem({
    required this.date,
    required this.label,
  });

  final String date;
  final String label;
}

typedef _DashboardActionCallback = Future<void> Function(BuildContext context);

class _DashboardAction {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.semanticKey,
  });

  final String label;
  final IconData icon;
  final _DashboardActionCallback onTap;
  final String semanticKey;
}

class _DashboardMockData {
  static final List<_DashboardAction> quickActions = <_DashboardAction>[
    _DashboardAction(
      label: 'Saillie',
      icon: Icons.favorite,
      semanticKey: 'dashboard-action-saillie',
      onTap: DashboardQuickActions.addBreeding,
    ),
    _DashboardAction(
      label: 'Mise bas',
      icon: Icons.cruelty_free,
      semanticKey: 'dashboard-action-mise-bas',
      onTap: DashboardQuickActions.openLitters,
    ),
    _DashboardAction(
      label: 'Pesée',
      icon: Icons.monitor_weight,
      semanticKey: 'dashboard-action-pesee',
      onTap: DashboardQuickActions.recordWeight,
    ),
    _DashboardAction(
      label: 'Abattage',
      icon: Icons.restaurant,
      semanticKey: 'dashboard-action-abattage',
      onTap: DashboardQuickActions.recordLoss,
    ),
  ];

  static final List<DashboardIndicator> indicators = <DashboardIndicator>[
    DashboardIndicator(
      title: 'Lapines actives',
      value: '12',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.pets,
    ),
    DashboardIndicator(
      title: 'Lapins prêts pour la vente',
      value: '8',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.shopping_basket,
    ),
    DashboardIndicator(
      title: 'Portées en cours',
      value: '5',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.home,
    ),
    DashboardIndicator(
      title: 'Tâches en retard',
      value: '2',
      helper: 'Données à connecter à Supabase.',
      icon: Icons.warning_amber,
    ),
  ];

  static final List<PlanningItem> planning = <PlanningItem>[
    PlanningItem(
      date: '02/11',
      label: 'Palpation lapine #K-24',
    ),
    PlanningItem(
      date: '03/11',
      label: 'Préparer nid portée #P-18',
    ),
    PlanningItem(
      date: '05/11',
      label: 'Pesée portée #P-11',
    ),
  ];
}

class DashboardQuickActions {
  DashboardQuickActions._();

  static Future<void> addBreeding(BuildContext context) {
    return _openBreedingForm(context);
  }

  static Future<void> openLitters(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext _) => const LittersAndHutchesScreen(),
      ),
    );
  }

  static Future<void> recordWeight(BuildContext context) {
    return _openEvent(
      context,
      category: 'health',
      initialEventType: 'weight',
      emptyMessage: 'Ajoutez vos animaux pour enregistrer une pesée.',
    );
  }

  static Future<void> recordLoss(BuildContext context) {
    return _openEvent(
      context,
      category: 'other',
      initialEventType: 'death',
      emptyMessage: 'Ajoutez vos animaux pour enregistrer une perte.',
    );
  }

  static Future<void> addBreeder(BuildContext context) {
    return _openAnimalForm(context);
  }

  static Future<void> openPlanningTasks(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext _) => const PlanningScreen(),
      ),
    );
  }

  static Future<void> _openAnimalForm(BuildContext context) async {
    final AnimalRepository repository = context.read<AnimalRepository>();
    final LocalAnimalDataSource? local = _maybeRead<LocalAnimalDataSource>(context);
    await Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext _) => BlocProvider<AnimalCubit>(
          create: (BuildContext __) => AnimalCubit(
            repository,
            localDataSource: local,
          )..fetchAnimals(),
          child: const AnimalFormScreen(),
        ),
      ),
    );
  }

  static Future<void> _openBreedingForm(BuildContext context) async {
    final BreedingRepository breedingRepository = context.read<BreedingRepository>();
    final AnimalRepository animalRepository = context.read<AnimalRepository>();
    await Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext _) => BlocProvider<BreedingCubit>(
          create: (BuildContext __) =>
              BreedingCubit(breedingRepository, animalRepository)..loadData(),
          child: const AddBreedingRecordScreen(),
        ),
      ),
    );
  }

  static Future<void> _openEvent(
    BuildContext context, {
    required String category,
    required String initialEventType,
    required String emptyMessage,
  }) async {
    final List<Animal> animals = await _loadAnimals(context);
    if (!context.mounted) {
      return;
    }
    if (animals.isEmpty) {
      _showSnack(context, emptyMessage);
      return;
    }
    EventRepository repository;
    try {
      repository = context.read<EventRepository>();
    } catch (_) {
      _showSnack(
        context,
        'Impossible de trouver le module d\'événements.',
        isError: true,
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext _) => BlocProvider<EventsCubit>(
          create: (BuildContext __) =>
              EventsCubit(repository)..loadEvents(),
          child: AddEventScreen(
            animals: animals,
            category: category,
            initialEventType: initialEventType,
          ),
        ),
      ),
    );
  }

  static Future<List<Animal>> _loadAnimals(BuildContext context) async {
    try {
      return await context.read<AnimalRepository>().fetchAnimals();
    } catch (error) {
      if (context.mounted) {
        _showSnack(
          context,
          'Impossible de charger les animaux. Veuillez réessayer.',
          isError: true,
        );
      }
      return const <Animal>[];
    }
  }

  static T? _maybeRead<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  static void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }
}

void _showQuickAddMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Ajouter un éleveur'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                if (!context.mounted) {
                  return;
                }
                await DashboardQuickActions.addBreeder(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Planifier une saillie'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                if (!context.mounted) {
                  return;
                }
                await DashboardQuickActions.addBreeding(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Créer une tâche'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                if (!context.mounted) {
                  return;
                }
                await DashboardQuickActions.openPlanningTasks(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Enregistrer une perte'),
              onTap: () async {
                await Navigator.of(context).maybePop();
                if (!context.mounted) {
                  return;
                }
                await DashboardQuickActions.recordLoss(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
