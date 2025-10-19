# Gestion des medias et assets

## Objectif
- Permettre l'upload des photos animaux vers Supabase Storage (avec dossiers par profil) et leur affichage offline (cache local).
- Ameliorer `AnimalPhotoGallery` et `AnimalFormScreen` pour gerer camera, recadrage (`image_cropper`) et upload asynchrone/securise.
- Ajouter la generation/affichage de QR codes (ou etiquettes) pour chaque animal afin de faciliter le scan depuis `ScanAnimalScreen`.

## Livrables
- Service d'upload (`MediaRepository`) gerant authentification, compression, et retour d'URL signee.
- Cache local (ex. `path_provider` + `cached_network_image` ou integration `flutter_cache_manager`) pour limiter la bande passante.
- Mise a jour de l'UI (progress indicators, gestion des erreurs upload) et documentation sur la taille/format des images recommandee.

## Notes techniques
- Verifier les regles de securite storage (RLS Storage) pour interdire l'acces inter-profil.
- Les uploads doivent etre en file d'attente en mode offline et publies a la reconnexion (integration avec OfflineSyncManager).
- Pour les QR codes, generer un contenu standard (ex. JSON avec `animal_id`) et prevoir une option d'impression/export.
