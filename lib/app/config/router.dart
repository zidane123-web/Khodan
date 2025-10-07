// lib/app/config/router.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/animals/presentation/screens/animal_list_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/events/presentation/screens/events_hub_screen.dart';
import '../../features/events/presentation/screens/add_breeding_record_screen.dart';
import '../../features/events/presentation/screens/add_event_screen.dart';
import '../../features/events/presentation/cubit/breeding_cubit.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../data/models/animal.dart';
import '../../data/repositories/event_repository.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

class KhodanRouter {
  KhodanRouter()
    : router = GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: const SplashRoute().location,
        refreshListenable: GoRouterRefreshStream(
          Supabase.instance.client.auth.onAuthStateChange,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: const SplashRoute().path,
            builder: (BuildContext context, GoRouterState state) =>
                const SplashScreen(),
          ),
          GoRoute(
            path: const LoginRoute().path,
            builder: (BuildContext context, GoRouterState state) =>
                const LoginScreen(),
          ),
          StatefulShellRoute.indexedStack(
            builder:
                (
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
                      // The local Animals screen doesn't support quickFilter param.
                      return const AnimalListScreen();
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
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'add-breeding',
                        builder: (BuildContext context, GoRouterState state) {
                          final Object? extra = state.extra;
                          BreedingCubit? breedingCubit = extra is BreedingCubit
                              ? extra
                              : null;
                          if (breedingCubit == null) {
                            try {
                              breedingCubit = context.read<BreedingCubit>();
                            } catch (_) {}
                          }
                          if (breedingCubit == null) {
                            return const AddBreedingRecordScreen();
                          }
                          return BlocProvider.value(
                            value: breedingCubit,
                            child: const AddBreedingRecordScreen(),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'add-event',
                        builder: (BuildContext context, GoRouterState state) {
                          final Object? extra = state.extra;
                          EventRepository? repository;
                          List<Animal>? animals;

                          if (extra is Map) {
                            final Object? repo = extra['repository'];
                            final Object? list = extra['animals'];
                            if (repo is EventRepository) repository = repo;
                            if (list is List<Animal>) animals = list;
                          }

                          repository ??= InMemoryEventRepository();

                          // Try to fallback to breeding cubit animals if not provided
                          animals ??= () {
                            try {
                              final BreedingCubit cubit = context.read<BreedingCubit>();
                              return cubit.state.animals;
                            } catch (_) {
                              return <Animal>[];
                            }
                          }();

                          return AddEventScreen(
                            animals: animals,
                            repository: repository,
                          );
                        },
                      ),
                    ],
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
        redirect: (BuildContext context, GoRouterState state) {
          final Session? session = Supabase.instance.client.auth.currentSession;
          final bool hasSession = session != null;
          final String location = state.uri.toString();

          final bool isAuthRoute = location == const LoginRoute().location;
          final bool isSplashRoute = location == const SplashRoute().location;

          if (isSplashRoute) {
            return hasSession
                ? const DashboardRoute().location
                : const LoginRoute().location;
          }

          if (!hasSession) {
            return isAuthRoute ? null : const LoginRoute().location;
          }

          if (isAuthRoute) {
            return const DashboardRoute().location;
          }

          return null;
        },
      );

  final GoRouter router;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract class KhodanRoute {
  const KhodanRoute(this.path);

  final String path;

  String get location => path;
}

class SplashRoute extends KhodanRoute {
  const SplashRoute() : super('/');
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
  const KhodanNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
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
