# Task 17 - Renforcer la securite Supabase (support & triggers)

## Objectif
- Etendre les politiques RLS et triggers a la table `support_requests` pour aligner la securite sur le reste du schema.
- Harmoniser les triggers `tg_maintain_timestamps` et les permissions `GRANT` pour evitar des erreurs en production.
- Mettre a jour la documentation Supabase pour couvrir ces nouvelles regles.

## Livrables
- Nouveau fichier de migration (ex: `20251020110000_support_requests_security.sql`) applique et versionne.
- Mise a jour de `supabase/README.md` detaillant les politiques RLS et les roles autorises.
- Verification PostgREST (via curl ou `supabase functions invoke`) confirmant qu'un utilisateur authentifie ne voit que ses tickets.

## Etapes
1. Creer une migration qui:
   - Active RLS sur `public.support_requests`.
   - Ajoute les politiques `ALL` filtrant sur `profile_id = auth.uid()` et le role `service_role`.
   - Ajoute les triggers `tg_maintain_timestamps` (insert/update) si absents.
   - Definie les `GRANT` pour `authenticated` et `service_role` selon les besoins.
2. Executer la migration localement (`supabase migration new ...`, `supabase db push`) puis sur l'environnement de dev.
3. Ecrire un test manuel:
   - Insertion avec le `service_role` (doit passer).
   - Consultation avec un anon key (doit echouer).
4. Mettre a jour `supabase/README.md` avec la marche a suivre pour verifier la securite de `support_requests`.
5. Communiquer la dependance de Task 20 (formulaire de support) sur cette migration dans le plan ou le changelog.

## Dependances
- Task 16 terminee (base a jour).
- Acces au projet Supabase et au CLI.

