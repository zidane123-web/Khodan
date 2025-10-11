# Renforcer l initialisation de l application

## Objectif / But
Mettre en place un bootstrap robuste chargeant configuration, analytics, crash reporting et services critiques.

## Etapes concretes
- Centraliser la configuration (Supabase, Firebase, sentry) dans `lib/app/core/constants.dart`.
- Ajouter la gestion des environnements (dev, staging, prod) via fichiers `.env` ou flavors.
- Initialiser les services critiques (logger, crashlytics) avant `runApp`.
- Mettre en place un guard pour detecter les secrets manquants et afficher un ecran d erreur clair.
- Ecrire des tests smoke sur l initialisation.

## Fichiers ou modules concernes
- `lib/main.dart`
- `lib/app/core/constants.dart`
- `lib/app/core/bootstrap (a creer)`

## Resultat attendu / Critere de reussite
- Bootstrap applicatif fiable avec gestion d environnements et verifications d erreurs.

## Prerequis eventuels
- 024_ImplServiceNotifications.md

