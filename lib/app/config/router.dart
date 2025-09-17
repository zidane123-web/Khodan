import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/animals/presentation/screens/animal_list_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/events/presentation/screens/events_hub_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
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
            GoRoute(
              path: const LoginRoute().path,
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
            ),
            StatefulShellRoute.indexedStack(
              builder: (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return KhodanNavigationShell(navigationShell: navigationShell);
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
                      builder: (BuildContext context, GoRouterState state) =>
                          const AnimalListScreen(),
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
                          const ReportsScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: const SettingsRoute().path,
                      builder: (BuildContext context, GoRouterState state) =>
                          const SettingsScreen(),
                    ),
                  ],
                ),
              ],
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

class LoginRoute extends KhodanRoute {
  const LoginRoute() : super('/auth/login');
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

class KhodanNavigationShell extends StatelessWidget {
  const KhodanNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Tableau de Bord',
    ),
    NavigationDestination(
      icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets),
      label: 'Animaux',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note),
      label: 'Événements',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Rapports',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Paramètres',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        onDestinationSelected: navigationShell.goBranch,
      ),
    );
  }
}
