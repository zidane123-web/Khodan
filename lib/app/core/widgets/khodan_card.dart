import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// High level card component with optional header and footer slots.
class KhodanCard extends StatelessWidget {
  const KhodanCard({
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.padding = const EdgeInsets.all(KhodanSpacing.lg),
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null || leading != null || trailing != null)
              _Header(
                title: title,
                subtitle: subtitle,
                leading: leading,
                trailing: trailing,
              ),
            if (title != null || leading != null || trailing != null)
              const SizedBox(height: KhodanSpacing.md),
            child,
            if (footer != null) ...<Widget>[
              const SizedBox(height: KhodanSpacing.lg),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: KhodanSpacing.sm),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: subtitle != null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          leading!,
          const SizedBox(width: KhodanSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.titleMedium,
                ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: KhodanSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: KhodanSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
