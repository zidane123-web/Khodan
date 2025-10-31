import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/app_env.dart';
import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/constants.dart';
import 'app/core/logging/diagnostics_service.dart';
import 'l10n/app_localizations.dart';
import 'data/local/local_data_sources.dart';
import 'data/local/local_database.dart';
import 'data/repositories/animal_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/breeding_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/event_template_repository.dart';
import 'data/repositories/food_inventory_repository.dart';
import 'data/repositories/media_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/knowledge_base_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/support_repository.dart';
import 'data/repositories/species_repository.dart';
import 'data/repositories/litter_repository.dart';
import 'data/repositories/hutch_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/connectivity_watcher.dart';
import 'data/services/offline_sync_manager.dart';
import 'data/services/reporting_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await DiagnosticsService.instance.initialize();
      FlutterError.onError = (FlutterErrorDetails details) {
        DiagnosticsService.instance.logError(
          details.exceptionAsString(),
          source: 'flutter',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };

      final AppEnv env = await AppEnv.load();
      if (kDebugMode) {
        debugPrint('App environment: ${env.label}');
      }
      await _initializeSupabase(env);
      if (env.useInMemoryRepositories) {
        _resetInMemoryRepositories();
      }
      runApp(KhodanApp(env: env));
    },
    (Object error, StackTrace stackTrace) {
      unawaited(
        DiagnosticsService.instance.logError(
          'Erreur zone non interceptée',
          source: 'zone',
          error: error,
          stackTrace: stackTrace,
        ),
      );
    },
  );
}

void _resetInMemoryRepositories() {
  InMemoryAnimalRepository.reset();
  InMemoryBreedingRepository.reset();
  InMemoryEventRepository.reset();
  InMemoryLitterRepository.reset();
  InMemoryHutchRepository.reset();
}

