// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- 1. IMPORTATION AJOUTÉE

import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/constants.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSupabase();
  runApp(const KhodanApp());
}

Future<void> _initializeSupabase() async {
  final String supabaseUrl = AppConstants.supabaseUrl;
  final String supabaseAnonKey = AppConstants.supabaseAnonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('⚠️ Supabase credentials are missing. Skipping initialization.');
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

class KhodanApp extends StatelessWidget {
  const KhodanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (BuildContext context) => AuthCubit(AuthRepository()),
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: buildKhodanTheme(),
        routerConfig: KhodanRouter().router,
        debugShowCheckedModeBanner: false,

        // --- 2. CONFIGURATION DE LA LOCALISATION AJOUTÉE ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', ''), // Français
          // Ajoutez d'autres langues ici si nécessaire
        ],
        // ----------------------------------------------------
      ),
    );
  }
}