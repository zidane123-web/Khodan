# Tâche 03 - Auditer la base Supabase et préparer les migrations

## Objectif
Connaitre l’état réel de la base (tables, policies, triggers) et définir une méthode fiable pour exécuter les futures migrations même en cas de blocage du CLI.

## Sous-tâches
1. Lister toutes les tables existantes via le SQL Editor Supabase (`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';`) et consigner le résultat dans `docs/everbreed-gap-analysis.md` (section base de données).
2. Vérifier les triggers et RLS clés (`support_requests`, `event_templates`, `food_types`, `food_stock`, `knowledge_articles`) et noter s’ils sont déjà en place.
3. Documenter, dans `docs/supabase-execution-guide.md`, deux méthodes d’exécution :
   - Méthode A : CLI (`supabase db push`) avec rappel des problèmes possibles.
   - Méthode B : SQL Editor (copier/coller la migration + insertion dans `schema_migrations`).
4. Établir une liste des migrations futures à prévoir (ex. nouvelles tables pour finances, santé, abonnements) sans les écrire pour l’instant.

## Livrables
- Mise à jour de `docs/everbreed-gap-analysis.md` (partie base de données).
- Nouveau fichier `docs/supabase-execution-guide.md`.

## Notes
- Toujours sauvegarder les requêtes SQL exécutées (copier/coller dans le guide).
- Pas de modification de schéma ici, uniquement de la documentation.
