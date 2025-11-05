import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../data/models/cage_card_template.dart';

class CageCardPreviewCard extends StatelessWidget {
  const CageCardPreviewCard({
    super.key,
    required this.record,
    required this.template,
    required this.hideSensitive,
  });

  final CageCardRecord record;
  final CageCardTemplate template;
  final bool hideSensitive;

  @override
  Widget build(BuildContext context) {
    final bool showSensitive = template.includeSensitive && !hideSensitive;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<Widget> meta = <Widget>[];
    if (template.enabledFields.contains(CageCardField.cage)) {
      meta.add(Text('Cage : ${record.cageLabel}'));
    }
    if (template.enabledFields.contains(CageCardField.breedingDates)) {
      final List<String> dates = _dateBadges();
      if (dates.isNotEmpty) {
        meta.add(Text(dates.join(' • ')));
      }
    }
    if (template.enabledFields.contains(CageCardField.weight)) {
      meta.add(Text(_weightLine()));
    }
    if (template.enabledFields.contains(CageCardField.litterStats) &&
        record.kitsAlive != null) {
      meta.add(Text('Jeunes vivants : ${record.kitsAlive}'));
    }
    if (template.enabledFields.contains(CageCardField.notes) &&
        record.sensitiveNote?.isNotEmpty == true) {
      meta.add(
        Text(
          showSensitive ? record.sensitiveNote! : '*** Données masquées ***',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    record.title,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (record.subtitle?.isNotEmpty ?? false)
                    Text(
                      record.subtitle!,
                      style: textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: record.tags
                        .where((String tag) => tag.isNotEmpty)
                        .map(
                          (String tag) => Chip(
                            label: Text(tag),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  ...meta.map(
                    (Widget line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: line,
                    ),
                  ),
                ],
              ),
            ),
            if (template.enabledFields.contains(CageCardField.qr))
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: QrImageView(
                  data: record.deepLink.toString(),
                  size: _qrSize(template.format),
                  backgroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _dateBadges() {
    final DateFormat fmt = DateFormat('dd/MM');
    final List<String> badges = <String>[];
    if (record.breedingDate != null) {
      badges.add('Saillie ${fmt.format(record.breedingDate!)}');
    }
    if (record.kindlingDate != null) {
      badges.add('Nid ${fmt.format(record.kindlingDate!)}');
    }
    if (record.birthDate != null &&
        record.subjectType == CageCardSubjectType.breeder) {
      badges.add('Naissance ${fmt.format(record.birthDate!)}');
    }
    return badges;
  }

  String _weightLine() {
    final List<String> parts = <String>[];
    if (record.latestWeightKg != null) {
      parts.add('${record.latestWeightKg!.toStringAsFixed(2)} kg');
    }
    if (record.averageKitWeightKg != null) {
      parts.add('Portée ${record.averageKitWeightKg!.toStringAsFixed(2)} kg');
    }
    if (parts.isEmpty) {
      return 'Poids : N/A';
    }
    return 'Poids : ${parts.join(' / ')}';
  }

  double _qrSize(CageCardFormat format) {
    switch (format) {
      case CageCardFormat.a4:
        return 72;
      case CageCardFormat.a5:
        return 64;
      case CageCardFormat.label:
        return 48;
    }
  }
}
