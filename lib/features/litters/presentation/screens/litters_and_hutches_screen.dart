import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/hutch.dart';
import '../../../../data/models/litter.dart';
import '../../../../data/repositories/hutch_repository.dart';
import '../../../../data/repositories/litter_repository.dart';
import '../cubit/hutches_cubit.dart';
import '../cubit/litters_cubit.dart';
import '../widgets/hutches_tab.dart';
import '../widgets/litter_dialogs.dart';
import '../widgets/litters_tab.dart';
import '../widgets/hutch_dialogs.dart';

class LittersAndHutchesScreen extends StatefulWidget {
  const LittersAndHutchesScreen({super.key});

  @override
  State<LittersAndHutchesScreen> createState() => _LittersAndHutchesScreenState();
}

class _LittersAndHutchesScreenState extends State<LittersAndHutchesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LittersCubit>(
          create: (BuildContext context) =>
              LittersCubit(context.read<LitterRepository>())..load(),
        ),
        BlocProvider<HutchesCubit>(
          create: (BuildContext context) => HutchesCubit(
            hutchRepository: context.read<HutchRepository>(),
            litterRepository: context.read<LitterRepository>(),
          )..load(),
        ),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<LittersCubit, LittersState>(
            listenWhen: (LittersState previous, LittersState current) =>
                previous.infoMessage != current.infoMessage ||
                previous.errorMessage != current.errorMessage,
            listener: (BuildContext context, LittersState state) {
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
              if (state.infoMessage != null) {
                messenger.showSnackBar(SnackBar(content: Text(state.infoMessage!)));
              } else if (state.errorMessage != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              context.read<LittersCubit>().acknowledgeMessage();
            },
          ),
          BlocListener<HutchesCubit, HutchesState>(
            listenWhen: (HutchesState previous, HutchesState current) =>
                previous.infoMessage != current.infoMessage ||
                previous.errorMessage != current.errorMessage,
            listener: (BuildContext context, HutchesState state) {
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
              if (state.infoMessage != null) {
                messenger.showSnackBar(SnackBar(content: Text(state.infoMessage!)));
              } else if (state.errorMessage != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              context.read<HutchesCubit>().acknowledgeMessage();
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Portees & clapiers'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const <Tab>[
                Tab(text: 'Portees'),
                Tab(text: 'Clapiers'),
              ],
            ),
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _tabController.animation ?? _tabController,
            builder: (BuildContext context, Widget? child) {
              if (_tabController.index == 0) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    final LitterDraft? draft = await showCreateLitterDialog(context);
                    if (draft != null && context.mounted) {
                      await context.read<LittersCubit>().createLitter(draft);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle portee'),
                );
              }
              return FloatingActionButton.extended(
                onPressed: () async {
                  final HutchDraft? draft = await showCreateHutchDialog(context);
                  if (draft != null && context.mounted) {
                    await context.read<HutchesCubit>().createHutch(draft);
                  }
                },
                icon: const Icon(Icons.home_work_outlined),
                label: const Text('Ajouter un clapier'),
              );
            },
          ),
          body: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              LittersTab(),
              HutchesTab(),
            ],
          ),
        ),
      ),
    );
  }
}
