# Configurer les politiques RLS Supabase

## Objectif / But
Mettre en place des politiques RLS et roles specifiques garantissant la separation des donnees par ferme et utilisateur.

## Etapes concretes
- Activer RLS sur toutes les tables sensibles.
- Ecrire des policies pour restreindre l acces aux utilisateurs appartenant a la meme ferme ou equipe.
- Introduire des fonctions helpers (auth.required_role) pour simplifier les policies complexes.
- Tester les policies avec des scenarii (utilisateur actif/inactif, invitation equipe).
- Documenter les procedures de debug et la maintenance RLS.

## Fichiers ou modules concernes
- `supabase/migrations`
- `supabase/.temp`
- `plan/017_NormaliserSupabaseTables.md`

## Resultat attendu / Critere de reussite
- Policies RLS appliquees, testees et documentees pour un deploiement securise.

## Prerequis eventuels
- 017_NormaliserSupabaseTables.md

