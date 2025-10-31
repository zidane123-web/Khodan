// lib/app/config/router.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/animals/presentation/screens/animal_list_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/email_confirmation_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/litters/presentation/screens/litters_and_hutches_screen.dart';
import '../../features/events/presentation/screens/add_breeding_record_screen.dart';
import '../../features/events/presentation/screens/add_event_screen.dart';
import '../../features/events/presentation/cubit/breeding_cubit.dart';
import '../../features/planning/presentation/screens/planning_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_about_screen.dart';
import '../../features/settings/presentation/screens/settings_contact_support_screen.dart';
import '../../features/settings/presentation/screens/settings_knowledge_base_screen.dart';
import '../../features/settings/presentation/screens/settings_logs_screen.dart';
import '../../features/settings/presentation/screens/settings_personalization_screen.dart';
import '../../features/settings/presentation/screens/settings_profile_screen.dart';
import '../../features/settings/presentation/screens/settings_referentials_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../data/models/animal.dart';
import '../../l10n/app_localizations.dart';
import '../core/widgets/khodan_placeholder_screen.dart';
import '../presentation/shell/khodan_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

class KhodanRouter {
  KhodanRouter({required bool enableAuth})
    : router = GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: const SplashRoute().location,
        refreshListenable: enableAuth
            ? GoRouterRefreshStream(
                Supabase.instance.client.auth.onAuthStateChange,
              )
            : null,
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
          GoRoute(
            path: const EmailConfirmationRoute().path,
            builder: (BuildContext context, GoRouterState state) {
              final Object? extra = state.extra;
              final String emailFromExtra = extra is String ? extra : '';
              final String emailFromQuery =
                  state.uri.queryParameters['email'] ?? '';
              final String email = emailFromExtra.isNotEmpty
                  ? emailFromExtra
                  : emailFromQuery;
              return EmailConfirmationScreen(email: email);
            },
          ),
          StatefulShellRoute.indexedStack(
            builder:
                (
                  BuildContext context,
                  GoRouterState state,
                  StatefulNavigationShell navigationShell,
                ) {
                  final AppLocalizations l10n = AppLocalizations.of(context);
                  return KhodanShell(
                    navigationShell: navigationShell,
                    destinations: <KhodanShellDestination>[
                      KhodanShellDestination(
                        label: l10n.navDashboard,
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard,
                      ),
                      KhodanShellDestination(
                        label: l10n.navAnimals,
                        icon: Icons.pets_outlined,
                        selectedIcon: Icons.pets,
                      ),
                      KhodanShellDestination(
                        label: l10n.navEvents,
                        icon: Icons.volunteer_activism_outlined,
                        selectedIcon: Icons.volunteer_activism,
                      ),
                      KhodanShellDestination(
                        label: l10n.navReports,
                        icon: Icons.bar_chart_outlined,
                        selectedIcon: Icons.bar_chart,
                      ),
                      KhodanShellDestination(
                        label: l10n.navSettings,
                        icon: Icons.settings_outlined,
                        selectedIcon: Icons.settings,
                      ),
                    ],
                    moreDestinations: <KhodanShellExtraDestination>[
                      KhodanShellExtraDestination(
                        route: const PlanningRoute().location,
                        label: l10n.navPlanning,
                        description: l10n.navPlanningDescription,
                        icon: Icons.event_note_outlined,
                      ),
                      KhodanShellExtraDestination(
                        route: const NotificationsRoute().location,
                        label: l10n.navNotifications,
                        description: l10n.navNotificationsDescription,
                        icon: Icons.notifications_none_outlined,
                      ),
                      KhodanShellExtraDestination(
                        route: const SettingsKnowledgeBaseRoute().location,
                        label: l10n.navHelpCenter,
                        description: l10n.navHelpCenterDescription,
                        icon: Icons.help_outline,
                      ),
                    ],
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
                        const LittersAndHutchesScreen(),
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
                          List<Animal>? animals;
                          String? category;

                          if (extra is Map) {
                            final Object? list = extra['animals'];
                            final Object? cat = extra['category'];
                            if (list is List<Animal>) animals = list;
                            if (cat is String) category = cat;
                          }

                          // Try to fallback to breeding cubit animals if not provided
                          animals ??= () {
                            try {
                              final BreedingCubit cubit = context
                                  .read<BreedingCubit>();
                              return cubit.state.animals;
                            } catch (_) {
                              return <Animal>[];
                            }
                          }();

                          return AddEventScreen(
                            animals: animals,
                            category: category,
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
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'referentials',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsReferentialsScreen(),
                      ),
                      GoRoute(
                        path: 'personalization',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsPersonalizationScreen(),
                      ),
                      GoRoute(
                        path: 'profile',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsProfileScreen(),
                      ),
                      GoRoute(
                        path: 'support/knowledge',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsKnowledgeBaseScreen(),
                      ),
                      GoRoute(
                        path: 'support/contact',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsContactSupportScreen(),
                      ),
                      GoRoute(
                        path: 'support/logs',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsLogsScreen(),
                      ),
                      GoRoute(
                        path: 'support/about',
                        builder: (BuildContext context, GoRouterState state) =>
                            const SettingsAboutScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: const PlanningRoute().path,
            builder: (BuildContext context, GoRouterState state) {
              return const PlanningScreen();
            },
          ),
          GoRoute(
            path: const NotificationsRoute().path,
            builder: (BuildContext context, GoRouterState state) {
              final AppLocalizations l10n = AppLocalizations.of(context);
              return KhodanPlaceholderScreen(
                title: l10n.placeholderNotificationsTitle,
                message: l10n.placeholderNotificationsMessage,
                icon: Icons.notifications,
              );
            },
          ),
        ],
        redirect: enableAuth ? _redirectWithAuth : null,
      );

  final GoRouter router;

  static String? _redirectWithAuth(BuildContext context, GoRouterState state) {
    final Session? session = Supabase.instance.client.auth.currentSession;
    final bool hasSession = session != null;
    final String path = state.uri.path;

    final bool isAuthRoute =
        path == const LoginRoute().path ||
        path == const EmailConfirmationRoute().path;
    final bool isSplashRoute = path == const SplashRoute().path;

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
  }
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

class EmailConfirmationRoute extends KhodanRoute {
  const EmailConfirmationRoute() : super('/auth/confirm');
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

class SettingsReferentialsRoute extends KhodanRoute {
  const SettingsReferentialsRoute() : super('/settings/referentials');
}

class SettingsPersonalizationRoute extends KhodanRoute {
  const SettingsPersonalizationRoute() : super('/settings/personalization');
}

class SettingsProfileRoute extends KhodanRoute {
  const SettingsProfileRoute() : super('/settings/profile');
}

class SettingsKnowledgeBaseRoute extends KhodanRoute {
  const SettingsKnowledgeBaseRoute() : super('/settings/support/knowledge');
}

class SettingsContactSupportRoute extends KhodanRoute {
  const SettingsContactSupportRoute() : super('/settings/support/contact');
}

class SettingsLogsRoute extends KhodanRoute {
  const SettingsLogsRoute() : super('/settings/support/logs');
}

class SettingsAboutRoute extends KhodanRoute {
  const SettingsAboutRoute() : super('/settings/support/about');
}

class PlanningRoute extends KhodanRoute {
  const PlanningRoute() : super('/planning');
}

class NotificationsRoute extends KhodanRoute {
  const NotificationsRoute() : super('/notifications');
}
