import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khodan/data/models/animal_media.dart';
import 'package:khodan/features/animals/presentation/widgets/animal_photo_gallery.dart';

void main() {
  testWidgets('renders explicit add button and triggers callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalPhotoGallery(
            photos: const <AnimalMedia>[],
            onAddPhoto: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ajouter une photo'));

    expect(tapped, isTrue);
  });

  testWidgets('shows uploading indicator when uploading', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalPhotoGallery(
            photos: <AnimalMedia>[
              AnimalMedia(
                id: 'm1',
                profileId: 'profile',
                animalId: 'a1',
                storagePath: 'media/m1',
                createdAt: DateTime(2024, 1, 1),
                updatedAt: DateTime(2024, 1, 1),
              ),
            ],
            onAddPhoto: () {},
            isUploading: true,
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}

