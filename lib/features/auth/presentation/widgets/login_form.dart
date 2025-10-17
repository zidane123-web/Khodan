import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/core/widgets/khodan_primary_button.dart';
import '../cubit/auth_cubit.dart';
import 'reset_password_dialog.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'agathe@ferme.com',
              ),
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
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
              ),
              obscureText: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Mot de passe requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (AuthState previous, AuthState current) =>
                  previous.status != current.status,
              builder: (BuildContext context, AuthState state) {
                final bool isLoading = state.status == AuthStatus.loading;
                return KhodanPrimaryButton(
                  label: 'Se connecter',
                  icon: Icons.login,
                  loading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<AuthCubit>().signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (AuthState previous, AuthState current) =>
                    previous.status != current.status,
                builder: (BuildContext context, AuthState state) {
                  final bool isLoading = state.status == AuthStatus.loading;
                  return TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final AuthCubit authCubit =
                                context.read<AuthCubit>();
                            showDialog<void>(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: authCubit,
                                child: const ResetPasswordDialog(),
                              ),
                            );
                          },
                    child: const Text('Mot de passe oublie ?'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
