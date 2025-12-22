// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/theme.dart';
import '../../../../app/core/widgets/khodan_primary_button.dart';
import '../cubit/auth_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthCubit>().resetPassword(
          _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
        }

        if (state.status == AuthStatus.success) {
          setState(() => _emailSent = true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Mot de passe oublié'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KhodanSpacing.lg),
            child: _emailSent ? _buildSuccessContent(theme) : _buildFormContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(KhodanSpacing.lg),
          decoration: BoxDecoration(
            color: theme.extension<KhodanAppColors>()?.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: theme.extension<KhodanAppColors>()?.success,
          ),
        ),
        const SizedBox(height: KhodanSpacing.xl),
        Text(
          'Email envoyé !',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KhodanSpacing.sm),
        Text(
          'Un lien de réinitialisation a été envoyé à\n${_emailController.text}',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KhodanSpacing.xl),
        KhodanPrimaryButton(
          label: 'Retour à la connexion',
          icon: Icons.login,
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: KhodanSpacing.md),
        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: const Text('Renvoyer l\'email'),
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.lock_reset,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: KhodanSpacing.lg),
          Text(
            'Réinitialisez votre mot de passe',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: KhodanSpacing.sm),
          Text(
            'Entrez votre adresse email. Nous vous enverrons un lien pour créer un nouveau mot de passe.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: KhodanSpacing.xl),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'votre@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.email],
            onFieldSubmitted: (_) => _handleResetPassword(),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Email requis';
              }
              if (!_emailRegex.hasMatch(value)) {
                return 'Adresse email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: KhodanSpacing.lg),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, AuthState state) {
              return KhodanPrimaryButton(
                label: 'Envoyer le lien',
                icon: Icons.send,
                fullWidth: true,
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : _handleResetPassword,
              );
            },
          ),
          const SizedBox(height: KhodanSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Retour à la connexion'),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Besoin d\'aide ?',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'support@khodan.app',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
