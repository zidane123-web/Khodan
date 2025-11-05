import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/pedigree.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/services/pedigree_service.dart';

class PedigreePage extends StatefulWidget {
  const PedigreePage({super.key});

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  Future<List<Animal>>? _animalsFuture;
  PedigreeTree? _tree;
  Animal? _selectedAnimal;
  Uri? _shareLink;
  bool _isLoadingTree = false;
  bool _isGeneratingPdf = false;
  String? _errorMessage;
  PedigreePdfTheme _currentTheme = const PedigreePdfTheme();

  PedigreeService get _service => context.read<PedigreeService>();

  @override
  void initState() {
    super.initState();
    _animalsFuture = context.read<AnimalRepository>().fetchAnimals();
  }

  Future<void> _selectAnimal(Animal? animal) async {
    setState(() {
      _selectedAnimal = animal;
      _tree = null;
      _shareLink = null;
      _errorMessage = null;
    });
    if (animal == null) {
      return;
    }
    await _loadTree(animal);
  }

  Future<void> _loadTree(Animal animal) async {
    setState(() {
      _isLoadingTree = true;
      _errorMessage = null;
    });
    try {
      final PedigreeTree tree = await _service.fetchTree(
        breederId: animal.id,
        generations: 4,
      );
      if (!mounted) return;
      setState(() {
        _tree = tree;
        _shareLink = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTree = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    final PedigreeTree? tree = _tree;
    final Animal? animal = _selectedAnimal;
    if (tree == null || animal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectionnez un lapin avant de generer.'),
        ),
      );
      return;
    }
    setState(() {
      _isGeneratingPdf = true;
    });
    try {
      final String farmName = 'Elevage ${animal.profileId.substring(0, 8)}';
      final Uint8List pdfBytes = await _service.buildPdf(
        tree: tree,
        farmName: farmName,
        theme: _currentTheme,
        shareLink: _shareLink,
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat _) async => pdfBytes);

      final String storagePath = await _service.uploadPdf(
        bytes: pdfBytes,
        profileId: animal.profileId,
        breederId: animal.id,
      );
      final Uri shareUri = await _service.createShareLink(
        profileId: animal.profileId,
        breederId: animal.id,
        storagePath: storagePath,
      );
      if (!mounted) return;
      setState(() {
        _shareLink = shareUri;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien partageable mis à jour.'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation PDF impossible : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  Future<void> _shareLinkWithUser() async {
    if (_shareLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Générez et chargez un PDF pour créer un lien partageable.',
          ),
        ),
      );
      return;
    }
    await Share.share(_shareLink.toString());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedigrees et certificats')),
      body: FutureBuilder<List<Animal>>(
        future: _animalsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Animal>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Impossible de charger les lapins : ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          final List<Animal> animals = snapshot.data ?? <Animal>[];
          if (animals.isEmpty) {
            return const Center(
              child: Text('Ajoutez un lapin pour generer un pedigree.'),
            );
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSelection(animals, theme),
                    if (_errorMessage != null) ...<Widget>[
                      const SizedBox(height: 16),
                      Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_isLoadingTree)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: LinearProgressIndicator(),
                      ),
                    if (_tree != null && !_isLoadingTree) ...<Widget>[
                      const SizedBox(height: 24),
                      _buildActions(theme),
                      const SizedBox(height: 16),
                      PedigreePreview(
                        tree: _tree!,
                        theme: _currentTheme,
                        shareLink: _shareLink,
                      ),
                      const SizedBox(height: 24),
                      _buildThemeSelector(theme),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelection(List<Animal> animals, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Selectionner un lapin', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<Animal>(
              initialValue: _selectedAnimal,
              decoration: const InputDecoration(
                labelText: 'Lapin',
                border: OutlineInputBorder(),
              ),
              items: animals
                  .map(
                    (Animal animal) => DropdownMenuItem<Animal>(
                      value: animal,
                      child: Text(
                        '${animal.tagId} - ${animal.name ?? 'Sans nom'}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (Animal? value) {
                unawaited(_selectAnimal(value));
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Le pedigree affichera jusqu a 4 generations. '
              'Les champs vides afficheront le message "Information a completer".',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton.icon(
              onPressed: _isGeneratingPdf ? null : _downloadPdf,
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Telecharger PDF'),
            ),
            OutlinedButton.icon(
              onPressed: _shareLinkWithUser,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Partager lien'),
            ),
            if (_shareLink != null)
              SelectableText(
                _shareLink.toString(),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Variantes de couleur', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children:
              <PedigreePdfTheme>[
                const PedigreePdfTheme(),
                const PedigreePdfTheme(
                  primaryHex: '1B4965',
                  secondaryHex: 'CAE9FF',
                  surfaceHex: 'F4F9FF',
                ),
                const PedigreePdfTheme(
                  primaryHex: '8D5524',
                  secondaryHex: 'F1E0C6',
                  surfaceHex: 'FBF5EE',
                ),
              ].map((PedigreePdfTheme option) {
                final bool selected = option == _currentTheme;
                return ChoiceChip(
                  label: Text(option.primaryHex),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _currentTheme = option;
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}

class PedigreePreview extends StatelessWidget {
  const PedigreePreview({
    required this.tree,
    required this.theme,
    this.shareLink,
    super.key,
  });

  final PedigreeTree tree;
  final PedigreePdfTheme theme;
  final Uri? shareLink;

  @override
  Widget build(BuildContext context) {
    final ThemeData colors = Theme.of(context);
    final List<List<PedigreeNode>> columns = tree.columns;
    final Color primary = Color(int.parse('0xFF${theme.primaryHex}'));
    final Color surface = Color(int.parse('0xFF${theme.surfaceHex}'));
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Apercu', style: colors.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isWide
                      ? MediaQuery.of(context).size.width - 96
                      : 600,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns
                      .map(
                        (List<PedigreeNode> generation) => SizedBox(
                          width: 220,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _PreviewColumn(
                              generation: generation,
                              color: primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _CertificateCard(
          subject: tree.subject,
          father: tree.nodes.firstWhereOrNull(
            (PedigreeNode node) =>
                node.generation == 1 && node.relationSide == 'P',
          ),
          mother: tree.nodes.firstWhereOrNull(
            (PedigreeNode node) =>
                node.generation == 1 && node.relationSide == 'M',
          ),
          primary: primary,
          shareLink: shareLink,
        ),
      ],
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({required this.generation, required this.color});

  final List<PedigreeNode> generation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            _titleForGeneration(
              generation.isEmpty ? 0 : generation.first.generation,
            ),
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          for (final PedigreeNode node in generation) ...<Widget>[
            _NodeCard(node: node, accent: color),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  String _titleForGeneration(int generation) {
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
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node, required this.accent});

  final PedigreeNode node;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: node.missing
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              node.relationLabel,
              style: theme.textTheme.labelLarge?.copyWith(color: accent),
            ),
            const SizedBox(height: 4),
            Text(
              node.missing ? 'Information a completer' : node.effectiveName,
              style: theme.textTheme.bodyMedium,
            ),
            if (!node.missing) ...<Widget>[
              if (node.shortSex.isNotEmpty)
                Text(
                  'Sexe : ${node.shortSex}',
                  style: theme.textTheme.bodySmall,
                ),
              if (node.birthDate != null)
                Text(
                  'Ne(e) le ${_format(node.birthDate)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _format(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.subject,
    required this.primary,
    this.father,
    this.mother,
    this.shareLink,
  });

  final PedigreeNode subject;
  final PedigreeNode? father;
  final PedigreeNode? mother;
  final Color primary;
  final Uri? shareLink;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Certificat de naissance',
              style: theme.textTheme.titleMedium?.copyWith(color: primary),
            ),
            const SizedBox(height: 8),
            Text(subject.effectiveName, style: theme.textTheme.headlineSmall),
            Text(
              'Identifiant : ${subject.tagId ?? 'Non renseigne'}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Ne(e) le ${_format(subject.birthDate)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (subject.shortSex.isNotEmpty)
              Text(
                'Sexe : ${subject.shortSex}',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            _buildParentLine(context, 'Pere', father),
            _buildParentLine(context, 'Mere', mother),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Signature de l elevage',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primary.withValues(alpha: 0.4),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (shareLink != null)
                  Column(
                    children: <Widget>[
                      Text('QR code partage', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.4),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: QrImageView(
                          data: shareLink.toString(),
                          size: 96,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                else
                  Expanded(
                    child: Text(
                      'Générez un PDF pour activer le QR code et obtenir un lien partageable.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentLine(
    BuildContext context,
    String label,
    PedigreeNode? node,
  ) {
    final ThemeData theme = Theme.of(context);
    final bool missing = node == null || node.missing;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            '$label : ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              missing ? 'Information a completer' : node.effectiveName,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
