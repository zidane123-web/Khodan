# Tâche 05 - Refondre le tableau de bord Khodan

## Objectif
Créer un tableau de bord inspiré d’Everbreed avec actions rapides, indicateurs clés et aperçu du planning.

## Sous-tâches
1. Définir dans `docs/dashboard-spec.md` les sections à afficher : message de bienvenue, actions rapides, menu « + », indicateurs, planning des tâches.
2. Implémenter un widget `DashboardScreen` réorganisé :
   - Actions rapides (Saillie, Mise bas, Pesée, Abattage) avec boutons stylés.
   - Menu « + » qui ouvre un `BottomSheet` listant les ajouts rapides.
   - Cartes d’indicateurs (utiliser des placeholders chiffrés tant que les données ne sont pas prêtes).
   - Section planning affichant les tâches à venir (utiliser un mock ou récupérer les tâches réelles si disponibles).
3. Prévoir des fonctions placeholder (ex. `onCreateBreeding()`) pour faciliter l’intégration future.
4. Vérifier l’absence d’avertissements Flutter (ex. `flutter analyze`).
5. Mettre à jour les tests existants ou ajouter un test widget minimal (`test/features/dashboard/...`) pour s’assurer que les sections principales s’affichent.

## Livrables
- Fichier `docs/dashboard-spec.md`.
- Nouveau code Flutter du tableau de bord avec tests verts.

## Notes
- Les textes doivent être en français et compréhensibles par un débutant.
- Si des dépendances (données Supabase) manquent, utiliser des valeurs temporaires documentées dans le spec.
