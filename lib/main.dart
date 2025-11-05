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
import 'data/repositories/task_template_repository.dart';
import 'data/repositories/health_repository.dart';
import 'data/repositories/finance_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/connectivity_watcher.dart';
import 'data/services/pedigree_service.dart';
import 'data/services/offline_sync_manager.dart';
import 'features/reports/services/reports_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/notifications/services/local_notification_service.dart';

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
  late final LocalTaskTemplateDataSource _localTaskTemplateDataSource;
  late final LocalTaskTemplateAssignmentDataSource
      _localTaskTemplateAssignmentDataSource;
  late final LocalAilmentDataSource _localAilmentDataSource;
  late final LocalHealthRecordDataSource _localHealthRecordDataSource;
  late final LocalLitterDataSource _localLitterDataSource;
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
    _localTaskTemplateDataSource = LocalTaskTemplateDataSource(_localDb);
    _localTaskTemplateAssignmentDataSource =
        LocalTaskTemplateAssignmentDataSource(_localDb);
    _localAilmentDataSource = LocalAilmentDataSource(_localDb);
    _localHealthRecordDataSource = LocalHealthRecordDataSource(_localDb);
    _localLitterDataSource = LocalLitterDataSource(_localDb);
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
    unawaited(LocalNotificationService.instance.initialize());
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
      RepositoryProvider<LocalTaskTemplateDataSource>.value(
        value: _localTaskTemplateDataSource,
      ),
      RepositoryProvider<LocalTaskTemplateAssignmentDataSource>.value(
        value: _localTaskTemplateAssignmentDataSource,
      ),
      RepositoryProvider<LocalAilmentDataSource>.value(
        value: _localAilmentDataSource,
      ),
      RepositoryProvider<LocalHealthRecordDataSource>.value(
        value: _localHealthRecordDataSource,
      ),
      RepositoryProvider<LocalLitterDataSource>.value(
        value: _localLitterDataSource,
      ),
      RepositoryProvider<LocalLitterDataSource>.value(
        value: _localLitterDataSource,
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
      RepositoryProvider<TaskTemplateRepository>(
        create: (_) => InMemoryTaskTemplateRepository(),
      ),
      RepositoryProvider<HealthRepository>(
        create: (_) => InMemoryHealthRepository(),
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
      RepositoryProvider<FinanceRepository>(
        create: (_) => InMemoryFinanceRepository(),
      ),
      RepositoryProvider<ReportsService>(
        create: (BuildContext context) => ReportsService(
          apiClient: context.read<ApiExecutor>(),
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
    final LitterRepository remoteLitter = SupabaseLitterRepository(
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
    final TaskTemplateRepository remoteTaskTemplates =
        SupabaseTaskTemplateRepository(apiClient: apiClient);
    final HealthRepository remoteHealth = SupabaseHealthRepository(
      apiClient: apiClient,
    );
    final FinanceRepository remoteFinance = SupabaseFinanceRepository(
      apiClient: apiClient,
    );

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
    final LitterRepository syncedLitter = SyncedLitterRepository(
      remote: remoteLitter,
      local: _localLitterDataSource,
      offlineManager: offlineManager,
    );
    final HealthRepository syncedHealth = SyncedHealthRepository(
      remote: remoteHealth,
      localAilments: _localAilmentDataSource,
      localRecords: _localHealthRecordDataSource,
      eventRepository: syncedEvent,
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
    final TaskTemplateRepository syncedTaskTemplates =
        SyncedTaskTemplateRepository(
          remote: remoteTaskTemplates,
          localTemplates: _localTaskTemplateDataSource,
          localAssignments: _localTaskTemplateAssignmentDataSource,
          offlineManager: offlineManager,
        );
    final DashboardRepository dashboardRepository = SupabaseDashboardRepository(
      localPreferences: _localDashboardPreferencesDataSource,
      apiClient: apiClient,
    );
    final PedigreeService pedigreeService = PedigreeService(
      apiClient: apiClient,
    );
    final LitterRepository litterRepository = syncedLitter;
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
      RepositoryProvider<LocalTaskTemplateDataSource>.value(
        value: _localTaskTemplateDataSource,
      ),
      RepositoryProvider<LocalTaskTemplateAssignmentDataSource>.value(
        value: _localTaskTemplateAssignmentDataSource,
      ),
      RepositoryProvider<LocalAilmentDataSource>.value(
        value: _localAilmentDataSource,
      ),
      RepositoryProvider<LocalHealthRecordDataSource>.value(
        value: _localHealthRecordDataSource,
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
      RepositoryProvider<TaskTemplateRepository>(
        create: (_) => syncedTaskTemplates,
      ),
      RepositoryProvider<FoodInventoryRepository>(
        create: (_) => syncedInventory,
      ),
      RepositoryProvider<HealthRepository>(
        create: (_) => syncedHealth,
      ),
      RepositoryProvider<MediaRepository>(create: (_) => syncedMedia),
      RepositoryProvider<KnowledgeBaseRepository>(
        create: (_) => remoteKnowledgeBase,
      ),
      RepositoryProvider<SupportRepository>(create: (_) => syncedSupport),
      RepositoryProvider<DashboardRepository>(
        create: (_) => dashboardRepository,
      ),
      RepositoryProvider<FinanceRepository>(
        create: (_) => remoteFinance,
      ),
      RepositoryProvider<ReportsService>(
        create: (BuildContext context) => ReportsService(
          apiClient: context.read<ApiExecutor>(),
        ),
      ),
      RepositoryProvider<PedigreeService>(
        create: (_) => pedigreeService,
      ),
    ];
  }
}
