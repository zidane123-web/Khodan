// lib/app/config/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/field_mvp/presentation/mvp_demo_controller.dart';
import '../../features/field_mvp/presentation/screens/mvp_animals_screen.dart';
import '../../features/field_mvp/presentation/screens/mvp_dashboard_screen.dart';
import '../../features/field_mvp/presentation/screens/mvp_finances_screen.dart';
import '../../features/field_mvp/presentation/screens/mvp_reproduction_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

class KhodanRouter {
  KhodanRouter()
      : router = GoRouter(
          navigatorKey: _rootNavigatorKey,
          initialLocation: const DashboardRoute().location,
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder: (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return KhodanNavigationShell(
                  navigationShell: navigationShell,
                );
              },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const DashboardRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const MvpDashboardScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const AnimalsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const MvpAnimalsScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const EventsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const MvpReproductionScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const ReportsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const MvpFinancesScreen(),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: const SettingsRoute().path,
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen(),
            ),
          ],
        );

  final GoRouter router;
}

abstract class KhodanRoute {
  const KhodanRoute(this.path);

  final String path;

  String get location => path;
}

class DashboardRoute extends KhodanRoute {
  const DashboardRoute() : super('/dashboard');
}

class AnimalsRoute extends KhodanRoute {
  const AnimalsRoute() : super('/animals');
}

class EventsRoute extends KhodanRoute {
  const EventsRoute() : super('/events');
}

class ReportsRoute extends KhodanRoute {
  const ReportsRoute() : super('/reports');
}

class SettingsRoute extends KhodanRoute {
  const SettingsRoute() : super('/settings');
}

class KhodanNavigationShell extends StatefulWidget {
  const KhodanNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<KhodanNavigationShell> createState() => _KhodanNavigationShellState();
}

class _KhodanNavigationShellState extends State<KhodanNavigationShell> {
  final MvpDemoController _store = MvpDemoController();
  bool _showQuickActions = false;

