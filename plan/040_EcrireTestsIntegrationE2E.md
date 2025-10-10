# Ecrire les tests d integration et E2E

## Objectif / But
Garantir les parcours critiques via tests d integration et end-to-end sur environnements proches de la prod.

## Etapes concretes
- Configurer un environnement de test Supabase dedie avec jeux de donnees seeds.
- Ecrire des tests integration (flutter test integration_test) pour onboarding, auth, creation animal, vente.
- Mettre en place des tests E2E sur mobile (Firebase Test Lab ou Codemagic) couvrant scenario offline/online.
- Automatiser la generation de rapports (videos, captures, logs).
- Bloquer le critere de merge sur la reussite de ces tests.

## Fichiers ou modules concernes
- `integration_test/`
- `supabase/.temp`
- `plan/039_EcrireTestsWidgetsEtFlux.md`

## Resultat attendu / Critere de reussite
- Suite integration/E2E fiable executant les parcours critiques a chaque merge.

## Prerequis eventuels
- 039_EcrireTestsWidgetsEtFlux.md

