import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/app_env.dart';
import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/constants.dart';
import 'data/repositories/animal_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/breeding_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/services/api_client.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppEnv env = await AppEnv.load();
  if (kDebugMode) {
    debugPrint('App environment: ${env.label}');
  }
  await _initializeSupabase(env);
  if (env.useInMemoryRepositories) {
    _resetInMemoryRepositories();
  }
  runApp(KhodanApp(env: env));
}

void _resetInMemoryRepositories() {
  InMemoryAnimalRepository.reset();
  InMemoryBreedingRepository.reset();
  InMemoryEventRepository.reset();
}

Future<void> _initializeSupabase(AppEnv env) async {
  if (!env.hasSupabaseCredentials) {
    debugPrint(
      'Supabase credentials are missing for ${env.label}. Skipping initialization.',
    );
    return;
  }

  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );
}

class KhodanApp extends StatefulWidget {
  const KhodanApp({required this.env, super.key});

  final AppEnv env;

  @override
  State<KhodanApp> createState() => _KhodanAppState();
}

class _KhodanAppState extends State<KhodanApp> {
  Key _appKey = UniqueKey();
  ApiExecutor? _apiClient;
  late final KhodanRouter _router;

  @override
  void initState() {
    super.initState();
    _router = KhodanRouter(
      enableAuth: widget.env.hasSupabaseCredentials &&
          !widget.env.useInMemoryRepositories,
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode && widget.env.useInMemoryRepositories) {
      _resetInMemoryRepositories();
      setState(() {
        _appKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<RepositoryProvider<dynamic>> repositoryProviders =
        widget.env.useInMemoryRepositories
            ? _buildInMemoryProviders()
            : _buildSupabaseProviders();

    return MultiRepositoryProvider(
      key: _appKey,
      providers: repositoryProviders,
      child: BlocProvider<AuthCubit>(
        create: (BuildContext context) => AuthCubit(AuthRepository()),
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: buildKhodanTheme(),
          routerConfig: _router.router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('fr'),
            // Add more locales here if needed.
          ],
        ),
      ),
    );
  }

  List<RepositoryProvider<dynamic>> _buildInMemoryProviders() {
    return <RepositoryProvider<dynamic>>[
      RepositoryProvider<AnimalRepository>(
        create: (_) => InMemoryAnimalRepository(),
      ),
      RepositoryProvider<BreedingRepository>(
        create: (_) => InMemoryBreedingRepository(),
      ),
      RepositoryProvider<EventRepository>(
        create: (_) => InMemoryEventRepository(),
      ),
    ];
  }

  List<RepositoryProvider<dynamic>> _buildSupabaseProviders() {
    final ApiExecutor apiClient = _apiClient ??= ApiClient();
    return <RepositoryProvider<dynamic>>[
      RepositoryProvider<ApiExecutor>.value(value: apiClient),
      RepositoryProvider<AnimalRepository>(
        create: (_) => SupabaseAnimalRepository(apiClient: apiClient),
      ),
      RepositoryProvider<BreedingRepository>(
        create: (_) => SupabaseBreedingRepository(apiClient: apiClient),
      ),
      RepositoryProvider<EventRepository>(
        create: (_) => SupabaseEventRepository(apiClient: apiClient),
      ),
    ];
  }
}
