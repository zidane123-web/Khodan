import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../cubit/animal_cubit.dart';
import '../widgets/animal_card.dart';
import 'animal_detail_screen.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalCubit>(
      create: (BuildContext context) =>
          AnimalCubit(SupabaseAnimalRepository())..fetchAnimals(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes animaux'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<AnimalCubit, AnimalState>(
          builder: (BuildContext context, AnimalState state) {
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
            if (animals.isEmpty) {
              return const _EmptyAnimalsPlaceholder();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: animals.length,
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
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _EmptyAnimalsPlaceholder extends StatelessWidget {
  const _EmptyAnimalsPlaceholder();

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
              'Ajoutez vos premiers animaux pour suivre votre cheptel.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
