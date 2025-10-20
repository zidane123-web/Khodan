class AppConstants {
  const AppConstants._();

  static const String appName = 'Khodan';
  static const String supportEmail = 'support@khodan.app';

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

  static const int supportSubjectMaxLength = 120;
}
