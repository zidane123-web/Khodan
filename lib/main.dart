// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/config/router.dart';
import 'app/config/theme.dart';
import 'app/core/bootstrap/bootstrap.dart';
import 'app/core/constants.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  await AppBootstrap.ensureInitialized();
  runApp(const KhodanApp());
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
      ),
    );
  }
}
