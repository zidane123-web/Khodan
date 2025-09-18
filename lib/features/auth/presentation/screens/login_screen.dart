// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/core/constants.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (BuildContext context) => AuthCubit(AuthRepository()),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          // Pas besoin de gérer le succès ici, le routeur s'en charge.
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
                    'Votre assistant d’élevage intelligent',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  const Expanded(child: LoginForm()),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Besoin d’aide ?',
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
            child: FilledButton.icon(
              label: const Text('Créer un compte'),
              icon: const Icon(Icons.person_add_alt),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  // On passe le AuthCubit au dialogue
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthCubit>(),
                    child: const _SignupDialog(),
                  ),
                );
              },
            ),
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
    return AlertDialog(
      title: const Text('Créer un élevage'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _farmNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’élevage',
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
                    return '6 caractères minimum';
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
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Annuler'),
        ),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) {
            return FilledButton(
              onPressed: state.status == AuthStatus.loading
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
                      
                      // On ferme simplement le dialogue si le cubit est monté
                      // Le routeur va gérer la redirection tout seul
                      if (context.mounted) {
                        final bool isSuccess =
                            context.read<AuthCubit>().state.status ==
                                AuthStatus.success;
                        if (isSuccess) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
              child: state.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Créer'),
            );
          },
        ),
      ],
    );
  }
}