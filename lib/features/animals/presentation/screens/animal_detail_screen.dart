import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/animal_media.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/breeding_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../domain/genealogy_analyzer.dart';
import '../cubit/animal_detail_cubit.dart';
import '../widgets/animal_performance_overview.dart';
import '../widgets/animal_photo_gallery.dart';
import '../widgets/animal_timeline.dart';
import '../widgets/genealogy_view.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({required this.animal, super.key});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalDetailCubit>(
      create: (BuildContext context) => AnimalDetailCubit(
        animal,
        context.read<AnimalRepository>(),
        context.read<BreedingRepository>(),
        context.read<EventRepository>(),
        context.read<MediaRepository>(),
      )..load(),
      child: const _AnimalDetailView(),
    );
  }
}

class _AnimalDetailView extends StatelessWidget {
  const _AnimalDetailView();

  Future<void> _addPhoto(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Depuis la galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked == null || !context.mounted) {
      return;
    }

    CroppedFile? cropped;
    try {
      cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: <CropAspectRatioPreset>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Recadrer la photo',
            aspectRatioLockEnabled: false,
            aspectRatioPresets: <CropAspectRatioPreset>[
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );
    } catch (_) {
      cropped = null;
    }

    final String targetPath = cropped?.path ?? picked.path;
    if (!context.mounted) {
      return;
    }
    final AnimalDetailCubit cubit = context.read<AnimalDetailCubit>();
    await cubit.uploadPhoto(targetPath);

    if (cropped != null && cropped.path != picked.path) {
      final File original = File(picked.path);
      try {
        if (await original.exists()) {
          await original.delete();
        }
      } catch (_) {}
    }
  }

  Future<void> _removePhoto(BuildContext context, AnimalMedia media) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer cette photo ?'),
          content: const Text(
            'La photo sera retirée de la galerie. Continuer ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<AnimalDetailCubit>().removeMedia(media);
    }
  }

  void _showQrCode(BuildContext context, Animal animal) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'type': 'khodan.animal',
      'version': 1,
      'animal_id': animal.id,
      'tag': animal.tagId,
      'species_id': animal.speciesId,
    };
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) =>
          _AnimalQrSheet(animal: animal, payload: jsonEncode(payload)),
    );
  }

  Future<void> _exportPdf(BuildContext context, AnimalDetailState state) async {
    final Animal animal = state.animal;
    final pw.Document doc = pw.Document();
    final String filename = 'animal-${animal.tagId}.pdf';

    String formatDate(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final pw.Widget identitySection = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Identité',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
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
              pw.Text(
                'Performances',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Saillies : ${performance.totalMatings}'),
              pw.Text('Réussites : ${performance.successfulMatings}'),
              if (performance.successRate != null)
                pw.Text(
                  'Taux de réussite : ${(performance.successRate! * 100).toStringAsFixed(1)} %',
                ),
              if (performance.averageKitsBornAlive != null)
                pw.Text(
                  'Nés vivants moyens : ${performance.averageKitsBornAlive!.toStringAsFixed(1)}',
                ),
              if (performance.averageKitsWeaned != null)
                pw.Text(
                  'Sevrés moyens : ${performance.averageKitsWeaned!.toStringAsFixed(1)}',
                ),
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
          .map(
            (Animal? ancestor) => ancestor == null ? 'Inconnu' : ancestor.tagId,
          )
          .join(', ');
      return 'Génération $index : $joined';
    }

    final pw.Widget? genealogySection = genealogy == null
        ? null
        : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'Généalogie',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
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
        pw.Text(
          'Chronologie',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
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
          if (performanceSection != null) ...<pw.Widget>[
            performanceSection,
            pw.SizedBox(height: 12),
          ],
          if (genealogySection != null) ...<pw.Widget>[
            genealogySection,
            pw.SizedBox(height: 12),
          ],
          timelineSection,
        ],
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimalDetailCubit, AnimalDetailState>(
      listenWhen: (AnimalDetailState previous, AnimalDetailState current) =>
          previous.mediaMessage != current.mediaMessage &&
          current.mediaMessage != null,
      listener: (BuildContext context, AnimalDetailState state) {
        final String? message = state.mediaMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: BlocBuilder<AnimalDetailCubit, AnimalDetailState>(
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
                  primaryPhoto: state.gallery.isNotEmpty
                      ? state.gallery.first
                      : null,
                ),
                const SizedBox(height: 16),
                if (state.performance != null) ...<Widget>[
                  AnimalPerformanceOverview(performance: state.performance!),
                  const SizedBox(height: 16),
                ],
                AnimalPhotoGallery(
                  photos: state.gallery,
                  onAddPhoto: () => _addPhoto(context),
                  onRemovePhoto: state.gallery.isEmpty
                      ? null
                      : (AnimalMedia media) => _removePhoto(context, media),
                  isLoading: state.galleryLoading,
                  isUploading: state.isUploadingMedia,
                ),
                const SizedBox(height: 16),
                GenealogyView(animal: animal, analysis: state.genealogy),
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
                        icon: const Icon(Icons.qr_code_2_outlined),
                        tooltip: 'Afficher le QR code',
                        onPressed: () => _showQrCode(context, animal),
                      ),
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
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.animal, this.primaryPhoto});

  final Animal animal;
  final AnimalMedia? primaryPhoto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 180,
            width: double.infinity,
            child: _PrimaryPhoto(media: primaryPhoto),
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
                  value: MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(animal.birthDate),
                ),
                _InfoRow(
                  label: 'Date d’entrée',
                  value: animal.entryDate != null
                      ? MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(animal.entryDate!)
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

class _PrimaryPhoto extends StatelessWidget {
  const _PrimaryPhoto({this.media});

  final AnimalMedia? media;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (media == null) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.photo_size_select_actual_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final String? localPath = media!.localPath;
    if (localPath != null) {
      final File file = File(localPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    if (media!.signedUrl != null && media!.signedUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: media!.signedUrl!,
        fit: BoxFit.cover,
        placeholder: (BuildContext context, String _) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const CircularProgressIndicator.adaptive(),
        ),
        errorWidget: (BuildContext context, String _, Object __) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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

class _AnimalQrSheet extends StatelessWidget {
  const _AnimalQrSheet({required this.animal, required this.payload});

  final Animal animal;
  final String payload;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('QR code – ${animal.tagId}', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: payload,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scannez ce code avec l’app Khodan pour ouvrir la fiche de ${animal.name ?? animal.tagId}.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SelectableText(
            payload,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: payload));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payload copié dans le presse-papiers.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copier'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
