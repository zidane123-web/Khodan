# Implementer le suivi reproduction et cycles

## Objectif / But
Permettre le suivi detaille des cycles de reproduction avec notifications et rapports dedies.

## Etapes concretes
- Implementer la timeline reproduction et les vues calendrier selon les maquettes.
- Connecter les formulaires aux repositories `BreedingRepository` et `EventRepository`.
- Ajouter les calculs automatiques de dates (gestation, rappel) et generer les notifications.
- Mettre a disposition les exports de cycles au format PDF/CSV.
- Ecrire des tests d integration autour des regles de calcul.

## Fichiers ou modules concernes
- `lib/features/events/presentation`
- `lib/data/repositories/breeding_repository.dart`
- `plan/011_DesignerSuiviReproduction.md`

## Resultat attendu / Critere de reussite
- Suivi reproduction operationnel avec rappels automatiques et exports.

## Prerequis eventuels
- 032_ImplGestionAnimaux.md

