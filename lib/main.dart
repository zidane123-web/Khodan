import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSupabase();
  runApp(const KhodanApp());
}

Future<void> _initializeSupabase() async {
  final supabaseUrl = AppConstants.supabaseUrl;
  final supabaseAnonKey = AppConstants.supabaseAnonKey;

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
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: buildKhodanTheme(),
      routerConfig: KhodanRouter().router,
      debugShowCheckedModeBanner: false,
    );
  }
}
