import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/animal_media.dart';

class AnimalPhotoGallery extends StatelessWidget {
  const AnimalPhotoGallery({
    required this.photos,
    required this.onAddPhoto,
    this.onRemovePhoto,
    this.isLoading = false,
    this.isUploading = false,
    super.key,
  });

  final List<AnimalMedia> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<AnimalMedia>? onRemovePhoto;
  final bool isLoading;
  final bool isUploading;

  bool get _hasPhotos => photos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: <Widget>[
                    Text(
                      'Galerie photo',
                      style: theme.textTheme.titleLarge,
                    ),
                    FilledButton.icon(
                      onPressed: onAddPhoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Ajouter une photo'),
                    ),
                  ],
                );
              },
            ),
            if (isUploading) ...<Widget>[
              const SizedBox(height: 4),
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ] else if (isLoading) ...<Widget>[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 12),
            if (!_hasPhotos && !isLoading)
              Text(
                'Ajoutez vos premières images pour suivre l’évolution de cet animal.',
                style: theme.textTheme.bodyMedium,
              )
            else if (_hasPhotos)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final AnimalMedia media = photos[index];
                  return _GalleryTile(media: media, onRemove: onRemovePhoto);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.media, this.onRemove});

  final AnimalMedia media;
  final ValueChanged<AnimalMedia>? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _MediaPreview(media: media),
          if (media.syncState == 'pending')
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_upload,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text('En attente', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  iconSize: 18,
                  onPressed: () => onRemove!(media),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Supprimer la photo',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.media});

  final AnimalMedia media;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? localPath = media.localPath;
    if (localPath != null) {
      final File file = File(localPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    if (media.signedUrl != null && media.signedUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: media.signedUrl!,
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
