# Rationaliser les repositories et sources de donnees

## Objectif / But
Refactoriser les repositories pour integrer les nouveaux modeles, la mise en cache et la gestion des erreurs.

## Etapes concretes
- Cartographier les repositories existants dans `lib/data/repositories`.
- Introduire des interfaces abstraites et impl concret pour Supabase.
- Ajouter la gestion centralisee des erreurs et retours types (Result, Either).
- Integrer la mise en cache locale (Hive/Isar) pour le offline.
- Ecrire des tests unitaires avec mocks Supabase pour chaque repository.

## Fichiers ou modules concernes
- `lib/data/repositories`
- `lib/data/services`
- `plan/021_MettreAJourModelesDart.md`

## Resultat attendu / Critere de reussite
- Repositories homogenes, testes et prets a alimenter les use cases.

## Prerequis eventuels
- 021_MettreAJourModelesDart.md

