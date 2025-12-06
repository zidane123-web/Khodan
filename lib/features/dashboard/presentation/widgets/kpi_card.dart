import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveColor = color ?? theme.colorScheme.primary;
    
    final TextStyle titleStyle =
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) ??
            const TextStyle(fontWeight: FontWeight.w700);
    final TextStyle valueStyle = theme.textTheme.headlineMedium!
        .copyWith(color: effectiveColor, fontWeight: FontWeight.bold);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 28),
                ),
              if (icon != null) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: titleStyle),
                    const SizedBox(height: 4),
                    Text(value, style: valueStyle),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
