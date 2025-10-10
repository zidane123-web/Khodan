# Implementer la gestion complete des animaux

## Objectif / But
Offrir un module animaux robuste permettant lecture, edition, suppression, import et actions de masse.

## Etapes concretes
- Refactoriser `AnimalListScreen` pour integrer filtres, recherche et pagination.
- Implementer la fiche detaillee avec onglets et charts (sante, reproduction, documents).
- Creer les formulaires d ajout/modification avec validations et upload de medias.
- Ajouter les actions batch (export, marquer traitement, assigner tag).
- Couverture par tests widget et integration sur les flux critiques.

## Fichiers ou modules concernes
- `lib/features/animals/presentation`
- `lib/data/repositories/animal_repository.dart`
- `plan/010_DesignerGestionAnimaux.md`

## Resultat attendu / Critere de reussite
- Module animaux complet, stable et teste couvrant l ensemble des operations necessaires.

## Prerequis eventuels
- 031_ImplDashboardWidgets.md

