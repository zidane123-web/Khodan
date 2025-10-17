import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/app_env.dart';
import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/constants.dart';
import 'data/local/local_data_sources.dart';
import 'data/local/local_database.dart';
import 'data/repositories/animal_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/breeding_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/species_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/offline_sync_manager.dart';
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
  late final LocalDatabase _localDb;
  late final LocalAnimalDataSource _localAnimalDataSource;
  late final LocalBreedingDataSource _localBreedingDataSource;
  late final LocalEventDataSource _localEventDataSource;
  late final LocalSpeciesDataSource _localSpeciesDataSource;
  late final KhodanRouter _router;

  @override
  void initState() {
    super.initState();
    _localDb = LocalDatabase();
    _localAnimalDataSource = LocalAnimalDataSource(_localDb);
    _localBreedingDataSource = LocalBreedingDataSource(_localDb);
    _localEventDataSource = LocalEventDataSource(_localDb);
    _localSpeciesDataSource = LocalSpeciesDataSource(_localDb);
    _router = KhodanRouter(
      enableAuth: widget.env.hasSupabaseCredentials &&
          !widget.env.useInMemoryRepositories,
    );
  }

  @override
  void dispose() {
    _localDb.close();
    super.dispose();
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
      RepositoryProvider<LocalAnimalDataSource>.value(
        value: _localAnimalDataSource,
      ),
      RepositoryProvider<LocalBreedingDataSource>.value(
        value: _localBreedingDataSource,
      ),
      RepositoryProvider<LocalEventDataSource>.value(
        value: _localEventDataSource,
      ),
      RepositoryProvider<LocalSpeciesDataSource>.value(
        value: _localSpeciesDataSource,
      ),
      RepositoryProvider<AnimalRepository>(
        create: (_) => InMemoryAnimalRepository(),
      ),
      RepositoryProvider<BreedingRepository>(
        create: (_) => InMemoryBreedingRepository(),
      ),
      RepositoryProvider<EventRepository>(
        create: (_) => InMemoryEventRepository(),
      ),
      RepositoryProvider<SpeciesRepository>(
        create: (_) => SyncedSpeciesRepository(
          remote:
              SupabaseSpeciesRepository(apiClient: _apiClient ??= ApiClient()),
          local: _localSpeciesDataSource,
          offlineManager: OfflineSyncManager.instance,
        ),
      ),
    ];
  }

  List<RepositoryProvider<dynamic>> _buildSupabaseProviders() {
    final ApiExecutor apiClient = _apiClient ??= ApiClient();
    final OfflineSyncManager offlineManager = OfflineSyncManager.instance;

    final AnimalRepository remoteAnimal =
        SupabaseAnimalRepository(apiClient: apiClient);
    final BreedingRepository remoteBreeding =
        SupabaseBreedingRepository(apiClient: apiClient);
    final EventRepository remoteEvent =
        SupabaseEventRepository(apiClient: apiClient);
    final SpeciesRepository remoteSpecies =
        SupabaseSpeciesRepository(apiClient: apiClient);

    final AnimalRepository syncedAnimal = SyncedAnimalRepository(
      remote: remoteAnimal,
      local: _localAnimalDataSource,
      offlineManager: offlineManager,
    );
    final BreedingRepository syncedBreeding = SyncedBreedingRepository(
      remote: remoteBreeding,
      local: _localBreedingDataSource,
      offlineManager: offlineManager,
    );
    final EventRepository syncedEvent = SyncedEventRepository(
      remote: remoteEvent,
      local: _localEventDataSource,
      offlineManager: offlineManager,
    );
    final SpeciesRepository syncedSpecies = SyncedSpeciesRepository(
      remote: remoteSpecies,
      local: _localSpeciesDataSource,
      offlineManager: offlineManager,
    );

    return <RepositoryProvider<dynamic>>[
      RepositoryProvider<ApiExecutor>.value(value: apiClient),
      RepositoryProvider<LocalAnimalDataSource>.value(
        value: _localAnimalDataSource,
      ),
      RepositoryProvider<LocalBreedingDataSource>.value(
        value: _localBreedingDataSource,
      ),
      RepositoryProvider<LocalEventDataSource>.value(
        value: _localEventDataSource,
      ),
      RepositoryProvider<LocalSpeciesDataSource>.value(
        value: _localSpeciesDataSource,
      ),
      RepositoryProvider<AnimalRepository>(
        create: (_) => syncedAnimal,
      ),
      RepositoryProvider<BreedingRepository>(
        create: (_) => syncedBreeding,
      ),
      RepositoryProvider<EventRepository>(
        create: (_) => syncedEvent,
      ),
      RepositoryProvider<SpeciesRepository>(
        create: (_) => syncedSpecies,
      ),
    ];
  }
}
