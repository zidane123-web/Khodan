# Tableau de bord personnalisable et metriques temps reel

## Objectif
- Connecter `DashboardCubit` aux aggregations backend (vues ou RPC definies tache 02) au lieu de recalculer cote client.
- Persister l'ordre des KPI et modules (`state.kpiOrder`, `state.moduleOrder`, `hiddenModules`) par utilisateur/profil.
- Enrichir le dashboard avec les rappels d'inventaire, alertes sanitaires et taches issues des referentiels.

## Livrables
- Mise a jour de `DashboardCubit` et widgets associes pour consommer les nouvelles donnees (gestion des etats chargement/erreur).
- Points de sauvegarde des preferences (Supabase ou Drift) et restauration au demarrage.
- Tests unitaires sur `DashboardCubit` et tests widget sur `DashboardScreen` validant la personnalisation (drag & drop ou reordre via bottom sheet).

## Notes techniques
- Veiller a limiter les appels reseau (memoization, cache local) pour ne pas alourdir le chargement du dashboard.
- Les rappels doivent se baser sur les `BreedingReminder` et la file offline afin d'etre coherents en mode hors-ligne.
- Documenter la marche a suivre pour ajouter de nouveaux KPI sans casser la persistence existante (gestion des valeurs manquantes).
