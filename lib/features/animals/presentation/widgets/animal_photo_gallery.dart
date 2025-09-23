import 'package:flutter/material.dart';

class AnimalPhotoGallery extends StatelessWidget {
  const AnimalPhotoGallery({
    required this.photos,
    required this.onAddPhoto,
    this.onRemovePhoto,
    super.key,
  });

  final List<String> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<String>? onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Galerie photo',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Ajouter une photo',
                  onPressed: onAddPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (photos.isEmpty)
              Text(
                'Ajoutez vos premières photos pour suivre l’évolution de cet animal.',
                style: theme.textTheme.bodyMedium,
              )
            else
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
                  final String photo = photos[index];
                  return _GalleryTile(
                    url: photo,
                    onRemove: onRemovePhoto,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.url, this.onRemove});

  final String url;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              );
            },
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.5).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  iconSize: 18,
                  onPressed: () => onRemove!(url),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}