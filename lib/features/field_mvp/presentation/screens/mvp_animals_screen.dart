import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../mvp_demo_controller.dart';
import 'mvp_animal_profile_screen.dart';

class MvpAnimalsScreen extends StatefulWidget {
  const MvpAnimalsScreen({super.key});

  @override
  State<MvpAnimalsScreen> createState() => _MvpAnimalsScreenState();
}

class _MvpAnimalsScreenState extends State<MvpAnimalsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tout';
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
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
        return rabbit.isMale && !rabbit.isSold && !rabbit.isDead;
      case 'Femelles':
        return rabbit.isFemale && !rabbit.isSold && !rabbit.isDead;
      case 'Vendus':
        return rabbit.isSold;
      case 'Morts':
        return rabbit.isDead;
      default:
        return !rabbit.isSold && !rabbit.isDead;
    }
  }

  int _countByFilter(List<MvpRabbit> rabbits, String filter) {
    switch (filter) {
      case 'Mâles':
        return rabbits
            .where((MvpRabbit r) => r.isMale && !r.isSold && !r.isDead)
            .length;
      case 'Femelles':
        return rabbits
            .where((MvpRabbit r) => r.isFemale && !r.isSold && !r.isDead)
            .length;
      case 'Vendus':
        return rabbits.where((MvpRabbit r) => r.isSold).length;
      case 'Morts':
        return rabbits.where((MvpRabbit r) => r.isDead).length;
      default:
        return rabbits.where((MvpRabbit r) => !r.isSold && !r.isDead).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    final MvpDemoController store = MvpDemoScope.of(context);
    final List<MvpRabbit> allRabbits = store.rabbits;
    final List<MvpRabbit> filteredRabbits =
        _filterRabbits(allRabbits).toList();

    final int totalActive =
        allRabbits.where((MvpRabbit r) => !r.isSold && !r.isDead).length;
    final int malesCount = allRabbits
        .where((MvpRabbit r) => r.isMale && !r.isSold && !r.isDead)
        .length;
    final int femalesCount = allRabbits
        .where((MvpRabbit r) => r.isFemale && !r.isSold && !r.isDead)
        .length;
    final int breedersCount = allRabbits
        .where((MvpRabbit r) =>
            r.category == RabbitCategory.breeder && !r.isSold && !r.isDead)
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mes lapins',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _StatCard(
                          icon: Icons.pets,
                          value: totalActive.toString(),
                          label: 'Total',
                          color: Colors.white,
                        ),
                        _StatCard(
                          icon: Icons.male,
                          value: malesCount.toString(),
                          label: 'Mâles',
                          color: Colors.lightBlue.shade100,
                        ),
                        _StatCard(
                          icon: Icons.female,
                          value: femalesCount.toString(),
                          label: 'Femelles',
                          color: Colors.pink.shade100,
                        ),
                        _StatCard(
                          icon: Icons.star,
                          value: breedersCount.toString(),
                          label: 'Repro',
                          color: Colors.amber.shade100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    hintText: 'Rechercher par nom, ID ou cage…',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: AnimatedOpacity(
                      opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filter chips with icons and counts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <_FilterChipData>[
                    _FilterChipData('Tout', Icons.grid_view_rounded, null),
                    _FilterChipData('Mâles', Icons.male, Colors.blue),
                    _FilterChipData('Femelles', Icons.female, Colors.pink),
                    _FilterChipData(
                        'Vendus', Icons.sell_outlined, colors?.success),
                    _FilterChipData(
                        'Morts', Icons.warning_amber_rounded, colors?.warning),
                  ].map((_FilterChipData data) {
                    final bool selected = _selectedFilter == data.label;
                    final int count = _countByFilter(allRabbits, data.label);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: FilterChip(
                          avatar: Icon(
                            data.icon,
                            size: 18,
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : data.color ?? theme.colorScheme.primary,
                          ),
                          label: Text('${data.label} ($count)'),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = data.label),
                          selectedColor: theme.colorScheme.primary,
                          checkmarkColor: theme.colorScheme.onPrimary,
                          labelStyle: TextStyle(
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${filteredRabbits.length} lapin${filteredRabbits.length > 1 ? 's' : ''} trouvé${filteredRabbits.length > 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),

          // List of rabbits
          filteredRabbits.isEmpty
              ? const SliverFillRemaining(child: _EmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final MvpRabbit rabbit = filteredRabbits[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ModernRabbitCard(
                            rabbit: rabbit,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<Widget>(
                                builder: (BuildContext context) =>
                                    MvpAnimalProfileScreen(rabbit: rabbit),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredRabbits.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/quick/new-rabbit'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nouveau'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color? color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernRabbitCard extends StatelessWidget {
  const _ModernRabbitCard({required this.rabbit, this.onTap});

  final MvpRabbit rabbit;
  final VoidCallback? onTap;

  String _getAge() {
    final int days = DateTime.now().difference(rabbit.birthDate).inDays;
    if (days < 30) {
      return '$days jours';
    }
    final int months = days ~/ 30;
    if (months < 12) {
      return '$months mois';
    }
    final int years = months ~/ 12;
    final int remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years an${years > 1 ? 's' : ''}';
    }
    return '$years an${years > 1 ? 's' : ''} $remainingMonths mois';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors? colors = theme.extension<KhodanAppColors>();
    final Color statusColor = rabbit.statusColor(theme);
    final bool isMale = rabbit.isMale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: statusColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                // Avatar with gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        statusColor.withOpacity(0.3),
                        statusColor.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      rabbit.name.isNotEmpty
                          ? rabbit.name[0].toUpperCase()
                          : '🐰',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              rabbit.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (isMale ? Colors.blue : Colors.pink)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  isMale ? Icons.male : Icons.female,
                                  size: 16,
                                  color: isMale ? Colors.blue : Colors.pink,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rabbit.sex,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isMale ? Colors.blue : Colors.pink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rabbit.id} • ${rabbit.cage}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  statusColor.withOpacity(0.2),
                                  statusColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rabbit.status,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Age
                          Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getAge(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Weight
                          Icon(
                            Icons.monitor_weight_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${rabbit.weight} kg',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun lapin trouvé',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par ajouter vos premiers lapins\nen utilisant le bouton ci-dessous',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
