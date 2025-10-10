# Implementer les widgets du dashboard

## Objectif / But
Developper le tableau de bord conforme aux maquettes et alimente par les donnees temps reel.

## Etapes concretes
- Implementer les widgets KPI dans `lib/features/dashboard/presentation/widgets`.
- Brancher les widgets aux use cases (production, finances, sante) avec gestion des etats.
- Optimiser les requetes pour limiter les appels simultanes (utiliser caching et combineLatest).
- Gerer les etats de chargement, erreur et vide.
- Ajouter des tests widget sur les composants critiques.

## Fichiers ou modules concernes
- `lib/features/dashboard/presentation`
- `lib/data/repositories`
- `plan/009_DesignerTableauDeBord.md`

## Resultat attendu / Critere de reussite
- Tableau de bord complet, performant et teste sur les cas principaux.

## Prerequis eventuels
- 030_ImplGestionProfilsUtilisateurs.md

