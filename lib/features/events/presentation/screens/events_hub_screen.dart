import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khodan/data/models/breeding_record.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/features/events/presentation/cubit/breeding_cubit.dart';
import 'package:khodan/features/events/presentation/widgets/event_timeline.dart';
import 'package:khodan/features/events/presentation/widgets/batch_event_form_dialog.dart';
import 'package:khodan/features/events/presentation/widgets/reproduction_tab.dart';
import 'package:khodan/features/events/presentation/screens/add_breeding_record_screen.dart';

class EventsHubScreen extends StatelessWidget {
  const EventsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BreedingCubit>(
      create: (BuildContext context) =>
          BreedingCubit(InMemoryBreedingRepository(), InMemoryAnimalRepository())
            ..loadData(),
      child: const _EventsHubView(),
    );
  }
}

class _EventsHubView extends StatefulWidget {
  const _EventsHubView();

  @override
  State<_EventsHubView> createState() => _EventsHubViewState();
}

class _EventsHubViewState extends State<_EventsHubView>
    with SingleTickerProviderStateMixin {
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

    if (state.status == BreedingStatus.loading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargement des donnees de reproduction...'),
        ),
      );
      return;
    }

    if (state.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajoutez d'abord vos animaux pour creer une saillie."),
        ),
      );
      return;
    }

    final BreedingRecord? record = await Navigator.of(context).push<BreedingRecord>(
      MaterialPageRoute<BreedingRecord>(
        builder: (_) => AddBreedingRecordScreen(
          animals: state.animals,
        ),
      ),
    );

    if (!mounted || record == null) {
      return;
    }

    await cubit.addRecord(record);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saillie enregistree.')),
    );
  }

  Future<void> _createGeneralEvent() async {
    final BreedingCubit cubit = context.read<BreedingCubit>();
    final BreedingState state = cubit.state;

    if (state.status == BreedingStatus.loading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargement des donnees...'),
        ),
      );
      return;
    }

    if (state.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajoutez d'abord vos animaux pour creer un evenement."),
        ),
      );
      return;
    }

    final List<LivestockEvent>? created = await BatchEventFormDialog.show(
      context,
      animals: state.animals,
      repository: InMemoryEventRepository(),
    );

    if (!mounted || created == null || created.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created.length > 1
              ? '${created.length} evenements enregistres.'
              : 'Evenement enregistre.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evenements'),
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Reproduction'),
            Tab(text: 'Sante'),
            Tab(text: 'Autres'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          ReproductionTabView(),
          _EventsTab(category: 'Sante'),
          _EventsTab(category: 'Autres'),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (BuildContext context, Widget? child) {
          return child!;
        },
        child: Builder(
          builder: (BuildContext context) {
            if (_tabController.index == 0) {
              return FloatingActionButton.extended(
                onPressed: _createBreedingRecord,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Nouvelle saillie'),
              );
            }
            return FloatingActionButton.extended(
              onPressed: _createGeneralEvent,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Nouvel evenement'),
            );
          },
        ),
      ),
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({
    required this.category,
  });

  final String category;

  List<LivestockEvent> _demoEventsForCategory() {
    return <LivestockEvent>[
      LivestockEvent(
        id: 'demo-$category-1',
        profileId: 'demo',
        eventType: category == 'Reproduction' ? 'Mise bas' : 'Vaccin',
        eventDate: DateTime.now().subtract(const Duration(days: 2)),
        details: const <String, dynamic>{},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return EventTimeline(events: _demoEventsForCategory());
  }
}









