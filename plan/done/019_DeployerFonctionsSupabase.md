# Deployer les fonctions et triggers Supabase

## Objectif / But
Mettre en place les fonctions stockees, triggers et edge functions necessaires aux flux metiers critiques.

## Etapes concretes
- Lister les automatisations requises (calcul KPIs, notifications, generation reference factures).
- Ecrire les fonctions SQL ou edge functions (TypeScript) correspondantes.
- Brancher les triggers sur insert/update/delete pour maintenir la coherence des donnees.
- Mettre en place des tests unitaires sur les fonctions (via supabase tests ou scripts).
- Preparer les scripts de deploiement et la documentation d exploitation.

## Fichiers ou modules concernes
- `supabase/functions (a creer)`
- `supabase/migrations`
- `plan/018_ConfigurerRLSSupabase.md`

## Resultat attendu / Critere de reussite
- Fonctions et triggers deployables avec tests assures pour les flux metiers critiques.

## Prerequis eventuels
- 018_ConfigurerRLSSupabase.md

