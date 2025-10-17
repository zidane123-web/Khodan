// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final AuthCubit authCubit = context.read<AuthCubit>();
    authCubit.listenAuthChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authCubit.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status,
      listener: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(const DashboardRoute().location);
        } else if (state.status == AuthStatus.unauthenticated) {
          context.go(const LoginRoute().location);
        } else if (state.status == AuthStatus.emailConfirmationRequired) {
          context.go(
            const EmailConfirmationRoute().location,
            extra: state.emailPendingVerification ??
                state.session?.user.email ??
                '',
          );
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
