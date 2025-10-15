/// Supported environment flavors handled by the app runtime.
enum AppEnvironment {
  dev,
  staging,
  prod,
}

/// Centralises runtime configuration such as Supabase credentials.
///
/// Values are primarily injected via `--dart-define` or
/// `--dart-define-from-file`. Safe fallbacks are provided for local
/// development so the application can start without leaking secrets into the
/// repository.
class AppEnv {
  AppEnv._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.useInMemoryRepositories,
  });

  /// In-memory singleton that stores the resolved configuration.
  static AppEnv? _instance;

  /// Loads the environment configuration once per process.
  static Future<AppEnv> load() async {
    if (_instance != null) {
      return _instance!;
    }

    final String rawEnvironment =
        const String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final AppEnvironment environment = _parseEnvironment(rawEnvironment);

    final String injectedSupabaseUrl =
        const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final String injectedSupabaseAnonKey =
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    final String inMemoryFlag = const String.fromEnvironment(
      'USE_IN_MEMORY_REPOSITORIES',
      defaultValue: 'auto',
    );

    final _EnvDefaults defaults = _defaults[environment]!;
    final String resolvedUrl = injectedSupabaseUrl.isNotEmpty
        ? injectedSupabaseUrl
        : defaults.url;
    final String resolvedAnonKey = injectedSupabaseAnonKey.isNotEmpty
        ? injectedSupabaseAnonKey
        : defaults.anonKey;
    final bool hasCredentials =
        resolvedUrl.isNotEmpty && resolvedAnonKey.isNotEmpty;

    final bool useInMemoryRepositories = _shouldUseInMemory(
      inMemoryFlag,
      hasCredentials: hasCredentials,
    );

    _instance = AppEnv._(
      environment: environment,
      supabaseUrl: resolvedUrl,
      supabaseAnonKey: resolvedAnonKey,
      useInMemoryRepositories: useInMemoryRepositories,
    );
    return _instance!;
  }

  /// Returns the loaded environment. Make sure [load] was awaited beforehand.
  static AppEnv get instance {
    final AppEnv? env = _instance;
    if (env == null) {
      throw StateError(
        'AppEnv.load() must be awaited before accessing AppEnv.instance',
      );
    }
    return env;
  }

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool useInMemoryRepositories;

  String get label => environment.name;

  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.prod;

  static AppEnvironment _parseEnvironment(String raw) {
    switch (raw.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }

  static bool _shouldUseInMemory(
    String flag, {
    required bool hasCredentials,
  }) {
    final String normalized = flag.toLowerCase().trim();
    switch (normalized) {
      case 'true':
      case '1':
      case 'yes':
      case 'demo':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'supabase':
        return false;
      default:
        return !hasCredentials;
    }
  }

  static const Map<AppEnvironment, _EnvDefaults> _defaults =
      <AppEnvironment, _EnvDefaults>{
    AppEnvironment.dev: _EnvDefaults(
      // Default Supabase local development values (non-sensitive).
      url: 'http://127.0.0.1:54321',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.local-development-placeholder',
    ),
    AppEnvironment.staging: _EnvDefaults(url: '', anonKey: ''),
    AppEnvironment.prod: _EnvDefaults(url: '', anonKey: ''),
  };
}

class _EnvDefaults {
  const _EnvDefaults({
    required this.url,
    required this.anonKey,
  });

  final String url;
  final String anonKey;
}
