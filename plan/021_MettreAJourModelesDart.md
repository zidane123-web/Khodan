# Mettre a jour les modeles Dart

## Objectif / But
Actualiser les classes des modeles pour prendre en compte les nouvelles colonnes, relations et validations.

## Etapes concretes
- Reviser `lib/data/models` et lister les modeles existants.
- Ajouter les nouveaux modeles (Finance, Stock, Notification, Task) et les enums associes.
- Mettre a jour les factories `fromJson` et `toJson` pour refleter le schema.
- Implementer des tests unitaires pour garantir la serialization correcte.
- Documenter les changements majeurs dans le changelog technique.

## Fichiers ou modules concernes
- `lib/data/models`
- `test/data/models`
- `plan/017_NormaliserSupabaseTables.md`

## Resultat attendu / Critere de reussite
- Modeles Dart synchronises avec le backend et couverts par des tests de serialization.

## Prerequis eventuels
- 017_NormaliserSupabaseTables.md

