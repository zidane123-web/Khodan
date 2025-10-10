# Mettre en place CI/CD complet

## Objectif / But
Configurer une pipeline CI/CD couvrant lint, tests, builds et depots sur les stores ou environnements.

## Etapes concretes
- Choisir l outil (GitHub Actions, GitLab CI, Codemagic) et creer les workflows.
- Integrer analyse statique (dart analyze, flutter format --set-exit-if-changed).
- Brancher les tests unitaires, widgets, integration et generer les rapports couverture.
- Automatiser la generation des builds (Android, iOS, Web) et les deploiements vers les stores ou Firebase Hosting.
- Configurer les notifications de pipeline et la gestion des secrets de build.

## Fichiers ou modules concernes
- `.github/workflows (a creer)`
- `codemagic.yaml (a creer)`
- `plan/040_EcrireTestsIntegrationE2E.md`

## Resultat attendu / Critere de reussite
- CI/CD fiable declenchee a chaque merge avec builds testes et artefacts disponibles.

## Prerequis eventuels
- 042_AssurerAccessibiliteI18n.md

