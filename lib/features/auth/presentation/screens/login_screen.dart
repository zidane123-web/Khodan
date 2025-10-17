// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../../../../app/core/constants.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.infoMessage != current.infoMessage,
      listener: (BuildContext context, AuthState state) {
        final AuthCubit cubit = context.read<AuthCubit>();
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          cubit.acknowledgeError();
        } else if (state.infoMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.infoMessage!)),
            );
          cubit.acknowledgeInfo();
        }

        if (state.status == AuthStatus.authenticated) {
          context.go(const DashboardRoute().location);
        } else if (state.status == AuthStatus.emailConfirmationRequired) {
          final String email =
              state.emailPendingVerification ?? state.session?.user.email ?? '';
          context.go(
            const EmailConfirmationRoute().location,
            extra: email,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Votre assistant d'elevage intelligent",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                const Expanded(child: LoginForm()),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Besoin d'aide ?",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        AppConstants.supportEmail,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (AuthState previous, AuthState current) =>
                previous.status != current.status,
            builder: (BuildContext context, AuthState state) {
              final bool isLoading = state.status == AuthStatus.loading;
              return FilledButton.icon(
                label: const Text('Creer un compte'),
                icon: const Icon(Icons.person_add_alt),
                onPressed: isLoading
                    ? null
                    : () {
                        final AuthCubit authCubit = context.read<AuthCubit>();
                        showDialog<void>(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: authCubit,
                            child: const _SignupDialog(),
                          ),
                        );
                      },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignupDialog extends StatefulWidget {
  const _SignupDialog();

  @override
  State<_SignupDialog> createState() => _SignupDialogState();
}

class _SignupDialogState extends State<_SignupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status != current.status,
      listener: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.emailConfirmationRequired) {
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      },
      child: AlertDialog(
        title: const Text('Creer un elevage'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _farmNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la ferme',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Merci de renseigner un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Email requis';
                    }
                    if (!value.contains('@')) {
                      return 'Adresse invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.length < 6) {
                      return '6 caracteres minimum';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).maybePop(),
            child: const Text('Annuler'),
          ),
          BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (AuthState previous, AuthState current) =>
                previous.status != current.status,
            builder: (BuildContext context, AuthState state) {
              final bool isLoading = state.status == AuthStatus.loading;
              return FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        await context.read<AuthCubit>().signUp(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              farmName: _farmNameController.text.trim(),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Creer'),
              );
            },
          ),
        ],
      ),
    );
  }
}
