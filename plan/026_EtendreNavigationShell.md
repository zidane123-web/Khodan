# Etendre la navigation et le shell d application

## Objectif / But
Adapter le router GoRouter pour supporter les nouveaux modules, la navigation conditionnelle et les deep links.

## Etapes concretes
- Ajouter les routes pour onboarding, finances, stocks, notifications et profils.
- Mettre en place des guard routes selon roles et statut d abonnement.
- Configurer les deep links et liens partages (web) pour les rapports ou fiches animaux.
- Verifier la coherence des transitions et animations entre ecrans.
- Ecrire des tests de navigation avec `go_router` testing utilities.

## Fichiers ou modules concernes
- `lib/app/config/router.dart`
- `lib/features/onboarding`
- `lib/features/finances`
- `lib/features/inventory`
- `lib/features/notifications`

## Resultat attendu / Critere de reussite
- Navigation GoRouter couvrant tous les modules avec tests automatisees.

## Prerequis eventuels
- 025_RenforcerInitialisationApp.md

