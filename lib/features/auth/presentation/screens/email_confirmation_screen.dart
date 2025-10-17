import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../cubit/auth_cubit.dart';

class EmailConfirmationScreen extends StatelessWidget {
  const EmailConfirmationScreen({
    required this.email,
    super.key,
  });

  final String email;

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
        } else if (state.status == AuthStatus.unauthenticated &&
            state.errorMessage == null) {
          context.go(const LoginRoute().location);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confirmation du compte'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (AuthState previous, AuthState current) =>
                previous.status != current.status,
            builder: (BuildContext context, AuthState state) {
              final bool isLoading = state.status == AuthStatus.loading;
              final String displayedEmail =
                  (state.emailPendingVerification ?? email).isEmpty
                      ? 'votre adresse email'
                      : (state.emailPendingVerification ?? email);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Validez votre inscription',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Un email de confirmation a ete envoye a $displayedEmail. '
                    'Cliquez sur le lien pour activer votre compte.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go(const LoginRoute().location),
                    child: const Text('Retourner a la connexion'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context
                                .read<AuthCubit>()
                                .resendConfirmationEmail(displayedEmail);
                          },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Renvoyer l'email"),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context
                                .read<AuthCubit>()
                                .sendMagicLink(displayedEmail);
                          },
                    child: const Text('Recevoir un lien magique'),
                  ),
                  if (isLoading) const SizedBox(height: 16),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
