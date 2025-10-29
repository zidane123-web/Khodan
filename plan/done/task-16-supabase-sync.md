# Task 16 - Synchroniser l'environnement Supabase de dev

## Objectif
- Rejouer toutes les migrations SQL presentes dans `supabase/migrations/` sur le projet reference dans `.env`.
- S'assurer que les tables critiques (`breeding_records`, `animals`, `events`, `food_stock`, etc.) existent et qu'elles sont peuplables depuis PostgREST.
- Documenter la procedure de verification pour les prochains environnements.

## Livrables
- Journal d'execution des commandes `supabase db remote commit` ou `psql` prouvant l'application des migrations.
- Capture ou sortie CLI listant les tables cibles dans `public`.
- Note rapide dans `supabase/README.md` indiquant la date de synchronisation et le projet touche.

## Etapes
1. Verifier que `SUPABASE_URL` et `SUPABASE_ANON_KEY` pointent vers l'environnement a synchroniser et que l'utilisateur est connecte au CLI (`supabase login`).
2. Executer `supabase db push` (ou `supabase db remote commit`) depuis la racine du projet pour envoyer les migrations `20251015110000_initial_schema.sql`, `20251015113000_security_rls.sql`, `20251018103000_extend_profiles_table.sql`, `20251018104500_support_requests.sql` et `add_features_tables`.
3. Si des conflits apparaissent, rejouer manuellement les fichiers en utilisant `psql` avec le role `service_role` et consigner les ajustements.
4. Controler la presence des tables attendues via `supabase db remote commit --dry-run` ou `SELECT * FROM information_schema.tables WHERE table_schema = 'public';`.
5. Tester rapidement via l'application (hot restart) qu'un ecran comme "Tableau de bord" ne remonte plus les erreurs `PGRST205`.
6. Ajouter la note de synthese dans `supabase/README.md` (section verification manuelle).

## Dependances
- Acces CLI au projet Supabase cible.
- Droits suffisants pour appliquer des migrations (role `service_role`).

