# Task 20 - Assainir les ecrans Evenements & saisie de saillies

## Objectif
- Garantir que l'onglet "Evenements" et les formulaires "Nouvelle saillie" / "Nouvel evenement" refleteront les donnees Supabase a jour.
- Corriger les cas ou des donnees obsoletes ou vides persistent apres synchronisation.
- Ajouter des tests widget pour couvrir les principaux flux utilisateur.

## Livrables
- Correctifs Flutter dans `features/events` (presentation + data) merges.
- Tests widget reproduisant un scenario standard (liste, creation, refresh).
- Notes de QA detaillees (sequence, donnees utilisees, captures).

## Etapes
1. Diagnostiquer la source des vues vides: verifier les appels au repository (`EventRepository`, `BreedingRepository`) et leur gestion des erreurs `DataLayerException`.
2. Ajuster les Cubits/Bloc pour mieux gerer les erreurs reseau (affichage snackbars, retry) au lieu d'effacer l'UI.
3. Verifier l'integration avec l'offline sync (`OfflineSyncManager`) pour eviter les doublons/apparitions de donnees legacy.
4. Revoir le routing (GoRouter) pour que "Nouvelle saillie" charge les bons Cubits/dep.
5. Ajouter des tests widget simulant un backend via `mocktail` ou stubs Supabase.
6. Documenter dans le changelog/plan le lien avec Task 22 (nettoyage des chaines).

## Dependances
- Task 19 (config data stable).
- Task 17 (RLS en place pour les nouvelles insertions).

