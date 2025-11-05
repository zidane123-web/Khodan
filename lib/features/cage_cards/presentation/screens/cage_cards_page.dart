import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/models/cage_card_template.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/repositories/litter_repository.dart';
import '../../../../data/services/cage_card_service.dart';
import '../widgets/cage_card_preview.dart';

class CageCardsPage extends StatefulWidget {
  const CageCardsPage({super.key, this.service});

  final CageCardService? service;

  @override
  State<CageCardsPage> createState() => _CageCardsPageState();
}

class _CageCardsPageState extends State<CageCardsPage> {
  static final DateFormat _fileNameFormatter =
      DateFormat('yyyyMMdd_HHmmss');
  final List<CageCardTemplate> _templates = _demoTemplates;
  late CageCardTemplate _selectedTemplate;
  late CageCardService _service;
  final Set<String> _selectedIds = <String>{};
  List<CageCardRecord> _records = <CageCardRecord>[];
  bool _hideSensitive = true;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = _templates.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _service = widget.service ??
        CageCardService(
          animalRepository: context.read<AnimalRepository>(),
          litterRepository: context.read<LitterRepository>(),
          eventRepository: context.read<EventRepository>(),
        );
    _initialized = true;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final List<CageCardRecord> records =
          await _service.loadActiveRecords(baseDeepLink: Uri.parse('https://app.khodan.africa/app'));
      setState(() {
        _records = records;
        _selectedIds
          ..clear()
          ..addAll(records.map((CageCardRecord e) => e.id));
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  List<CageCardRecord> get _selectedRecords => _records
      .where((CageCardRecord record) => _selectedIds.contains(record.id))
      .toList(growable: false);

  bool get _hasSelection => _selectedRecords.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartes de clapier'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recharger',
            onPressed: _isLoading ? null : _loadRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(isWide),
        ),
      ),
    );
  }

  Widget _buildBody(bool isWide) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.warning_amber, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadRecords,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final Widget selectors = SizedBox(
      width: isWide ? 380 : double.infinity,
      child: _buildSelectors(),
    );
    final Widget preview = Expanded(
      child: _PreviewPanel(
        records: _selectedRecords,
        template: _selectedTemplate,
        hideSensitive: _hideSensitive,
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          selectors,
          const SizedBox(width: 24),
          preview,
        ],
      );
    }

    return ListView(
      children: <Widget>[
        selectors,
        const SizedBox(height: 24),
        preview,
      ],
    );
  }

  Widget _buildSelectors() {
    final bool isAllSelected = _selectedIds.length == _records.length;
    final bool isPartiallySelected =
        _selectedIds.isNotEmpty && _selectedIds.length != _records.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _HelpBanner(),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Template',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CageCardTemplate>(
                  initialValue: _selectedTemplate,
                  decoration: const InputDecoration(
                    labelText: 'Format',
                    border: OutlineInputBorder(),
                  ),
                  items: _templates
                      .map(
                        (CageCardTemplate template) =>
                            DropdownMenuItem<CageCardTemplate>(
                          value: template,
                          child: Text(
                            '${template.label} • ${template.format.label}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (CageCardTemplate? template) {
                    if (template == null) {
                      return;
                    }
                    setState(() => _selectedTemplate = template);
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTemplate.enabledFields
                      .map(
                        (CageCardField field) => Chip(
                          avatar: const Icon(Icons.drag_indicator, size: 16),
                          label: Text(field.label),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: <Widget>[
              CheckboxListTile(
                value: isPartiallySelected ? null : isAllSelected,
                tristate: true,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds
                        ..clear()
                        ..addAll(_records.map((CageCardRecord e) => e.id));
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
                title: const Text('Sélectionner tout'),
                subtitle: Text('${_selectedIds.length} cartes retenues'),
              ),
              const Divider(height: 1),
              if (_records.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun lapin actif.'),
                )
              else
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CageCardRecord record = _records[index];
                      return CheckboxListTile(
                        dense: true,
                        value: _selectedIds.contains(record.id),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedIds.add(record.id);
                            } else {
                              _selectedIds.remove(record.id);
                            }
                          });
                        },
                        title: Text(record.title),
                        subtitle: Text(
                          '${record.cageLabel} • ${record.subjectType.name}',
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile.adaptive(
          title: const Text('Masquer données sensibles'),
          subtitle: const Text('Ex : coûts, notes internes'),
          value: _hideSensitive,
          onChanged: (bool value) {
            setState(() => _hideSensitive = value);
          },
        ),
        const SizedBox(height: 16),
        _ActionButtons(
          onDownload: _hasSelection ? _handleDownloadPdf : null,
          onPrint: _hasSelection ? _handlePrint : null,
          onExport: _hasSelection ? _handleExportToPrinter : null,
          busy: _isProcessing,
        ),
      ],
    );
  }

  Future<void> _handleDownloadPdf() async {
    await _executeAction(
      fallbackMessage: 'PDF sauvegarde.',
      runner: (Uint8List pdfBytes) async {
        final File file = await _savePdfLocally(pdfBytes);
        return 'Enregistre dans ${file.path}';
      },
    );
  }

  Future<void> _handlePrint() async {
    await _executeAction(
      fallbackMessage: 'Impression envoyee.',
      runner: (Uint8List pdfBytes) async {
        await _sendToPrint(pdfBytes);
        return 'Apercu impression ouvert.';
      },
    );
  }

  Future<void> _handleExportToPrinter() async {
    await _executeAction(
      fallbackMessage: 'Export Supabase pret.',
      runner: (Uint8List pdfBytes) async {
        final String path = await _exportToStorage(pdfBytes);
        return 'Disponible sur $path';
      },
    );
  }

  Future<void> _executeAction({
    required Future<String?> Function(Uint8List bytes) runner,
    String? fallbackMessage,
  }) async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List bytes = await _service.generatePdf(
        template: _selectedTemplate,
        records: _selectedRecords,
        hideSensitiveData: _hideSensitive,
      );
      final String? customMessage = await runner(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customMessage ?? fallbackMessage ?? 'Action terminee.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Echec : $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<File> _savePdfLocally(Uint8List bytes) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory target = Directory(p.join(baseDir.path, 'cage_cards'));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    final String fileName =
        'cage_cards_${_fileNameFormatter.format(DateTime.now())}.pdf';
    final File file = File(p.join(target.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _sendToPrint(Uint8List bytes) {
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  Future<String> _exportToStorage(Uint8List bytes) async {
    SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase n\'est pas configure sur cet appareil.');
    }
    final String? profileId = client.auth.currentUser?.id;
    if (profileId == null) {
      throw StateError('Connecte-toi pour exporter vers Supabase Storage.');
    }
    return _service.exportToStorage(
      pdfBytes: bytes,
      profileId: profileId,
    );
  }
}
class _HelpBanner extends StatelessWidget {
  const _HelpBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aligné sur Everbreed : sélectionne un template, choisis les clapiers à imprimer, '
                'puis exporte un PDF avec QR pour ouvrir la fiche Supabase.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onDownload,
    required this.onPrint,
    required this.onExport,
    required this.busy,
  });

  final Future<void> Function()? onDownload;
  final Future<void> Function()? onPrint;
  final Future<void> Function()? onExport;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: busy ? null : onDownload,
          icon: const Icon(Icons.download),
          label: const Text('Télécharger PDF'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: busy ? null : onPrint,
          icon: const Icon(Icons.print),
          label: const Text('Imprimer'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : onExport,
          icon: const Icon(Icons.factory_outlined),
          label: const Text('Exporter vers imprimeur'),
        ),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.records,
    required this.template,
    required this.hideSensitive,
  });

  final List<CageCardRecord> records;
  final CageCardTemplate template;
  final bool hideSensitive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Aperçu (${records.length} cartes)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(template.format.label),
              ],
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const Text('Sélectionne au moins un lapin pour voir l’aperçu.')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: records
                    .take(6)
                    .map(
                      (CageCardRecord record) => ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 260,
                          maxWidth: _previewWidth(template.format),
                        ),
                        child: CageCardPreviewCard(
                          record: record,
                          template: template,
                          hideSensitive: hideSensitive,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  double _previewWidth(CageCardFormat format) {
    switch (format) {
      case CageCardFormat.a4:
        return 320;
      case CageCardFormat.a5:
        return 360;
      case CageCardFormat.label:
        return 240;
    }
  }
}

const List<CageCardTemplate> _demoTemplates = <CageCardTemplate>[
  CageCardTemplate(
    id: 'tpl-a4',
    label: 'Standard élevage',
    format: CageCardFormat.a4,
  ),
  CageCardTemplate(
    id: 'tpl-a5',
    label: 'Fiche maternité',
    format: CageCardFormat.a5,
    enabledFields: <CageCardField>{
      CageCardField.identity,
      CageCardField.cage,
      CageCardField.breedingDates,
      CageCardField.weight,
      CageCardField.notes,
      CageCardField.qr,
    },
  ),
  CageCardTemplate(
    id: 'tpl-label',
    label: 'Étiquette mobile',
    format: CageCardFormat.label,
    enabledFields: <CageCardField>{
      CageCardField.identity,
      CageCardField.cage,
      CageCardField.qr,
    },
  ),
];








