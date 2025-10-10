# Standardiser la gestion d etat

## Objectif / But
Aligner tous les modules sur une gestion d etat coherente, testable et scalables.

## Etapes concretes
- Inventorier les Cubits/Blocs actuels et identifier les modules sans gestion d etat claire.
- Definir les guidelines (Bloc vs Riverpod) et les conventions de dossiers.
- Extraire la logique metier dans des use cases/domaine pour simplifier les Cubits.
- Refactoriser les modules existants pour adopter les conventions et ajouter les tests.
- Documenter la structure et referencer dans le wiki projet.

## Fichiers ou modules concernes
- `lib/features/*/presentation/cubit`
- `lib/features/*/presentation/bloc`
- `plan/003_CadrerArchitectureGlobale.md`

## Resultat attendu / Critere de reussite
- Gestion d etat uniforme avec tests unitaires sur chaque Cubit/Bloc critique.

## Prerequis eventuels
- 026_EtendreNavigationShell.md