  List<_NavItem> get _destinations => const <_NavItem>[
        _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Accueil',
        ),
        _NavItem(
          icon: Icons.pets_outlined,
          activeIcon: Icons.pets,
          label: 'Lapins',
        ),
        _NavItem(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          label: 'Repro',
        ),
        _NavItem(
          icon: Icons.payments_outlined,
          activeIcon: Icons.payments,
          label: 'Finances',
        ),
      ];

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  void _selectDestination(int index) {
    setState(() => _showQuickActions = false);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _openNewRabbitForm(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = '';
    String id = '';
    String breed = 'Néo-Zélandais';
    String cage = 'Cage 1';
    String sex = 'Femelle';
    RabbitCategory category = RabbitCategory.breeder;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Nouveau lapin',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nom'),
                  onSaved: (String? value) => name = value?.trim() ?? '',
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ID'),
                  onSaved: (String? value) => id = value?.trim() ?? '',
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Identifiant requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Race'),
                  initialValue: breed,
                  onSaved: (String? value) => breed = value?.trim() ?? breed,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cage'),
                  initialValue: cage,
                  onSaved: (String? value) => cage = value?.trim() ?? cage,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: sex,
                  decoration: const InputDecoration(labelText: 'Sexe'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'Femelle',
                      child: Text('Femelle'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Mâle',
                      child: Text('Mâle'),
                    ),
                  ],
                  onChanged: (String? value) => sex = value ?? 'Femelle',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RabbitCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: const <DropdownMenuItem<RabbitCategory>>[
                    DropdownMenuItem<RabbitCategory>(
                      value: RabbitCategory.breeder,
                      child: Text('Reproducteur'),
                    ),
                    DropdownMenuItem<RabbitCategory>(
                      value: RabbitCategory.growOut,
                      child: Text('Engraissement'),
                    ),
                  ],
                  onChanged: (RabbitCategory? value) =>
                      category = value ?? RabbitCategory.breeder,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      _store.addRabbit(
                        name: name,
                        id: id,
                        sex: sex,
                        breed: breed,
                        cage: cage,
                        category: category,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lapin ajouté.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNewBreedingForm(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final List<MvpRabbit> bucks = _store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('m'))
        .toList();
    final List<MvpRabbit> does = _store.rabbits
        .where((MvpRabbit rabbit) => rabbit.sex.toLowerCase().startsWith('f'))
        .toList();

    MvpRabbit? buck = bucks.isNotEmpty ? bucks.first : null;
    MvpRabbit? doe = does.isNotEmpty ? does.first : null;
    DateTime date = DateTime.now();
    String cage = doe?.cage ?? 'Cage';

    if (buck == null || doe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un mâle et une femelle.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Nouvelle saillie',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MvpRabbit>(
                      value: buck,
                      decoration: const InputDecoration(labelText: 'Mâle'),
                      items: bucks
                          .map(
                            (MvpRabbit rabbit) => DropdownMenuItem<MvpRabbit>(
                              value: rabbit,
                              child: Text('${rabbit.name} (${rabbit.id})'),
                            ),
                          )
                          .toList(),
                      onChanged: (MvpRabbit? value) => setModalState(() => buck = value),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MvpRabbit>(
                      value: doe,
                      decoration: const InputDecoration(labelText: 'Femelle'),
                      items: does
                          .map(
                            (MvpRabbit rabbit) => DropdownMenuItem<MvpRabbit>(
                              value: rabbit,
                              child: Text('${rabbit.name} (${rabbit.id})'),
                            ),
                          )
                          .toList(),
                      onChanged: (MvpRabbit? value) => setModalState(() {
                        doe = value;
                        cage = value?.cage ?? cage;
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Cage'),
                      initialValue: cage,
                      onSaved: (String? value) => cage = value?.trim() ?? cage,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            firstDate:
                                DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                            initialDate: date,
                          );
                          if (picked != null) {
                            setModalState(() => date = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          if (buck != null && doe != null) {
                            _store.addBreedingCycle(
                              buckName: buck!.name,
                              doeName: doe!.name,
                              date: date,
                              cage: cage,
                            );
                          }
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saillie enregistrée.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openFinanceForm(
    BuildContext context, {
    required bool isExpense,
  }) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController labelController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String type = isExpense ? 'Dépense' : 'Vente';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isExpense ? 'Nouvelle dépense' : 'Nouvelle vente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Libellé'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                  validator: (String? value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: <String>[
                    if (isExpense) ...<String>['Dépense', 'Alimentation', 'Santé']
                    else ...<String>['Vente', 'Engraissement', 'Reproducteur'],
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) => type = value ?? type,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final double amount =
                          double.tryParse(amountController.text.trim()) ?? 0;
                      _store.addTransaction(
                        label: labelController.text.trim(),
                        amount: amount,
                        isExpense: isExpense,
                        type: type,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isExpense ? 'Dépense ajoutée.' : 'Vente enregistrée.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleQuickActions() {
    setState(() => _showQuickActions = !_showQuickActions);
  }

  void _closeQuickActions() {
    if (_showQuickActions) {
      setState(() => _showQuickActions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return MvpDemoScope(
      notifier: _store,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: <Widget>[
            widget.navigationShell,
            if (_showQuickActions)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeQuickActions,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showQuickActions ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showQuickActions,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _QuickActionChip(
                        icon: Icons.pets,
                        label: 'Nouveau lapin',
                        color: theme.colorScheme.primary,
                        onTap: () {
                          _toggleQuickActions();
                          _openNewRabbitForm(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickActionChip(
                        icon: Icons.favorite,
                        label: 'Nouvelle saillie',
                        color: theme.colorScheme.secondary,
                        onTap: () {
                          _toggleQuickActions();
                          _openNewBreedingForm(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickActionChip(
                        icon: Icons.shopping_bag,
                        label: 'Dépense',
                        color: theme.colorScheme.error,
                        onTap: () {
                          _toggleQuickActions();
                          _openFinanceForm(context, isExpense: true);
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickActionChip(
                        icon: Icons.sell,
                        label: 'Vente',
                        color: theme.colorScheme.tertiary,
                        onTap: () {
                          _toggleQuickActions();
                          _openFinanceForm(context, isExpense: false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < 2; i++)
                  Expanded(
                    child: _BottomBarItem(
                      item: _destinations[i],
                      selected: widget.navigationShell.currentIndex == i,
                      onTap: () => _selectDestination(i),
                    ),
                  ),
                const SizedBox(width: 48),
                for (int i = 2; i < _destinations.length; i++)
                  Expanded(
                    child: _BottomBarItem(
                      item: _destinations[i],
                      selected: widget.navigationShell.currentIndex == i,
                      onTap: () => _selectDestination(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleQuickActions,
          child: Icon(_showQuickActions ? Icons.close : Icons.add),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color =
        selected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(selected ? item.activeIcon : item.icon, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: color.withOpacity(0.16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
