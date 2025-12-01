import 'package:flutter/material.dart';

import '../../../../app/config/theme.dart';
import '../mvp_demo_controller.dart';

class MvpAnimalProfileScreen extends StatelessWidget {
  const MvpAnimalProfileScreen({required this.rabbit, super.key});

  final MvpRabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    final Color statusColor = rabbit.statusColor(theme);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${rabbit.name} (${rabbit.id})'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Infos'),
              Tab(text: 'Repro'),
              Tab(text: 'Santé'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      rabbit.name.isNotEmpty ? rabbit.name[0] : '?',
                      style:
                          theme.textTheme.headlineSmall?.copyWith(color: statusColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rabbit.name,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${rabbit.breed} • ${rabbit.cage}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: <Widget>[
                            Chip(
                              label: Text(
                                rabbit.status,
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: statusColor),
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: statusColor),
                            ),
                            Chip(
                              avatar: Icon(
                                rabbit.sex.toLowerCase().startsWith('m')
                                    ? Icons.male
                                    : Icons.female,
                                size: 18,
                              ),
                              label: Text(rabbit.sex),
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Action rapide',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    ListTile(
                                      leading: const Icon(Icons.sell),
                                      title: const Text('Marquer comme vendu'),
                                      onTap: () => Navigator.of(context).pop(),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.warning,
                                          color: colors?.warning),
                                      title: const Text('Marquer comme mort'),
                                      onTap: () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_horiz),
                        label: const Text('Action'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _InfoTab(rabbit: rabbit),
                  _ReproTab(rabbit: rabbit),
                  _HealthTab(rabbit: rabbit),
                  _NotesTab(rabbit: rabbit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.rabbit});

  final MvpRabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _InfoRow(
          icon: Icons.cake_outlined,
          label: 'Date de naissance',
          value:
              '${rabbit.birthDate.day}/${rabbit.birthDate.month}/${rabbit.birthDate.year}',
        ),
        _InfoRow(
          icon: Icons.scale,
          label: 'Poids',
          value: '${rabbit.weight.toStringAsFixed(1)} kg',
        ),
        _InfoRow(
          icon: Icons.family_restroom,
          label: 'Parents',
          value: [
            if (rabbit.mother != null) 'Mère: ${rabbit.mother}',
            if (rabbit.father != null) 'Père: ${rabbit.father}',
          ].where((String element) => element.isNotEmpty).join(' • '),
        ),
        _InfoRow(
          icon: Icons.home_work_outlined,
          label: 'Cage',
          value: rabbit.cage,
        ),
        const SizedBox(height: 12),
        Text(
          'Notes rapides',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Column(
          children: rabbit.notes.isEmpty
              ? <Widget>[
                  ListTile(
                    leading: const Icon(Icons.edit_note),
                    title: const Text('Aucune note pour le moment'),
                    subtitle:
                        const Text('Ajoutez vos observations pour ce lapin.'),
                    onTap: () {},
                  ),
                ]
              : rabbit.notes
                  .map(
                    (String note) => ListTile(
                      leading: const Icon(Icons.push_pin_outlined),
                      title: Text(note),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _ReproTab extends StatelessWidget {
  const _ReproTab({required this.rabbit});

  final MvpRabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Historique des saillies'),
          subtitle: Text(
            rabbit.reproductionHistory.isEmpty
                ? 'Aucun historique enregistré'
                : '${rabbit.reproductionHistory.length} évènements',
          ),
        ),
        const SizedBox(height: 8),
        ...rabbit.reproductionHistory.map(
          (String history) => Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(history),
              subtitle: const Text('Taux de réussite estimé: 75%'),
            ),
          ),
        ),
        if (rabbit.reproductionHistory.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Icon(Icons.favorite_outline, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Planifiez une saillie depuis le bouton + pour ce lapin.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HealthTab extends StatelessWidget {
  const _HealthTab({required this.rabbit});

  final MvpRabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Vaccins & soins',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (rabbit.health.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Aucun soin enregistré'),
              subtitle: const Text(
                'Renseignez les vaccins et traitements pour suivre la santé.',
              ),
            ),
          )
        else
          ...rabbit.health.map(
            (String record) => Card(
              child: ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(record),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.rabbit});

  final MvpRabbit rabbit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Notes',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (rabbit.notes.isEmpty)
          const ListTile(
            leading: Icon(Icons.edit_note),
            title: Text('Aucune note'),
            subtitle: Text('Ajoutez vos observations terrain ici.'),
          )
        else
          ...rabbit.notes.map(
            (String note) => Card(
              child: ListTile(
                leading: const Icon(Icons.short_text),
                title: Text(note),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Bloc-notes libre (non synchronisé)',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Saisir une observation…',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note sauvegardée localement.')),
            );
          },
          child: const Text('Enregistrer la note'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
