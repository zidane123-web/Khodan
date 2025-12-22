// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/router.dart';
import '../../../../app/config/theme.dart';
import '../../../../app/core/constants.dart';
import '../../../../app/core/widgets/khodan_card.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour 🌅';
    } else if (hour < 18) {
      return 'Bon après-midi ☀️';
    } else {
      return 'Bonsoir 🌙';
    }
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
          context.go(const DashboardRoute().location);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(KhodanSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: KhodanSpacing.xl),
                  
                  // Hero Section with Illustration
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '🐰',
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.lg),

                  // App Name and Tagline
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Votre assistant d'élevage intelligent",
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.xl),

                  // Greeting
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Content de vous revoir !',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.lg),

                  // Login Form Card
                  KhodanCard(
                    child: Padding(
                      padding: const EdgeInsets.all(KhodanSpacing.md),
                      child: const LoginForm(),
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.lg),

                  // Divider with "or"
                  Row(
                    children: <Widget>[
                      Expanded(child: Divider(color: theme.colorScheme.outline.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: KhodanSpacing.md),
                        child: Text(
                          'ou',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.colorScheme.outline.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: KhodanSpacing.lg),

                  // Signup Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(const SignupRoute().location),
                      icon: const Icon(Icons.person_add_alt),
                      label: const Text('Créer un compte'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: KhodanSpacing.sm),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: KhodanRadius.medium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.xl),

                  // SSO Buttons (Coming Soon)
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Connexion alternative',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: KhodanSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _SsoButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onTap: null, // Disabled
                            ),
                            const SizedBox(width: KhodanSpacing.sm),
                            _SsoButton(
                              icon: Icons.window,
                              label: 'Microsoft',
                              onTap: null, // Disabled
                            ),
                          ],
                        ),
                        const SizedBox(height: KhodanSpacing.xs),
                        Text(
                          'Bientôt disponible',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KhodanSpacing.xl),

                  // Support Section
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Besoin d'aide ?",
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          AppConstants.supportEmail,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  const _SsoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDisabled = onTap == null;

    return Tooltip(
      message: isDisabled ? 'Bientôt disponible' : label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: KhodanRadius.medium,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KhodanSpacing.md,
              vertical: KhodanSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(isDisabled ? 0.3 : 0.5),
              ),
              borderRadius: KhodanRadius.medium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 20,
                  color: isDisabled
                      ? theme.colorScheme.outline.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: KhodanSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDisabled
                        ? theme.colorScheme.outline.withOpacity(0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

