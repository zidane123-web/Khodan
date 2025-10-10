import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Primary button following the Khodan design system.
class KhodanPrimaryButton extends StatelessWidget {
  const KhodanPrimaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      textStyle: theme.textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(
        horizontal: KhodanSpacing.lg,
        vertical: KhodanSpacing.sm,
      ),
      minimumSize: fullWidth ? const Size.fromHeight(48) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: KhodanRadius.medium,
      ),
    );

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

/// Secondary button with outline style.
class KhodanSecondaryButton extends StatelessWidget {
  const KhodanSecondaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final ButtonStyle style = OutlinedButton.styleFrom(
      foregroundColor: colors.primary,
      textStyle: theme.textTheme.labelLarge?.copyWith(color: colors.primary),
      side: BorderSide(color: colors.primary, width: 1.2),
      padding: const EdgeInsets.symmetric(
        horizontal: KhodanSpacing.lg,
        vertical: KhodanSpacing.sm,
      ),
      minimumSize: fullWidth ? const Size.fromHeight(48) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: KhodanRadius.medium,
      ),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

/// Ghost button used for tertiary actions.
class KhodanGhostButton extends StatelessWidget {
  const KhodanGhostButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: colors.primary,
      textStyle: theme.textTheme.labelLarge?.copyWith(color: colors.primary),
      padding: const EdgeInsets.symmetric(
        horizontal: KhodanSpacing.md,
        vertical: KhodanSpacing.sm,
      ),
      minimumSize: fullWidth ? const Size.fromHeight(48) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: KhodanRadius.medium,
      ),
    );

    if (icon != null) {
      return TextButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

/// Danger variant dedicated to destructive actions.
class KhodanDangerButton extends StatelessWidget {
  const KhodanDangerButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: colors.error,
      foregroundColor: colors.onError,
      textStyle: theme.textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(
        horizontal: KhodanSpacing.lg,
        vertical: KhodanSpacing.sm,
      ),
      minimumSize: fullWidth ? const Size.fromHeight(48) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: KhodanRadius.medium,
      ),
    );

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
