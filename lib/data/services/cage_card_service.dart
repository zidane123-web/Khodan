import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/animal.dart';
import '../models/animal_event.dart';
import '../models/cage_card_template.dart';
import '../models/event.dart';
import '../models/litter.dart';
import '../repositories/animal_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/litter_repository.dart';
import 'api_client.dart';

/// Prépare les données d'impression des cartes de clapier (animaux + portées).
class CageCardService {
  CageCardService({
    required AnimalRepository animalRepository,
    required LitterRepository litterRepository,
    EventRepository? eventRepository,
    ApiExecutor? apiClient,
    Uri? fallbackDeepLinkBase,
  })  : _animalRepository = animalRepository,
        _litterRepository = litterRepository,
        _eventRepository = eventRepository,
        _api = apiClient ?? ApiClient(),
        _baseDeepLink =
            fallbackDeepLinkBase ?? Uri.parse('https://app.khodan.africa');

  final AnimalRepository _animalRepository;
  final LitterRepository _litterRepository;
  final EventRepository? _eventRepository;
  final ApiExecutor _api;
  final Uri _baseDeepLink;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Charge les éleveurs/portées actifs et transforme en [CageCardRecord].
  Future<List<CageCardRecord>> loadActiveRecords({
    bool includeBreeders = true,
    bool includeLitters = true,
    Uri? baseDeepLink,
  }) async {
    final Uri resolvedBase = baseDeepLink ?? _baseDeepLink;
    final Future<List<Animal>> animalsFuture =
        includeBreeders ? _animalRepository.fetchAnimals(speciesId: 1) : Future<List<Animal>>.value(<Animal>[]);
    final Future<List<Litter>> littersFuture =
        includeLitters ? _litterRepository.fetchLitters() : Future<List<Litter>>.value(<Litter>[]);
    final Future<Map<String, _WeightMeasurement>> weightsFuture =
        _eventRepository == null
            ? Future<Map<String, _WeightMeasurement>>.value(
                const <String, _WeightMeasurement>{},
              )
            : _loadLatestWeights();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      animalsFuture,
      littersFuture,
      weightsFuture,
    ]);

    final List<Animal> animals = results[0] as List<Animal>;
    final List<Litter> litters = results[1] as List<Litter>;
    final Map<String, _WeightMeasurement> weights =
        results[2] as Map<String, _WeightMeasurement>;

    final List<CageCardRecord> records = <CageCardRecord>[
      ...animals
          .where(_isAnimalActive)
          .map(
            (Animal animal) => _mapAnimal(
              animal,
              resolvedBase,
              weights[animal.id],
            ),
          ),
      ...litters
          .where(_isLitterActive)
          .map((Litter litter) => _mapLitter(litter, resolvedBase)),
    ]..sort(
        (CageCardRecord a, CageCardRecord b) => a.title.compareTo(b.title),
      );

    return records;
  }

  /// Crée un PDF prêt à être téléchargé ou imprimé.
  Future<Uint8List> generatePdf({
    required CageCardTemplate template,
    required List<CageCardRecord> records,
    bool hideSensitiveData = false,
  }) async {
    final pw.Document doc = pw.Document();
    final PdfPageFormat pageFormat = _pageFormatFor(template.format);
    final PdfColor accent = _colorFromHex(template.accentColor);
    final bool showSensitive = template.includeSensitive && !hideSensitiveData;

    if (records.isEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                'Aucune carte sélectionnée.',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey700,
                ),
              ),
            );
          },
        ),
      );
      return doc.save();
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: records
                  .map(
                    (CageCardRecord record) => _buildPdfCard(
                      record: record,
                      template: template,
                      accent: accent,
                      showSensitive: showSensitive,
                    ),
                  )
                  .toList(growable: false),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Sauvegarde un PDF dans Supabase Storage (bucket `cage_cards`).
  Future<String> exportToStorage({
    required Uint8List pdfBytes,
    required String profileId,
    DateTime? timestamp,
  }) async {
    final DateTime now = timestamp ?? DateTime.now().toUtc();
    final String filename = 'cage_cards_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
    final String path = '$profileId/$filename';

    await _api.run(
      (SupabaseClient client) => client.storage.from('cage_cards').uploadBinary(
            path,
            pdfBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'application/pdf',
            ),
          ),
      label: 'cageCards.export',
    );

    return 'cage_cards/$path';
  }

  Future<Map<String, _WeightMeasurement>> _loadLatestWeights() async {
    final EventRepository? repository = _eventRepository;
    if (repository == null) {
      return const <String, _WeightMeasurement>{};
    }
    try {
      final DateTime start =
          DateTime.now().subtract(const Duration(days: 120));
      final List<LivestockEvent> events =
          await repository.fetchEvents(start: start);
      if (events.isEmpty) {
        return const <String, _WeightMeasurement>{};
      }
      final List<AnimalEventLink> links =
          await repository.fetchEventLinks();
      final Map<String, _WeightMeasurement> latest =
          <String, _WeightMeasurement>{};
      final Map<String, DateTime> latestDate = <String, DateTime>{};
      for (final LivestockEvent event in events) {
        if (event.eventType != 'weight') {
          continue;
        }
        final double? weight = _extractWeight(event);
        if (weight == null) {
          continue;
        }
        final Iterable<String> animalIds = links
            .where((AnimalEventLink link) => link.eventId == event.id)
            .map((AnimalEventLink link) => link.animalId);
        for (final String animalId in animalIds) {
          final DateTime previous =
              latestDate[animalId] ??
              DateTime.fromMillisecondsSinceEpoch(0);
          if (event.eventDate.isBefore(previous)) {
            continue;
          }
          latestDate[animalId] = event.eventDate;
          latest[animalId] = _WeightMeasurement(
            weightKg: weight,
            eventDate: event.eventDate,
          );
        }
      }
      return latest;
    } catch (error) {
      debugPrint('Impossible de charger les pesées: $error');
      return const <String, _WeightMeasurement>{};
    }
  }

  double? _extractWeight(LivestockEvent event) {
    final dynamic raw =
        event.details['weightKg'] ?? event.details['weight'];
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw);
    }
    return null;
  }

  CageCardRecord _mapAnimal(
    Animal animal,
    Uri base,
    _WeightMeasurement? measurement,
  ) {
    final double? estimatedWeightKg =
        measurement?.weightKg ?? _estimateWeight(animal);
    final String name = (animal.name?.isNotEmpty ?? false)
        ? '${animal.name} ${animal.tagId}'
        : 'Lapin ${animal.tagId}';
    final Uri link = base.resolve('/breeders/${animal.id}');
    final List<String> tags = <String>[
      if (animal.status.isNotEmpty) animal.status,
      if (animal.category?.isNotEmpty ?? false) animal.category!,
    ];
    return CageCardRecord(
      id: animal.id,
      title: name,
      subtitle: animal.breed,
      cageLabel: animal.cageNumber ?? 'À organiser',
      subjectType: CageCardSubjectType.breeder,
      deepLink: link,
      birthDate: animal.birthDate,
      breedingDate: animal.lastLitterDate,
      latestWeightKg: estimatedWeightKg,
      latestWeightDate: measurement?.eventDate ?? animal.nextTaskDate,
      tags: tags,
      alert: _buildAlertFromNotes(animal.notes),
      sensitiveNote: animal.notes,
      includeSensitive: true,
    );
  }

  CageCardRecord _mapLitter(Litter litter, Uri base) {
    final double? avgKitWeight = _averageKitWeight(litter);
    final Uri link = base.resolve('/litters/${litter.id}');
    final List<String> tags = <String>[
      litter.status.label,
      if (litter.enclosure?.isNotEmpty ?? false) litter.enclosure!,
    ];
    return CageCardRecord(
      id: litter.id,
      title: 'Portée ${litter.code}',
      subtitle: '${litter.doeTag} × ${litter.buckTag}',
      cageLabel: litter.cage,
      subjectType: CageCardSubjectType.litter,
      deepLink: link,
      kindlingDate: litter.kindlingDate,
      breedingDate: litter.breedingDate,
      averageKitWeightKg: avgKitWeight,
      kitsAlive: litter.kits.length,
      tags: tags,
      alert: litter.notes?.isNotEmpty == true ? 'Notes disponibles' : null,
      sensitiveNote: litter.notes,
      includeSensitive: true,
    );
  }

  pw.Widget _buildPdfCard({
    required CageCardRecord record,
    required CageCardTemplate template,
    required PdfColor accent,
    required bool showSensitive,
  }) {
    final double width = _cardWidth(template.format);
    final List<pw.Widget> body = <pw.Widget>[];
    if (template.enabledFields.contains(CageCardField.identity)) {
      body.add(
        pw.Text(
          record.title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: accent,
          ),
        ),
      );
      if (record.subtitle?.isNotEmpty ?? false) {
        body.add(
          pw.Text(
            record.subtitle!,
            style: const pw.TextStyle(fontSize: 10),
          ),
        );
      }
    }
    if (template.enabledFields.contains(CageCardField.cage)) {
      body.add(
        pw.Text(
          'Cage : ${record.cageLabel}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      );
    }
    if (template.enabledFields.contains(CageCardField.breedingDates)) {
      final List<String> dates = <String>[];
      if (record.breedingDate != null) {
        dates.add('Saillie ${_dateFormat.format(record.breedingDate!)}');
      }
      if (record.kindlingDate != null) {
        dates.add('Nid ${_dateFormat.format(record.kindlingDate!)}');
      }
      if (record.birthDate != null &&
          record.subjectType == CageCardSubjectType.breeder) {
        dates.add('Né(e) ${_dateFormat.format(record.birthDate!)}');
      }
      if (dates.isNotEmpty) {
        body.add(pw.Text(
          dates.join(' • '),
          style: const pw.TextStyle(fontSize: 9),
        ));
      }
    }
    if (template.enabledFields.contains(CageCardField.weight)) {
      final List<String> weightLines = <String>[];
      if (record.latestWeightKg != null) {
        final String weightDate =
            record.latestWeightDate != null ? _dateFormat.format(record.latestWeightDate!) : 'récent';
        weightLines.add(
          'Poids : ${record.latestWeightKg!.toStringAsFixed(2)} kg ($weightDate)',
        );
      }
      if (record.averageKitWeightKg != null) {
        weightLines.add(
          'Moyenne portée : ${record.averageKitWeightKg!.toStringAsFixed(2)} kg',
        );
      }
      if (weightLines.isNotEmpty) {
        body.add(
          pw.Text(
            weightLines.join(' / '),
            style: const pw.TextStyle(fontSize: 9),
          ),
        );
      }
    }
    if (template.enabledFields.contains(CageCardField.litterStats) &&
        record.kitsAlive != null) {
      body.add(
        pw.Text(
          'Jeunes vivants : ${record.kitsAlive}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      );
    }
    if (template.enabledFields.contains(CageCardField.notes) &&
        record.hasSensitiveContent) {
      body.add(
        pw.Text(
          showSensitive ? record.sensitiveNote! : '*** Données masquées ***',
          style: pw.TextStyle(
            fontSize: 9,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    final pw.Widget qrWidget = template.enabledFields.contains(CageCardField.qr)
        ? pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: record.deepLink.toString(),
            width: _qrSize(template.format),
            height: _qrSize(template.format),
          )
        : pw.SizedBox(width: 0, height: 0);

    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: accent, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: body,
            ),
          ),
          if (template.enabledFields.contains(CageCardField.qr))
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8),
              child: qrWidget,
            ),
        ],
      ),
    );
  }

  bool _isAnimalActive(Animal animal) {
    final String normalized = animal.status.toLowerCase();
    const Set<String> inactive = <String>{
      'vendu',
      'mort',
      'archivé',
      'archive',
      'retiré',
    };
    return !inactive.contains(normalized);
  }

  bool _isLitterActive(Litter litter) =>
      litter.status != LitterStatus.archived;

  double? _estimateWeight(Animal animal) {
    if (animal.category == null && animal.sex.isEmpty) {
      return null;
    }
    if (animal.sex.toLowerCase() == 'male') {
      return 3.8;
    }
    if (animal.sex.toLowerCase() == 'femelle') {
      return 3.4;
    }
    return animal.category?.toLowerCase().contains('engraissement') ?? false
        ? 2.6
        : null;
  }

  double? _averageKitWeight(Litter litter) {
    final List<double> weights = litter.kits
        .map((LitterKit kit) =>
            kit.preSlaughterWeightGrams ?? kit.weaningWeightGrams ?? kit.birthWeightGrams)
        .whereType<double>()
        .toList();
    if (weights.isEmpty) {
      return null;
    }
    final double gramsAvg =
        weights.reduce((double a, double b) => a + b) / weights.length;
    return gramsAvg / 1000;
  }

  String? _buildAlertFromNotes(String? note) {
    if (note == null || note.isEmpty) {
      return null;
    }
    if (note.toLowerCase().contains('traitement') ||
        note.toLowerCase().contains('surveillance')) {
      return 'Attention santé';
    }
    return 'Note interne';
  }

  PdfPageFormat _pageFormatFor(CageCardFormat format) {
    switch (format) {
      case CageCardFormat.a4:
        return PdfPageFormat.a4;
      case CageCardFormat.a5:
        return PdfPageFormat.a5;
      case CageCardFormat.label:
        return PdfPageFormat(
          95 * PdfPageFormat.mm,
          57 * PdfPageFormat.mm,
        );
    }
  }

  double _cardWidth(CageCardFormat format) {
    switch (format) {
      case CageCardFormat.a4:
        return (PdfPageFormat.a4.width - (3 * 12 * PdfPageFormat.mm)) / 2;
      case CageCardFormat.a5:
        return PdfPageFormat.a5.width - (2 * 16 * PdfPageFormat.mm);
      case CageCardFormat.label:
        return 95 * PdfPageFormat.mm - (2 * 6 * PdfPageFormat.mm);
    }
  }

  double _qrSize(CageCardFormat format) {
    switch (format) {
      case CageCardFormat.a4:
        return 70;
      case CageCardFormat.a5:
        return 60;
      case CageCardFormat.label:
        return 45;
    }
  }

  PdfColor _colorFromHex(String hex) {
    final String sanitized = hex.replaceAll('#', '');
    final int intValue = int.parse('0xFF$sanitized');
    return PdfColor.fromInt(intValue);
  }
}

class _WeightMeasurement {
  const _WeightMeasurement({
    required this.weightKg,
    required this.eventDate,
  });

  final double weightKg;
  final DateTime eventDate;
}

