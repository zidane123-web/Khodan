import 'package:flutter/material.dart';

import '../../config/theme.dart';

enum KhodanTagVariant { info, success, warning, danger }

/// Small label used to highlight statuses or categories.
class KhodanTag extends StatelessWidget {
  const KhodanTag(
    this.label, {
    this.variant = KhodanTagVariant.info,
    this.icon,
    super.key,
  });

  final String label;
  final KhodanTagVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KhodanAppColors appColors =
        theme.extension<KhodanAppColors>() ?? const KhodanAppColors(
          success: Color(0xFF47A36D),
          onSuccess: Colors.white,
          warning: Color(0xFFFFB347),
          onWarning: Color(0xFF3D2A0E),
          info: Color(0xFF4C7CD5),
          onInfo: Colors.white,
        );

    final _TagStyle style = switch (variant) {
      KhodanTagVariant.success => _TagStyle(
          background: appColors.success.withOpacity(0.12),
          foreground: appColors.success,
        ),
      KhodanTagVariant.warning => _TagStyle(
          background: appColors.warning.withOpacity(0.18),
          foreground: appColors.warning,
        ),
      KhodanTagVariant.danger => _TagStyle(
          background: theme.colorScheme.error.withOpacity(0.12),
          foreground: theme.colorScheme.error,
        ),
      KhodanTagVariant.info => _TagStyle(
          background: appColors.info.withOpacity(0.12),
          foreground: appColors.info,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: KhodanRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KhodanSpacing.md,
          vertical: KhodanSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 16, color: style.foreground),
              const SizedBox(width: KhodanSpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: style.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagStyle {
  const _TagStyle({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
