# Tâche 10 - Module santé (maladies et dossiers)

## Objectif
Créer une section Santé complète avec bibliothèque d’affections, dossiers de santé et liens avec les modèles de traitements.

## Sous-tâches
1. Définir les champs nécessaires dans `docs/health-spec.md` (maladie, symptômes, traitements, dates, statut).
2. Créer ou compléter les tables Supabase (ex. `ailments`, `health_records`, `health_treatments`). Documenter les migrations et utiliser le SQL Editor si besoin.
3. Implémenter les écrans Flutter :
   - Liste des maladies avec recherche.
   - Formulaire de dossier santé (sélection du lapin, saisie des symptômes, traitements, statut).
   - Historique des traitements liés aux tâches programmées.
4. Intégrer les notifications (rappels de traitement) via le service défini en Tâche 09.
5. Ajouter des tests (par exemple vérifier qu’un dossier enregistré apparaît dans la liste).

## Livrables
- `docs/health-spec.md`.
- Migrations Supabase et code Flutter du module.

## Notes
- Prévoir des textes clairs (« Ajouter un traitement », « Statut : en cours / résolu »).
- Veiller à ce que les formulaires vérifient les champs obligatoires pour éviter les erreurs de saisie.
