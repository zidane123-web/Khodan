# Politiques RLS et automatisations Supabase

## Objectif
- Mettre en place une securite multi-locataire stricte basee sur l'ID Supabase Auth pour toutes les tables creees a la tache 01.
- Automatiser la generation de metriques (ex. statistiques de reproduction, rappels d'echeances) et la gestion des horodatages via triggers ou fonctions Edge.
- Offrir des points d'entree efficaces pour le tableau de bord (vues materialisees ou RPC) tout en limitant la complexite cote Flutter.

## Livrables
- Scripts SQL ajoutant: activation RLS, politiques `SELECT/INSERT/UPDATE/DELETE`, fonctions utilitaires (ex. `public.upsert_breeding_metrics`), triggers `updated_at`, et vues agregees (ex. `dashboard_kpis`).
- Tests manuels documentes (commande `supabase db reset && supabase db remote commit`) validant que les policies bloquent bien un utilisateur tiers.
- Guide succinct dans `plan/` ou `supabase/README.md` expliquant comment recuperer les metriques via RPC pour `DashboardCubit`.

## Notes techniques
- Utiliser `auth.uid()` dans les policies; prevoir une policy de lecture globale uniquement pour les referentiels publics s'il y en a.
- Pour les vues agregees, optimiser les jointures afin de limiter le nombre d'appels depuis Flutter (regrouper animals + breeding + events en une seule vue).
- Les triggers doivent etre idempotents pour supporter la synchronisation offline (ex. ignorer les updates si les valeurs ne changent pas).
- Evaluer l'ajout d'une fonction `rpc.sync_payload` permettant de pousser un lot d'operations offline en une transaction atomique.
