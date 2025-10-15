# Persistance hors-ligne avec Drift

## Objectif
- Introduire une base locale (Drift) reflechant les tables critiques (animaux, saillies, evenements, profils, species_config).
- Assurer la lecture offline des listes et details (AnimalList, AnimalDetail, EventsHub, Dashboard) en s'appuyant sur des DAOs Drift.
- Synchroniser les horodatages / versions pour detecter les divergences lors du retour en ligne.

## Livrables
- Schema Drift dans `lib/data/local/` (fichiers `.drift` ou classes Dart) avec generation via `build_runner`.
- Services synchrones/asynchrones encapsulant l'acces local (ex. `LocalAnimalDataSource`) et integres dans les Cubits existants.
- Documentation de la strategie de migration locale (gestion du bump schema, wipe en cas de diff irreconciliable).

## Notes techniques
- Utiliser des conversions JSON pour stocker les objets complexes (`LivestockEvent.details`).
- Prevoir une colonne `updated_at` et un `sync_state` pour chaque enregistrement afin d'alimenter la file de synchro.
- Ajouter des tests widget/offline validant que l'application fonctionne sans connexion (utiliser `connectivity_plus` en mode offline force).