Future<void> _initializeSupabase(AppEnv env) async {
  if (!env.hasSupabaseCredentials) {
    debugPrint(
      'Supabase credentials are missing for ${env.label}. Skipping initialization.',
    );
    return;
  }

  await Supabase.initialize(url: env.supabaseUrl, anonKey: env.supabaseAnonKey);
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
  late final LocalAnimalMediaDataSource _localAnimalMediaDataSource;
  late final LocalBreedingDataSource _localBreedingDataSource;
  late final LocalEventDataSource _localEventDataSource;
  late final LocalSpeciesDataSource _localSpeciesDataSource;
  late final LocalEventTemplateDataSource _localEventTemplateDataSource;
  late final LocalFoodTypeDataSource _localFoodTypeDataSource;
  late final LocalFoodStockDataSource _localFoodStockDataSource;
  late final LocalProfileDataSource _localProfileDataSource;
  late final LocalDashboardPreferencesDataSource
  _localDashboardPreferencesDataSource;
  late final LocalSyncQueueDataSource _localQueueDataSource;
  late final KhodanRouter _router;
  ConnectivityWatcher? _connectivityWatcher;

  @override
  void initState() {
    super.initState();
    _localDb = LocalDatabase();
    _localAnimalDataSource = LocalAnimalDataSource(_localDb);
    _localAnimalMediaDataSource = LocalAnimalMediaDataSource(_localDb);
    _localBreedingDataSource = LocalBreedingDataSource(_localDb);
    _localEventDataSource = LocalEventDataSource(_localDb);
    _localSpeciesDataSource = LocalSpeciesDataSource(_localDb);
    _localEventTemplateDataSource = LocalEventTemplateDataSource(_localDb);
    _localFoodTypeDataSource = LocalFoodTypeDataSource(_localDb);
    _localFoodStockDataSource = LocalFoodStockDataSource(_localDb);
    _localProfileDataSource = LocalProfileDataSource(_localDb);
    _localDashboardPreferencesDataSource = LocalDashboardPreferencesDataSource(
      _localDb,
    );
    _localQueueDataSource = LocalSyncQueueDataSource(_localDb);
    OfflineSyncManager.instance.attachQueue(_localQueueDataSource);
    OfflineSyncManager.instance.setHistoryLogger(
      DiagnosticsService.instance.logSync,
    );
    _router = KhodanRouter(
      enableAuth:
          widget.env.hasSupabaseCredentials &&
          !widget.env.useInMemoryRepositories,
    );
    _connectivityWatcher = ConnectivityWatcher();
    unawaited(_connectivityWatcher!.initialize());
  }

  @override
  void dispose() {
    unawaited(_connectivityWatcher?.dispose());
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
        create: (BuildContext context) => AuthCubit(
          AuthRepository(),
          localProfile: context.read<LocalProfileDataSource>(),
        )..listenAuthChanges(),
        child: MaterialApp.router(
          title: AppConstants.appName,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          theme: buildKhodanTheme(),
          routerConfig: _router.router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  List<RepositoryProvider<dynamic>> _buildInMemoryProviders() {
    return <RepositoryProvider<dynamic>>[
      RepositoryProvider<LocalAnimalDataSource>.value(
        value: _localAnimalDataSource,
      ),
      RepositoryProvider<LocalAnimalMediaDataSource>.value(
        value: _localAnimalMediaDataSource,
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
      RepositoryProvider<LocalEventTemplateDataSource>.value(
        value: _localEventTemplateDataSource,
      ),
      RepositoryProvider<LocalFoodTypeDataSource>.value(
        value: _localFoodTypeDataSource,
      ),
      RepositoryProvider<LocalFoodStockDataSource>.value(
        value: _localFoodStockDataSource,
      ),
      RepositoryProvider<LocalProfileDataSource>.value(
        value: _localProfileDataSource,
      ),
      RepositoryProvider<LocalDashboardPreferencesDataSource>.value(
        value: _localDashboardPreferencesDataSource,
      ),
      RepositoryProvider<ProfileRepository>(
        create: (_) => InMemoryProfileRepository(),
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
      RepositoryProvider<LitterRepository>(
        create: (_) => InMemoryLitterRepository(),
      ),
      RepositoryProvider<HutchRepository>(
        create: (_) => InMemoryHutchRepository(),
      ),
      RepositoryProvider<SpeciesRepository>(
        create: (_) => SyncedSpeciesRepository(
          remote: SupabaseSpeciesRepository(
            apiClient: _apiClient ??= ApiClient(),
          ),
          local: _localSpeciesDataSource,
          offlineManager: OfflineSyncManager.instance,
        ),
      ),
      RepositoryProvider<EventTemplateRepository>(
        create: (_) => SyncedEventTemplateRepository(
          remote: SupabaseEventTemplateRepository(
            apiClient: _apiClient ??= ApiClient(),
          ),
          local: _localEventTemplateDataSource,
          offlineManager: OfflineSyncManager.instance,
        ),
      ),
      RepositoryProvider<FoodInventoryRepository>(
        create: (_) => SyncedFoodInventoryRepository(
          remote: SupabaseFoodInventoryRepository(
            apiClient: _apiClient ??= ApiClient(),
          ),
          localTypes: _localFoodTypeDataSource,
          localStock: _localFoodStockDataSource,
          offlineManager: OfflineSyncManager.instance,
        ),
      ),
      RepositoryProvider<MediaRepository>(
        create: (_) => InMemoryMediaRepository(),
      ),
      RepositoryProvider<KnowledgeBaseRepository>(
        create: (_) => InMemoryKnowledgeBaseRepository(),
      ),
      RepositoryProvider<SupportRepository>(
        create: (_) => InMemorySupportRepository(),
      ),
      RepositoryProvider<DashboardRepository>(
        create: (_) => InMemoryDashboardRepository(),
      ),
      RepositoryProvider<ReportingService>(
        create: (BuildContext context) => ReportingService(
          breedingRepository: context.read<BreedingRepository>(),
          animalRepository: context.read<AnimalRepository>(),
          eventRepository: context.read<EventRepository>(),
          inventoryRepository: context.read<FoodInventoryRepository>(),
        ),
      ),
    ];
  }

  List<RepositoryProvider<dynamic>> _buildSupabaseProviders() {
    final ApiExecutor apiClient = _apiClient ??= ApiClient();
    final OfflineSyncManager offlineManager = OfflineSyncManager.instance;

    final AnimalRepository remoteAnimal = SupabaseAnimalRepository(
      apiClient: apiClient,
    );
    final BreedingRepository remoteBreeding = SupabaseBreedingRepository(
      apiClient: apiClient,
    );
    final EventRepository remoteEvent = SupabaseEventRepository(
      apiClient: apiClient,
    );
    final SupabaseMediaRepository remoteMedia = SupabaseMediaRepository(
      apiClient: apiClient,
    );
    final SpeciesRepository remoteSpecies = SupabaseSpeciesRepository(
      apiClient: apiClient,
    );
    final ProfileRepository remoteProfile = SupabaseProfileRepository(
      apiClient: apiClient,
    );
    final SupportRepository remoteSupport = SupabaseSupportRepository(
      apiClient: apiClient,
    );
    final KnowledgeBaseRepository remoteKnowledgeBase =
        SupabaseKnowledgeBaseRepository(apiClient: apiClient);
    final EventTemplateRepository remoteTemplate =
        SupabaseEventTemplateRepository(apiClient: apiClient);
    final FoodInventoryRepository remoteInventory =
        SupabaseFoodInventoryRepository(apiClient: apiClient);

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
    final MediaRepository syncedMedia = SyncedMediaRepository(
      remote: remoteMedia,
      local: _localAnimalMediaDataSource,
      offlineManager: offlineManager,
    );
    final SpeciesRepository syncedSpecies = SyncedSpeciesRepository(
      remote: remoteSpecies,
      local: _localSpeciesDataSource,
      offlineManager: offlineManager,
    );
    final ProfileRepository syncedProfile = SyncedProfileRepository(
      remote: remoteProfile,
      local: _localProfileDataSource,
      offlineManager: offlineManager,
    );
    final SupportRepository syncedSupport = SyncedSupportRepository(
      remote: remoteSupport,
      offlineManager: offlineManager,
    );
    final EventTemplateRepository syncedTemplate =
        SyncedEventTemplateRepository(
          remote: remoteTemplate,
          local: _localEventTemplateDataSource,
          offlineManager: offlineManager,
        );
    final FoodInventoryRepository syncedInventory =
        SyncedFoodInventoryRepository(
          remote: remoteInventory,
          localTypes: _localFoodTypeDataSource,
          localStock: _localFoodStockDataSource,
          offlineManager: offlineManager,
        );
    final DashboardRepository dashboardRepository = SupabaseDashboardRepository(
      localPreferences: _localDashboardPreferencesDataSource,
      apiClient: apiClient,
    );
    final LitterRepository litterRepository = InMemoryLitterRepository();
    final HutchRepository hutchRepository = InMemoryHutchRepository();

    return <RepositoryProvider<dynamic>>[
      RepositoryProvider<ApiExecutor>.value(value: apiClient),
      RepositoryProvider<LocalAnimalDataSource>.value(
        value: _localAnimalDataSource,
      ),
      RepositoryProvider<LocalAnimalMediaDataSource>.value(
        value: _localAnimalMediaDataSource,
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
      RepositoryProvider<LocalEventTemplateDataSource>.value(
        value: _localEventTemplateDataSource,
      ),
      RepositoryProvider<LocalFoodTypeDataSource>.value(
        value: _localFoodTypeDataSource,
      ),
      RepositoryProvider<LocalFoodStockDataSource>.value(
        value: _localFoodStockDataSource,
      ),
      RepositoryProvider<LocalProfileDataSource>.value(
        value: _localProfileDataSource,
      ),
      RepositoryProvider<LocalDashboardPreferencesDataSource>.value(
        value: _localDashboardPreferencesDataSource,
      ),
      RepositoryProvider<AnimalRepository>(create: (_) => syncedAnimal),
      RepositoryProvider<BreedingRepository>(create: (_) => syncedBreeding),
      RepositoryProvider<EventRepository>(create: (_) => syncedEvent),
      RepositoryProvider<LitterRepository>(create: (_) => litterRepository),
      RepositoryProvider<HutchRepository>(create: (_) => hutchRepository),
      RepositoryProvider<SpeciesRepository>(create: (_) => syncedSpecies),
      RepositoryProvider<ProfileRepository>(create: (_) => syncedProfile),
      RepositoryProvider<EventTemplateRepository>(
        create: (_) => syncedTemplate,
      ),
      RepositoryProvider<FoodInventoryRepository>(
        create: (_) => syncedInventory,
      ),
      RepositoryProvider<MediaRepository>(create: (_) => syncedMedia),
      RepositoryProvider<KnowledgeBaseRepository>(
        create: (_) => remoteKnowledgeBase,
      ),
      RepositoryProvider<SupportRepository>(create: (_) => syncedSupport),
      RepositoryProvider<DashboardRepository>(
        create: (_) => dashboardRepository,
      ),
      RepositoryProvider<ReportingService>(
        create: (BuildContext context) => ReportingService(
          breedingRepository: context.read<BreedingRepository>(),
          animalRepository: context.read<AnimalRepository>(),
          eventRepository: context.read<EventRepository>(),
          inventoryRepository: context.read<FoodInventoryRepository>(),
        ),
      ),
    ];
  }
}
