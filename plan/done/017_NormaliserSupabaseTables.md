# Normaliser les tables Supabase

## Objectif / But
Creer les migrations Supabase necessaires pour disposer des tables, colonnes et contraintes definies lors du cadrage.

## Etapes concretes
- Creer une branche migrations dediee dans `supabase/migrations`.
- Ecrire les migrations SQL pour ajouter ou modifier les tables manquantes (finances, stocks, notifications).
- Mettre a jour les relations, index et contraintes de cle etrangere.
- Executer `supabase db reset` sur un environnement local et verifier l etat du schema.
- Documenter les migrations et leur impact dans le changelog backend.

## Fichiers ou modules concernes
- `supabase/migrations`
- `plan/004_PlanifierSchemaSupabase.md`

## Resultat attendu / Critere de reussite
- Schema Supabase aligne avec le plan cible et migrations versionnees pret pour review.

## Prerequis eventuels
- 004_PlanifierSchemaSupabase.md

