import 'package:flutter/material.dart';

/// Custom app level colors that complement the Material [ColorScheme].
@immutable
class KhodanAppColors extends ThemeExtension<KhodanAppColors> {
  const KhodanAppColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  @override
  ThemeExtension<KhodanAppColors> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return KhodanAppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  ThemeExtension<KhodanAppColors> lerp(
    covariant ThemeExtension<KhodanAppColors>? other,
    double t,
  ) {
    if (other is! KhodanAppColors) {
      return this;
    }

    return KhodanAppColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
    );
  }
}

/// Standard spacing scale used throughout the application.
class KhodanSpacing {
  const KhodanSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Standard corner radius scale used by the design system.
class KhodanRadius {
  const KhodanRadius._();

  static const BorderRadius small = BorderRadius.all(Radius.circular(4));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8));
  static final BorderRadius large = BorderRadius.circular(16);
}

ThemeData buildKhodanTheme() {
  const Color primary = Color(0xFF1B4D8C);
  const Color secondary = Color(0xFF47A36D);
  const Color tertiary = Color(0xFFFFB347);
  const Color danger = Color(0xFFD96B5F);
  const Color surface = Color(0xFFF5F7FA);
  const Color surfaceTint = Colors.white;

  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
    error: danger,
    surface: surface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: const Color(0xFF3D2A0E),
    onSurface: const Color(0xFF101828),
    onError: Colors.white,
  );

  const TextTheme textTheme = TextTheme(
    displayMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 44,
      letterSpacing: -0.5,
      color: Color(0xFF101828),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 32,
      letterSpacing: -0.4,
      color: Color(0xFF101828),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 28,
      letterSpacing: -0.3,
      color: Color(0xFF101828),
    ),
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.2,
      color: Color(0xFF101828),
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.1,
      color: Color(0xFF101828),
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Color(0xFF101828),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.5,
      color: Color(0xFF344054),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: Color(0xFF475467),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.4,
      color: Color(0xFF667085),
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: 0.1,
      color: Color(0xFF475467),
    ),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    useMaterial3: true,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: surfaceTint,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: KhodanRadius.large),
      margin: const EdgeInsets.symmetric(vertical: KhodanSpacing.sm),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceTint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KhodanSpacing.md,
        vertical: KhodanSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: KhodanRadius.medium,
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: KhodanRadius.medium,
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: KhodanRadius.medium,
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: KhodanRadius.medium,
        borderSide: BorderSide(color: danger),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF98A2B3)),
      labelStyle:
          textTheme.bodyMedium?.copyWith(color: const Color(0xFF475467)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      KhodanAppColors(
        success: Color(0xFF47A36D),
        onSuccess: Colors.white,
        warning: Color(0xFFFFB347),
        onWarning: Color(0xFF3D2A0E),
        info: Color(0xFF4C7CD5),
        onInfo: Colors.white,
      ),
    ],
  );
}
