import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/event.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../cubit/breeding_cubit.dart';
import '../cubit/events_cubit.dart';
import '../widgets/batch_event_form_dialog.dart';
import '../widgets/event_timeline.dart';
import '../widgets/reproduction_tab.dart';

class EventsHubScreen extends StatelessWidget {
  const EventsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BreedingRepository breedingRepository = SupabaseBreedingRepository();
    final AnimalRepository animalRepository = SupabaseAnimalRepository();
    final EventRepository eventRepository = SupabaseEventRepository();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<BreedingCubit>(
          create: (BuildContext context) =>
              BreedingCubit(breedingRepository, animalRepository)..loadData(),
        ),
        BlocProvider<EventsCubit>(
          create: (BuildContext context) =>
              EventsCubit(eventRepository)..loadEvents(),
        ),
      ],
      child: _EventsHubView(eventRepository: eventRepository),
    );
  }
}

class _EventsHubView extends StatefulWidget {
  const _EventsHubView({required this.eventRepository});

  final EventRepository eventRepository;

  @override
  State<_EventsHubView> createState() => _EventsHubViewState();
}

class _EventsHubViewState extends State<_EventsHubView>
    with SingleTickerProviderStateMixin {
  int _lastBreedingRecordCount = 0;
  bool _hasInitializedBreedingCount = false;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createBreedingRecord() async {
    final BreedingCubit cubit = context.read<BreedingCubit>();
    final BreedingState state = cubit.state;

    if (state.status == BreedingStatus.loading && state.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargement des données de reproduction…'),
        ),
      );
      return;
    }

    if (state.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ajoutez d’abord vos animaux pour créer une saillie.',
          ),
        ),
      );
      return;
    }

    context.go('/events/add-breeding', extra: cubit);
  }

  Future<void> _createHealthOrOtherEvent() async {
    final BreedingCubit breedingCubit = context.read<BreedingCubit>();
    final BreedingState breedingState = breedingCubit.state;

    if (breedingState.status == BreedingStatus.loading &&
        breedingState.animals.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chargement des données')));
      return;
    }

    if (breedingState.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ajoutez d’abord vos animaux pour enregistrer un événement.',
          ),
        ),
      );
      return;
    }

    final List<LivestockEvent>? created = await BatchEventFormDialog.show(
      context,
      animals: breedingState.animals,
      repository: widget.eventRepository,
    );

    if (!mounted || created == null) {
      return;
    }

    await context.read<EventsCubit>().loadEvents();

    if (!mounted || created.isEmpty) {
      return;
    }

    final String message = created.length > 1
        ? 'vénements enregistrés.'
        : 'vénement enregistré.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocListener<BreedingCubit, BreedingState>(
      listener: (BuildContext context, BreedingState state) {
        if (!_hasInitializedBreedingCount) {
          if (state.status == BreedingStatus.success) {
            _hasInitializedBreedingCount = true;
            _lastBreedingRecordCount = state.records.length;
          }
          return;
        }

        if (state.status == BreedingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          return;
        }

        if (state.status == BreedingStatus.success &&
            state.records.length > _lastBreedingRecordCount) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saillie enregistrée.')));
        }

        _lastBreedingRecordCount = state.records.length;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('â°vénements'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
              alpha: 0.7,
            ),
            indicatorColor: theme.colorScheme.onPrimary,
            tabs: const <Widget>[
              Tab(text: 'Reproduction'),
              Tab(text: 'Santé'),
              Tab(text: 'Autres'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const <Widget>[
            ReproductionTabView(),
            HealthTabView(),
            OtherEventsTabView(),
          ],
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (BuildContext context, _) {
            final int index = _tabController.index;
            if (index == 0) {
              return FloatingActionButton.extended(
                onPressed: _createBreedingRecord,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Nouvelle saillie'),
              );
            }
            if (index == 1 || index == 2) {
              return FloatingActionButton.extended(
                onPressed: _createHealthOrOtherEvent,
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Ajouter un événement'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class HealthTabView extends StatelessWidget {
  const HealthTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (BuildContext context, EventsState state) {
        if (state.status == EventsStatus.failure) {
          return _EventsErrorView(
            message:
                state.errorMessage ??
                'Impossible de charger les événements de santé.',
            onRetry: () => context.read<EventsCubit>().loadEvents(),
          );
        }

        final List<LivestockEvent> events = state.healthEvents;
        final bool isLoading =
            (state.status == EventsStatus.initial ||
                state.status == EventsStatus.loading) &&
            events.isEmpty;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (events.isEmpty) {
          return const _EmptyEventsMessage(
            message: 'Aucun événement de santé enregistré pour le moment.',
          );
        }

        return EventTimeline(events: events);
      },
    );
  }
}

class OtherEventsTabView extends StatelessWidget {
  const OtherEventsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (BuildContext context, EventsState state) {
        if (state.status == EventsStatus.failure) {
          return _EventsErrorView(
            message:
                state.errorMessage ??
                'Impossible de charger les autres événements.',
            onRetry: () => context.read<EventsCubit>().loadEvents(),
          );
        }

        final List<LivestockEvent> events = state.otherEvents;
        final bool isLoading =
            (state.status == EventsStatus.initial ||
                state.status == EventsStatus.loading) &&
            events.isEmpty;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (events.isEmpty) {
          return const _EmptyEventsMessage(
            message: 'Aucun autre événement enregistré pour le moment.',
          );
        }

        return EventTimeline(events: events);
      },
    );
  }
}

class _EventsErrorView extends StatelessWidget {
  const _EventsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventsMessage extends StatelessWidget {
  const _EmptyEventsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
