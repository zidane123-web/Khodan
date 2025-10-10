# Ecrire les tests unitaires de domaine et data

## Objectif / But
Garantir la qualite des couches domaine et data via une couverture de tests unitaire minimale de 80 %.

## Etapes concretes
- Identifier les use cases critiques (auth, animaux, finances, sync).
- Ecrire des tests unitaires pour chaque repository avec mocks Supabase.
- Tester les services (notification, sync) avec scenarios de succes et erreurs.
- Mettre en place la collecte de couverture (lcov) et l integrer a CI.
- Documenter les cas limites couverts et ceux a ajouter plus tard.

## Fichiers ou modules concernes
- `test/data`
- `test/domain (a creer)`
- `plan/022_RationaliserRepositories.md`

## Resultat attendu / Critere de reussite
- Couverture unitaire >80% sur data/domaine avec rapports de couverture integres.

## Prerequis eventuels
- 037_ImplParametresEtOffline.md

