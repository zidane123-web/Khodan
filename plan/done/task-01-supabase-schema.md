# Modele de donnees Supabase complet

## Objectif
- Concevoir un schema relationnel exhaustif couvrant profils, animaux, genealogies, saillies, evenements, inventaire aliments et parametres d'elevage.
- Documenter les types, contraintes et index garantissant l'integrite des donnees et les performances attendues par les ecrans Flutter existants.
- Preparer la migration initiale (ou un lot ordonne de migrations) compatible avec le projet Supabase hebergeant deja le fichier `add_features_tables`.

## Livrables
- Fichiers SQL dans `supabase/migrations/` definissant les tables suivantes au minimum: `profiles`, `species_config`, `animals`, `breeding_records`, `breeding_metrics`, `events`, `animal_events`, `event_templates`, `food_types`, `food_stock`, `sync_queue`, ainsi que les sequences/index associes.
- Documentation technique (README ou commentaire) listant les relations clefs, les colonnes obligatoires/optionnelles, et les regles de nettoyage cascade.
- Jeu de donnees de demarrage optionnel (INSERT) limite aux informations utiles aux tests locaux.

## Notes techniques
- Harmoniser les noms de colonnes avec les modeles Dart existants (`profile_id`, `species_id`, etc.) pour eviter les conversions supplementaires dans `lib/data/models/`.
- Prevoir des colonnes systeme standard (`created_at`, `updated_at`, `deleted_at`) pour permettre l'archivage logique et la synchronisation hors ligne.
- Ajouter des index composites sur les colonnes filtrees frequemment (ex. `(profile_id, species_id)` sur `animals`, `(profile_id, event_date)` sur `events`).
- S'assurer que toutes les contraintes de cle etrangere utilisent `ON DELETE CASCADE` ou `SET NULL` selon les besoins de l'UI (ex. suppression d'un animal doit propager vers `animal_events`).
- Tenir compte de la future integration Drift: un identifiant stable et deterministe (UUID) est prefere pour les tables ecriture depuis le mobile.
