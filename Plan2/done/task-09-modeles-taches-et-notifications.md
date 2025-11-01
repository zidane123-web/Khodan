# Tâche 09 - Modèles de tâches et notifications

## Objectif
Mettre en place un système de gabarits de tâches (reproduction, santé) et un moteur de notifications simple.

## Sous-tâches
1. Dans `docs/schedule-spec.md`, ajouter une section « Modèles » expliquant les champs nécessaires (nom, type, délai en jours, actions associées).
2. Créer les tables Supabase nécessaires (ex. `task_templates`, `task_template_steps`) via une migration documentée. Si le CLI échoue, utiliser la méthode SQL Editor décrite dans `docs/supabase-execution-guide.md`.
3. Implémenter dans Flutter un écran de gestion des modèles (liste, ajout, modification, suppression) et l’attribution d’un modèle à une portée ou à un traitement.
4. Mettre en place un service de notifications : commencer par les notifications locales (Flutter) et prévoir des hooks pour e-mail/SMS. Documenter dans `docs/notifications-plan.md` l’architecture retenue.
5. Tester la création d’un modèle, l’application à une portée et la génération des tâches correspondantes.

## Livrables
- Migration Supabase dédiée (fichier dans `supabase/migrations` + note dans README).
- Écrans Flutter pour la gestion des modèles.
- Document `docs/notifications-plan.md`.

## Notes
- Toujours noter les étapes manuelles (ex. insertion dans `schema_migrations` si SQL Editor).
- Vérifier les logs pour déceler toute erreur et les corriger avant de conclure la tâche.
