# Flux evenements et reproduction relies a Supabase

## Objectif
- Faire en sorte que les ecrans `AddBreedingRecordScreen`, `AddEventScreen`, `BatchEventFormDialog` s'appuient sur les repositories Supabase et la file offline.
- Normaliser la validation des formulaires (dates coherentes, quantites positives, verification des animaux existants).
- Synchroniser les rappels (palpation, mise bas, sevrage) avec le backend pour les notifications et le dashboard.

## Livrables
- Mise a jour des formulaires avec gestion complete des etats (chargement, succes, erreur) et integration `OfflineSyncManager`.
- Refonte des Cubits `BreedingCubit` et `EventsCubit` pour qu'ils declenchent une recharge apres chaque operation, meme offline.
- Tests widget couvrant la creation/edition/suppression de saillies et d'evenements, y compris en mode hors-ligne.

## Notes techniques
- Appliquer les regles metiers definies (ex. date d'entree >= date de naissance) et afficher des messages clairs.
- Les liens `AnimalEventLink` doivent etre crees avec transactions afin d'eviter les evenements orphelins.
- Prevoir des conversions timezone coherentes (toutes les dates en UTC en base, locales pour l'affichage).
