# Tâche 08 - Refaire le module Planning (liste, calendrier, chaîne)

## Objectif
Offrir des vues liste/calendrier/chaîne pour gérer les tâches d’élevage et synchroniser avec un agenda externe.

## Sous-tâches
1. Définir dans `docs/schedule-spec.md` les champs d’une tâche (type, date, heure, animaux liés, statut, notes).
2. Implémenter la vue Liste avec filtrage, recherche, tri, actions rapides (marquer comme fait, éditer, supprimer).
3. Ajouter la vue Calendrier (mensuel + hebdomadaire) avec le même jeu d’actions.
4. Créer la vue Chaîne (visualisation des étapes de reproduction pour une portée).
5. Prévoir un export iCal/CSV (générer un fichier et proposer le téléchargement).
6. Vérifier le fonctionnement hors-ligne (queue des actions si pas de connexion) et documenter les limites.

## Livrables
- `docs/schedule-spec.md`.
- Écrans Flutter mis à jour avec tests unitaires pour les fonctions clés (filtre, export).

## Notes
- Garder un langage clair (« Télécharger l’agenda », « Marquer comme terminé »).
- En cas de difficulté avec l’iCal, fournir au minimum un export CSV et noter le suivi dans le spec.
