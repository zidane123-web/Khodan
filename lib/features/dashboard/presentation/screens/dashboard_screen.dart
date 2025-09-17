import 'package:flutter/material.dart';

import '../widgets/kpi_card.dart';
import '../widgets/tasks_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma journée'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Text('Indicateurs clés', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      KpiCard(
                        title: 'Animaux actifs',
                        value: '128',
                        icon: Icons.pets,
                        subtitle: '+5 cette semaine',
                      ),
                      KpiCard(
                        title: 'Taux de réussite repro',
                        value: '82%',
                        icon: Icons.favorite_outline,
                      ),
                      KpiCard(
                        title: 'Portées en cours',
                        value: '12',
                        icon: Icons.nest_cam_wired_stand,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const TasksList(
                    title: 'Aujourd’hui',
                    tasks: <String>[
                      'Vérifier la gestation de F08',
                      'Enregistrer la pesée hebdo de M12',
                    ],
                  ),
                  const TasksList(
                    title: 'À venir',
                    tasks: <String>[
                      'Sevrer la portée de F12 (dans 2 jours)',
                      'Rappel vaccin lapereaux lot B',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouvel événement'),
      ),
    );
  }
}
