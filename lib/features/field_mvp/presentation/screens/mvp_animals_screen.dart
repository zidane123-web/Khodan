import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../mvp_demo_controller.dart';
import 'mvp_animal_profile_screen.dart';

class MvpAnimalsScreen extends StatefulWidget {
  const MvpAnimalsScreen({super.key});

  @override
  State<MvpAnimalsScreen> createState() => _MvpAnimalsScreenState();
}

class _MvpAnimalsScreenState extends State<MvpAnimalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tout';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Iterable<MvpRabbit> _filterRabbits(List<MvpRabbit> rabbits) sync* {
    for (final MvpRabbit rabbit in rabbits) {
      final bool matchesSearch = _searchTermMatches(rabbit);
      final bool matchesFilter = _filterMatches(rabbit);
      if (matchesSearch && matchesFilter) {
        yield rabbit;
      }
    }
  }

  bool _searchTermMatches(MvpRabbit rabbit) {
    if (_searchController.text.trim().isEmpty) {
      return true;
    }
    final String query = _searchController.text.trim().toLowerCase();
    return rabbit.name.toLowerCase().contains(query) ||
        rabbit.id.toLowerCase().contains(query) ||
        rabbit.cage.toLowerCase().contains(query);
  }

  bool _filterMatches(MvpRabbit rabbit) {
    switch (_selectedFilter) {
      case 'Mâles':
        return rabbit.sex.toLowerCase().startsWith('m');
      case 'Femelles':
        return rabbit.sex.toLowerCase().startsWith('f');
      case 'Vendus':
        return rabbit.isSold;
      case 'Morts':
        return rabbit.isDead;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MvpDemoController store = MvpDemoScope.of(context);
    final List<MvpRabbit> rabbits = _filterRabbits(store.rabbits).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes lapins'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Rechercher par nom ou ID…',
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <String>[
                  'Tout',
                  'Mâles',
                  'Femelles',
                  'Vendus',
                  'Morts',
                ].map((String label) {
                  final bool selected = _selectedFilter == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = label),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: rabbits.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: rabbits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final MvpRabbit rabbit = rabbits[index];
                        return _RabbitCard(
                          rabbit: rabbit,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<Widget>(
                              builder: (BuildContext context) =>
                                  MvpAnimalProfileScreen(rabbit: rabbit),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RabbitCard extends StatelessWidget {
  const _RabbitCard({required this.rabbit, this.onTap});

  final MvpRabbit rabbit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color statusColor = rabbit.statusColor(theme);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: statusColor.withOpacity(0.14),
          child: Text(
            rabbit.name.isNotEmpty ? rabbit.name[0] : '?',
            style: theme.textTheme.titleLarge?.copyWith(color: statusColor),
          ),
        ),
        title: Text('${rabbit.name} - ${rabbit.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text('${rabbit.breed} • ${rabbit.cage}'),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rabbit.status,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  rabbit.sex.toLowerCase().startsWith('m')
                      ? Icons.male
                      : Icons.female,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(rabbit.sex, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.pets, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Ajoutez vos premiers lapins avec le bouton +',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
