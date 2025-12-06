// lib/app/config/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/animals/presentation/screens/animal_list_screen.dart';
import '../../features/animals/presentation/models/animal_quick_filter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/events/presentation/screens/events_hub_screen.dart';
import '../../features/animals/presentation/screens/animal_form_screen.dart';
import '../../features/events/presentation/screens/breeding_form_screen.dart';
import '../../features/finances/presentation/screens/finances_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

class KhodanRouter {
  KhodanRouter()
      : router = GoRouter(
          navigatorKey: _rootNavigatorKey,
          initialLocation: const DashboardRoute().location,
          redirect: (BuildContext context, GoRouterState state) {
            final bool isLoggedIn = 
                Supabase.instance.client.auth.currentUser != null;
            final bool isOnLogin = state.matchedLocation == const LoginRoute().location;
            
            // If not logged in and not on login page, redirect to login
            if (!isLoggedIn && !isOnLogin) {
              return const LoginRoute().location;
            }
            
            // If logged in and on login page, redirect to dashboard
            if (isLoggedIn && isOnLogin) {
              return const DashboardRoute().location;
            }
            
            return null; // No redirect
          },
          routes: <RouteBase>[
            // Login route (outside shell)
            GoRoute(
              path: const LoginRoute().path,
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
            // Main app shell (requires auth)
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
                          const DashboardScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const AnimalsRoute().path,
                      builder: (BuildContext context, GoRouterState state) {
                        final Object? extra = state.extra;
                        return AnimalListScreen(
                          quickFilter: extra is AnimalQuickFilter ? extra : null,
                        );
                      },
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const EventsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const EventsHubScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const ReportsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const FinancesScreen(),
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

class LoginRoute extends KhodanRoute {
  const LoginRoute() : super('/login');
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

  void _selectDestination(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _openNewRabbitForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AnimalFormScreen(),
      ),
    );
  }

  Future<void> _openNewBreedingForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const BreedingFormScreen(),
      ),
    );
  }

  Future<void> _openFinanceForm(
    BuildContext context, {
    required bool isExpense,
  }) async {
    // TODO: Implement real finance form when available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isExpense
              ? 'Fonctionnalité dépenses à venir'
              : 'Fonctionnalité ventes à venir',
        ),
      ),
    );
  }

  Future<void> _openQuickActionsModal(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final BuildContext rootContext = context;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Actions rapides',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        _QuickActionChip(
                          icon: Icons.pets,
                          label: 'Nouveau lapin',
                          color: theme.colorScheme.primary,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openNewRabbitForm(rootContext);
                          },
                        ),
                        _QuickActionChip(
                          icon: Icons.favorite,
                          label: 'Nouvelle saillie',
                          color: theme.colorScheme.secondary,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openNewBreedingForm(rootContext);
                          },
                        ),
                        _QuickActionChip(
                          icon: Icons.shopping_bag,
                          label: 'Dépense',
                          color: theme.colorScheme.error,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openFinanceForm(rootContext, isExpense: true);
                          },
                        ),
                        _QuickActionChip(
                          icon: Icons.sell,
                          label: 'Vente',
                          color: theme.colorScheme.tertiary,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _openFinanceForm(rootContext, isExpense: false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PageRoute<T> _slideRoute<T>(Widget child) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (
        _,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final Animation<Offset> offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ));
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double navHeight = kBottomNavigationBarHeight + bottomPadding + 8;
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: theme.colorScheme.surface,
        child: SizedBox(
          height: navHeight,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openQuickActionsModal(context),
        child: const Icon(Icons.add),
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
      child: Center(
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
    final BorderRadius radius = BorderRadius.circular(24);
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: radius,
            border: Border.all(color: color.withOpacity(0.24)),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
