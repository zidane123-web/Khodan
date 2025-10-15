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
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppEnv env = await AppEnv.load();
  if (kDebugMode) {
    debugPrint('App environment: ${env.label}');
  }
  await _initializeSupabase(env);
  _resetInMemoryRepositories();
  runApp(const KhodanApp());
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
  const KhodanApp({super.key});

  @override
  State<KhodanApp> createState() => _KhodanAppState();
}

class _KhodanAppState extends State<KhodanApp> {
  Key _appKey = UniqueKey();

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode) {
      _resetInMemoryRepositories();
      setState(() {
        _appKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      key: _appKey,
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<AnimalRepository>(
          create: (_) => InMemoryAnimalRepository(),
        ),
        RepositoryProvider<BreedingRepository>(
          create: (_) => InMemoryBreedingRepository(),
        ),
        RepositoryProvider<EventRepository>(
          create: (_) => InMemoryEventRepository(),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (BuildContext context) => AuthCubit(AuthRepository()),
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: buildKhodanTheme(),
          routerConfig: KhodanRouter().router,
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
}
