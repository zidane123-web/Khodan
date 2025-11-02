import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pedigree.dart';
import 'api_client.dart';

/// Service responsable de charger l'arbre genealogique et de construire le PDF.
class PedigreeService {
  PedigreeService({ApiExecutor? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiExecutor _api;

  Future<PedigreeTree> fetchTree({
    required String breederId,
    int generations = 4,
  }) async {
    final List<dynamic> payload = await _api.run(
      (client) => client.rpc(
        'fn_pedigree_tree',
        params: <String, dynamic>{
          'p_breeder_id': breederId,
          'p_generations': generations,
        },
      ),
      label: 'pedigree.fetchTree',
    );

    final List<Map<String, dynamic>> rows = payload
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);

    return PedigreeTree.fromRows(rows, requestedGenerations: generations);
  }

  Future<Uint8List> buildPdf({
    required PedigreeTree tree,
    required String farmName,
    PedigreePdfTheme theme = const PedigreePdfTheme(),
    Uri? shareLink,
    bool includeCertificate = true,
  }) async {
    final pw.Document doc = pw.Document();
    final PdfColor primary = _colorFromHex(theme.primaryHex);
    final PdfColor secondary = _colorFromHex(theme.secondaryHex);
    final PdfColor surface = _colorFromHex(theme.surfaceHex);
    final PdfColor text = _colorFromHex(theme.textHex);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(
          horizontal: 15 * PdfPageFormat.mm,
          vertical: 18 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _buildHeader(
                title: 'Pedigree officiel',
                farmName: farmName,
                primary: primary,
                text: text,
              ),
              pw.SizedBox(height: 18),
              _buildPedigreeGrid(
                tree: tree,
                primary: primary,
                secondary: secondary,
                surface: surface,
                text: text,
              ),
            ],
          );
        },
      ),
    );

    if (includeCertificate) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(
            horizontal: 15 * PdfPageFormat.mm,
            vertical: 18 * PdfPageFormat.mm,
          ),
          build: (pw.Context context) {
            return _buildCertificate(
              tree: tree,
              farmName: farmName,
              primary: primary,
              surface: surface,
              text: text,
              shareLink: shareLink,
            );
          },
        ),
      );
    }

    return doc.save();
  }

  /// Cree une URL partageable a partir du profil et de l identifiant animal.
  Uri buildShareLink(
    String breederId, {
    String? profileId,
    String baseUrl = 'https://khodan.app/share/pedigree',
  }) {
    final String suffix = profileId == null
        ? breederId
        : '$profileId/$breederId';
    return Uri.parse('$baseUrl/$suffix');
  }

  pw.Widget _buildHeader({
    required String title,
    required String farmName,
    required PdfColor primary,
    required PdfColor text,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: primary,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Elevage : $farmName',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Document genere via Khodan',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPedigreeGrid({
    required PedigreeTree tree,
    required PdfColor primary,
    required PdfColor secondary,
    required PdfColor surface,
    required PdfColor text,
  }) {
    final List<List<PedigreeNode>> columns = tree.columns;
    final double columnSpacing = 10;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (int index = 0; index < columns.length; index++) ...<pw.Widget>[
          if (index > 0) pw.SizedBox(width: columnSpacing),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: <pw.Widget>[
                pw.Text(
                  _columnTitle(index),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primary,
                  ),
                ),
                pw.SizedBox(height: 6),
                for (final PedigreeNode node in columns[index]) ...<pw.Widget>[
                  _buildNodeCard(
                    node: node,
                    primary: primary,
                    secondary: secondary,
                    surface: surface,
                    text: text,
                  ),
                  pw.SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildNodeCard({
    required PedigreeNode node,
    required PdfColor primary,
    required PdfColor secondary,
    required PdfColor surface,
    required PdfColor text,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: node.missing ? PdfColors.white : secondary,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: node.missing ? surface : primary,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            node.relationLabel,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: text,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            node.missing ? 'Information a completer' : node.effectiveName,
            style: pw.TextStyle(fontSize: 10, color: text),
          ),
          if (!node.missing) ...<pw.Widget>[
            if ((node.shortSex).isNotEmpty)
              pw.Text(
                'Sexe : ${node.shortSex}',
                style: pw.TextStyle(fontSize: 9, color: text),
              ),
            if (node.birthDate != null)
              pw.Text(
                'Ne(e) : ${_formatDate(node.birthDate)}',
                style: pw.TextStyle(fontSize: 9, color: text),
              ),
            if (node.lastMatingDate != null)
              pw.Text(
                'Saillie : ${_formatDate(node.lastMatingDate)}',
                style: pw.TextStyle(fontSize: 9, color: text),
              ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildCertificate({
    required PedigreeTree tree,
    required String farmName,
    required PdfColor primary,
    required PdfColor surface,
    required PdfColor text,
    Uri? shareLink,
  }) {
    final PedigreeNode subject = tree.subject;
    final PedigreeNode? father = tree.nodes.firstWhereOrNull(
      (PedigreeNode node) => node.generation == 1 && node.relationSide == 'P',
    );
    final PedigreeNode? mother = tree.nodes.firstWhereOrNull(
      (PedigreeNode node) => node.generation == 1 && node.relationSide == 'M',
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: surface,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _buildHeader(
            title: 'Certificat de naissance',
            farmName: farmName,
            primary: primary,
            text: text,
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  subject.effectiveName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: text,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Identifiant : ${subject.tagId ?? 'Non renseigne'}',
                  style: pw.TextStyle(fontSize: 11, color: text),
                ),
                pw.Text(
                  'Ne(e) le : ${_formatDate(subject.birthDate)}',
                  style: pw.TextStyle(fontSize: 11, color: text),
                ),
                if ((subject.shortSex).isNotEmpty)
                  pw.Text(
                    'Sexe : ${subject.shortSex}',
                    style: pw.TextStyle(fontSize: 11, color: text),
                  ),
                if (subject.origin != null && subject.origin!.isNotEmpty)
                  pw.Text(
                    'Origine : ${subject.origin}',
                    style: pw.TextStyle(fontSize: 11, color: text),
                  ),
                pw.SizedBox(height: 12),
                _buildParentLine('Pere', father, text),
                pw.SizedBox(height: 6),
                _buildParentLine('Mere', mother, text),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Signature de l elevage',
                  style: pw.TextStyle(fontSize: 11, color: text),
                ),
                pw.Container(
                  height: 40,
                  margin: const pw.EdgeInsets.symmetric(vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primary, width: 0.5),
                  ),
                ),
                pw.Text(
                  'Date : ${_formatDate(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: text),
                ),
              ],
            ),
          ),
          pw.Spacer(),
          if (shareLink != null) ...<pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'Partager en ligne',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: text,
                      ),
                    ),
                    pw.Text(
                      shareLink.toString(),
                      style: pw.TextStyle(fontSize: 9, color: text),
                    ),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: shareLink.toString(),
                  width: 80,
                  height: 80,
                ),
              ],
            ),
          ] else
            pw.Text(
              'QR code non configure (voir documentation).',
              style: pw.TextStyle(fontSize: 9, color: text),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildParentLine(String label, PedigreeNode? node, PdfColor text) {
    final bool missing = node == null || node.missing;
    final String content = missing
        ? 'Information a completer'
        : node.effectiveName;
    return pw.Row(
      children: <pw.Widget>[
        pw.Text(
          '$label : ',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: text,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            content,
            style: pw.TextStyle(fontSize: 11, color: text),
          ),
        ),
      ],
    );
  }

  String _columnTitle(int generation) {
    switch (generation) {
      case 0:
        return 'Sujet';
      case 1:
        return 'Parents';
      case 2:
        return 'Grands-parents';
      case 3:
        return 'Arriere grands-parents';
      default:
        return 'Generation $generation';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Non renseigne';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  PdfColor _colorFromHex(String hex) {
    final String sanitized = hex.replaceAll('#', '');
    return PdfColor.fromInt(int.parse('0xFF$sanitized'));
  }
}
