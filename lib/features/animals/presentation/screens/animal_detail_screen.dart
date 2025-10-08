import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../domain/genealogy_analyzer.dart';
import '../cubit/animal_detail_cubit.dart';
import '../widgets/animal_performance_overview.dart';
import '../widgets/animal_photo_gallery.dart';
import '../widgets/animal_timeline.dart';
import '../widgets/genealogy_view.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({
    required this.animal,
    super.key,
  });

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalDetailCubit>(
      create: (BuildContext context) => AnimalDetailCubit(
        animal,
        context.read<AnimalRepository>(),
        context.read<BreedingRepository>(),
        context.read<EventRepository>(),
      )..load(),
      child: const _AnimalDetailView(),
    );
  }
}

class _AnimalDetailView extends StatelessWidget {
  const _AnimalDetailView();

  Future<void> _addPhoto(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final String? url = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une photo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'URL de l’image',
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (url != null && url.isNotEmpty) {
      context.read<AnimalDetailCubit>().addPhoto(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo ajoutée.')),
      );
    }
  }

  void _removePhoto(BuildContext context, String url) {
    context.read<AnimalDetailCubit>().removePhoto(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo retirée.')),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    AnimalDetailState state,
  ) async {
    final Animal animal = state.animal;
    final pw.Document doc = pw.Document();
    final String filename = 'animal-${animal.tagId}.pdf';

    String formatDate(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final pw.Widget identitySection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text('Identité', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Tag : ${animal.tagId}'),
        if (animal.name != null) pw.Text('Nom : ${animal.name}'),
        pw.Text('Sexe : ${animal.sex}'),
        pw.Text('Statut : ${animal.status}'),
        pw.Text('Naissance : ${formatDate(animal.birthDate)}'),
        if (animal.origin != null) pw.Text('Origine : ${animal.origin}'),
        if (animal.cageNumber != null) pw.Text('Cage : ${animal.cageNumber}'),
      ],
    );

    final AnimalPerformanceStats? performance = state.performance;
    final pw.Widget? performanceSection = performance == null
        ? null
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Performances',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Saillies : ${performance.totalMatings}'),
              pw.Text('Réussites : ${performance.successfulMatings}'),
              if (performance.successRate != null)
                pw.Text(
                    'Taux de réussite : ${(performance.successRate! * 100).toStringAsFixed(1)} %'),
              if (performance.averageKitsBornAlive != null)
                pw.Text(
                    'Nés vivants moyens : ${performance.averageKitsBornAlive!.toStringAsFixed(1)}'),
              if (performance.averageKitsWeaned != null)
                pw.Text(
                    'Sevrés moyens : ${performance.averageKitsWeaned!.toStringAsFixed(1)}'),
              pw.Text('Sevrés cumulés : ${performance.totalKitsWeaned}'),
            ],
          );

    final GenealogyAnalysis? genealogy = state.genealogy;
    String generationLabel(int index) {
      if (genealogy == null || index >= genealogy.generations.length) {
        return '';
      }
      final List<Animal?> ancestors = genealogy.generations[index];
      final String joined = ancestors
          .map((Animal? ancestor) => ancestor == null ? 'Inconnu' : ancestor.tagId)
          .join(', ');
      return 'Génération $index : $joined';
    }
    final pw.Widget? genealogySection = genealogy == null
        ? null
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Généalogie',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              if (genealogy.inbreedingCoefficient != null)
                pw.Text(
                  'Coefficient d’endogamie : ${genealogy.inbreedingCoefficient!.toStringAsFixed(3)}',
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  for (int i = 1; i < genealogy.generations.length; i++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(generationLabel(i)),
                    ),
                ],
              ),
            ],
          );

    final pw.Widget timelineSection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text('Chronologie',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (state.timeline.isEmpty)
          pw.Text('Aucun évènement enregistré.')
        else
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              for (final AnimalTimelineEntry entry in state.timeline.take(20))
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(
                    '${formatDate(entry.date)} · ${entry.title}${entry.description != null ? ' — ${entry.description}' : ''}',
                  ),
                ),
            ],
          ),
      ],
    );

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(level: 0, child: pw.Text('Fiche ${animal.tagId}')), 
          identitySection,
          pw.SizedBox(height: 12),
          if (performanceSection != null) ...<pw.Widget>[performanceSection, pw.SizedBox(height: 12)],
          if (genealogySection != null) ...<pw.Widget>[genealogySection, pw.SizedBox(height: 12)],
          timelineSection,
        ],
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalDetailCubit, AnimalDetailState>(
      builder: (BuildContext context, AnimalDetailState state) {
        final Animal animal = state.animal;
        Widget body;
        switch (state.status) {
          case AnimalDetailStatus.initial:
          case AnimalDetailStatus.loading:
            body = const Center(child: CircularProgressIndicator());
            break;
          case AnimalDetailStatus.failure:
            body = Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.errorMessage ??
                          'Impossible de charger la fiche détaillée.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<AnimalDetailCubit>().load(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
            break;
          case AnimalDetailStatus.success:
            final List<Widget> sections = <Widget>[
              _IdentityCard(
                animal: animal,
                primaryPhoto:
                    state.gallery.isNotEmpty ? state.gallery.first : null,
              ),
              const SizedBox(height: 16),
              AnimalPerformanceOverview(performance: state.performance!),
              const SizedBox(height: 16),
              AnimalPhotoGallery(
                photos: state.gallery,
                onAddPhoto: () => _addPhoto(context),
                onRemovePhoto: state.gallery.isEmpty
                    ? null
                    : (String url) => _removePhoto(context, url),
              ),
              const SizedBox(height: 16),
              GenealogyView(
                animal: animal,
                analysis: state.genealogy,
              ),
              const SizedBox(height: 16),
              AnimalTimeline(entries: state.timeline),
            ];

            body = RefreshIndicator(
              onRefresh: () => context.read<AnimalDetailCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: sections,
              ),
            );
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(animal.name ?? animal.tagId),
            actions: state.status == AnimalDetailStatus.success
                ? <Widget>[
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      tooltip: 'Exporter en PDF',
                      onPressed: () => _exportPdf(context, state),
                    ),
                  ]
                : null,
          ),
          body: body,
        );
      },
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.animal,
    this.primaryPhoto,
  });

  final Animal animal;
  final String? primaryPhoto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (primaryPhoto != null)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                primaryPhoto!,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Identité', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(label: Text(animal.sex)),
                    Chip(label: Text(animal.status)),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Tag', value: animal.tagId),
                if (animal.name != null)
                  _InfoRow(label: 'Nom', value: animal.name!),
                _InfoRow(
                  label: 'Cage',
                  value: animal.cageNumber ?? 'Non renseignée',
                ),
                _InfoRow(
                  label: 'Origine',
                  value: animal.origin ?? 'Non renseignée',
                ),
                _InfoRow(
                  label: 'Date de naissance',
                  value: MaterialLocalizations.of(context)
                      .formatMediumDate(animal.birthDate),
                ),
                _InfoRow(
                  label: 'Date d’entrée',
                  value: animal.entryDate != null
                      ? MaterialLocalizations.of(context)
                          .formatMediumDate(animal.entryDate!)
                      : 'Non renseignée',
                ),
                if (animal.firstBreedingDate != null)
                  _InfoRow(
                    label: '1ère saillie',
                    value:
                        '${MaterialLocalizations.of(context).formatMediumDate(animal.firstBreedingDate!)} · ${animal.firstBreedingDate!.difference(animal.birthDate).inDays} jours',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
