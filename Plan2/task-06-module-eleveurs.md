# Tâche 06 - Moderniser le module Éleveurs

## Objectif
Aligner la gestion des éleveurs sur les fonctionnalités Everbreed (filtres détaillés, actions groupées, import).

## Sous-tâches
1. Documenter dans `docs/breeders-spec.md` les filtres, colonnes et actions nécessaires (liste et fiche).
2. Refonte de la liste :
   - Ajouter une barre de recherche avec suggestions (nom, tatouage, cage).
   - Implémenter des filtres multiples (statut actif, race, catégorie, sexe, dates).
   - Permettre la sélection multiple et les actions groupées (saillie, archive, vente). Utiliser des dialogues de confirmation.
3. Revoir la fiche éleveur :
   - Réorganiser les champs selon le spec Everbreed (onglets Informations, Portées, Santé, Documents).
   - Ajouter des validations simples (dates, poids numériques).
4. Ajouter l’import CSV/Excel :
   - Prévoir un service qui lit un fichier depuis l’appareil (web + mobile) et affiche un aperçu.
   - Documenter les colonnes attendues dans `docs/breeders-spec.md`.
5. Tester l’écran (`flutter test` pour les vues et `flutter run` pour vérifier la navigation) et corriger toute alerte/analyse.

## Livrables
- `docs/breeders-spec.md` mis à jour.
- Code Flutter pour la liste et la fiche des éleveurs, plus import CSV, avec tests.

## Notes
- Toujours afficher des messages d’erreur simples en français (« Champ obligatoire », « Valeur numérique attendue »).
- Si l’import complet est complexe, livrer une version minimaliste (lecture CSV → insertion) et noter les limites dans la documentation.
