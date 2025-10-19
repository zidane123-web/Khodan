# Maintenance des KPI du dashboard

Ce guide resume les verifications a effectuer lorsqu'un nouvel indicateur doit etre ajoute au tableau de bord.

1. **Enum et ordres par defaut**  
   - Ajouter la nouvelle valeur dans `DashboardKpiType`.  
   - Mettre a jour les listes `kpiOrder` par defaut dans `DashboardState` et dans la feuille de personnalisation si l'indicateur doit etre visible immediatement.

2. **Preferences persistees**  
   - Les ordres et modules sont stockes dans `DashboardPreferences`.  
   - Les methodes `_mergeKpiOrder`, `_mergeModuleOrder` et `_decodeHiddenModules` de `DashboardCubit` tolerent les valeurs inconnues. Assurez-vous qu'elles couvrent le nouvel enum (sinon l'utilisateur pourrait perdre sa configuration).  
   - Aucun nettoyage de base de donnees n'est requis: une nouvelle valeur absente dans le JSON sera ajoutee automatiquement a la fin des listes merges.

3. **Agrégations backend**  
   - Etendre la fonction RPC `get_dashboard_snapshot` (ou la vue associee) pour inclure la nouvelle metrique.  
   - Si un filtrage rapide est necessaire, renseigner `kpi_filters` dans la reponse avec l'ensemble des identifiants ou filtres a appliquer.

4. **Mapping cote Flutter**  
   - Ajuster `_buildKpiPresentation` pour traduire la valeur en titre/sous-titre compréhensible.  
   - Lorsque le KPI doit rediriger vers une liste filtre, ajouter l'entree correspondante dans `_mapSnapshotFilters` ou, en fallback, dans la construction locale des filtres.

5. **Tests**  
   - Ajouter un cas dans les tests unitaires (snapshot et fallback) pour garantir que le nouvel indicateur apparait et que les preferences existantes ne declenchent pas d'exception.

En suivant ces etapes, les mises a jour conservent les configurations existantes et evitent les regressions sur le chargement du dashboard.
