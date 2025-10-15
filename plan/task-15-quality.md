# Internationalisation, qualite et pipeline de livraison

## Objectif
- Corriger les problemes d'encodage (utiliser `fix_encoding.py` ou integration directe) et etablir une base de traduction propre (arb francais, anglais a terme).
- Etendre la couverture de tests (unitaires, widget, integration) pour les Cubits critiques et les ecrans majeurs (auth, dashboard, events, settings).
- Mettre en place une CI/CD (GitHub Actions ou autre) executant `flutter analyze`, `flutter test`, build release et deploy (Firebase App Distribution/TestFlight/Play Store selon cible).

## Livrables
- Fichiers de localisation (`lib/l10n/*.arb`), configuration `MaterialApp` avec `AppLocalizations`, et mise a jour des textes statiques.
- Suite de tests modernisee (usage de mocks pour Supabase, tests offline) + mise a jour des anciens tests pour refléter la nouvelle UI.
- Workflow CI (`.github/workflows/ci.yml` par exemple) avec badges README, triggers sur PR/main, et instructions de release (CHANGELOG, versioning semantic).

## Notes techniques
- S'assurer que tous les nouveaux fichiers texte restent en UTF-8 et que les contributions futures utilisent la meme norme.
- Ajouter des scripts de verification (pre-commit ou commande `just`) pour lancer lint + format + tests avant push.
- Documenter le processus de release (increment version `pubspec.yaml`, generation des builds, publication store) dans `README.md` ou `RELEASE.md`.
