class AppConstants {
  const AppConstants._();

  static const String appName = 'Khodan';
  static const String supportEmail = 'support@khodan.app';

  static const String _defaultSupabaseUrl = 'https://example.supabase.co';
  static const String _defaultSupabaseAnonKey = 'public-anon-key';

  /// Inject credentials at build time: `--dart-define=SUPABASE_URL=...`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );

  /// Default configuration for the rabbit module.
  static const String defaultSpeciesName = 'Lapin';
  static const int defaultRabbitGestationDays = 31;
  static const int defaultRabbitWeaningDays = 35;

  static const List<String> defaultRabbitEventsSchema = <String>[
    'Accouplement',
    'Palpation',
    'Mise Bas',
    'Sevrage',
  ];
}
