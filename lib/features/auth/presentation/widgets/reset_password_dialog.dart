import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.infoMessage != current.infoMessage ||
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (BuildContext context, AuthState state) {
        if (state.status != AuthStatus.loading &&
            state.errorMessage == null &&
            state.infoMessage != null) {
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      },
      child: AlertDialog(
        title: const Text('Reinitialiser le mot de passe'),
        content: Form(
          key: _formKey,
          child: TextFormField(
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
                        await context.read<AuthCubit>().resetPassword(
                              _emailController.text.trim(),
                            );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer'),
              );
            },
          ),
        ],
      ),
    );
  }
}
