# Mesurer et optimiser les performances

## Objectif / But
Analyser et optimiser les performances (rendering, memoire, temps de chargement, poids) sur toutes les plateformes.

## Etapes concretes
- Utiliser Flutter DevTools pour profiler les ecrans lourds (dashboard, listes).
- Optimiser les requetes (pagination, indexes Supabase, caches).
- Reduire le poids des assets et configurer lazy loading pour les medias.
- Verifier la consommation memoire et CPU sur devices cibles.
- Documenter les optimisations appliquees et les metrics obtenues.

## Fichiers ou modules concernes
- `lib/features/dashboard`
- `lib/features/animals`
- `supabase/migrations`
- `plan/040_EcrireTestsIntegrationE2E.md`

## Resultat attendu / Critere de reussite
- Performances dans les seuils definis (temps d ouverture <3s, scroll fluide) avec rapport de profiling.

## Prerequis eventuels
- 040_EcrireTestsIntegrationE2E.md

