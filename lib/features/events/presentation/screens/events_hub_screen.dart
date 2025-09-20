import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/breeding_record.dart';
import '../../../../data/models/event.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../cubit/breeding_cubit.dart';
import '../widgets/event_timeline.dart';
import '../widgets/breeding_record_form.dart';
import '../widgets/reproduction_tab.dart';

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
          content: Text('Chargement des données de reproduction…'),
        ),
      );
      return;
    }

    if (state.animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d’abord vos animaux pour créer une saillie.'),
        ),
      );
      return;
    }

    final BreedingRecord? record = await BreedingRecordFormDialog.show(
      context,
      animals: state.animals,
    );

    if (!mounted || record == null) {
      return;
    }

    await cubit.addRecord(record);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saillie enregistrée.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor:
              theme.colorScheme.onPrimary.withOpacity(0.7),
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
          _EventsTab(category: 'Santé'),
          _EventsTab(category: 'Autres'),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (BuildContext context, Widget? child) {
          if (_tabController.index != 0) {
            return const SizedBox.shrink();
          }
          return child!;
        },
        child: FloatingActionButton.extended(
          onPressed: _createBreedingRecord,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Nouvelle saillie'),
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
