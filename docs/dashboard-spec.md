# Spécification tableau de bord Khodan

## Contexte
- Objectif : offrir une vue d'accueil inspirée d'Everbreed avec actions rapides, indicateurs clés et planning à court terme.
- Public : éleveur débutant francophone, accès mobile et desktop.
- Statut : branchement Supabase réel à faire plus tard, données temporaires utilisées ici.

## Sections

### Message d'accueil
- Titre : `Bienvenue sur Khodan`
- Sous-texte : `Retrouvez vos élevages, vos actions rapides et les prochains événements en un coup d'œil.`
- Placeholder dynamique : afficher le prénom de l'utilisateur si disponible (`Bonjour, {prenom}`), sinon `Bonjour !`.

### Actions rapides
- Boutons alignés horizontalement sur desktop, carousel/2 colonnes sur mobile.
- CTA :
  - `Saillie` → stub `onCreateBreeding()`
  - `Mise bas` → stub `onCreateKindling()`
  - `Pesée` → stub `onCreateWeighing()`
  - `Abattage` → stub `onCreateHarvest()`
- Style : icône, étiquette courte, fond vert clair, coins arrondis.
- Statut : actions ouvrent un `showModalBottomSheet` ou future navigation, pour l'instant log ou `debugPrint`.

### Menu « + »
- Bouton flottant + (mobile) ou bouton icône + (desktop) ouvrant un `BottomSheet`.
- Options proposées avec texte simple :
  - `Ajouter un éleveur`
  - `Planifier une saillie`
  - `Créer une tâche`
  - `Enregistrer une perte`
- Chaque option appelle un stub (`onQuickAddBreeder()`, etc.).
- Mentionner dans l'UI : `Plus d'actions bientôt`.

### Indicateurs
- Cartes responsives (2 par ligne desktop, 1 mobile).
- Placeholder valeurs :
  - `Lapines actives` : `12`
  - `Lapins prêts pour la vente` : `8`
  - `Portées en cours` : `5`
  - `Tâches en retard` : `2`
- Chaque carte : titre + valeur + texte helper (`Données à connecter à Supabase`).
- Prévoir hook futur : méthode `loadDashboardStats()` qui sera remplacée par appel réel.

### Planning
- Bloc `Planning des 7 prochains jours`.
- Liste verticale (ou horizontale sur desktop) avec éléments mock :
  - `02/11 – Palpation lapine #K-24`
  - `03/11 – Préparer nid portée #P-18`
  - `05/11 – Pesée portée #P-11`
- Bouton `Voir tout le planning` qui redirigera plus tard vers l'écran Agenda (`onOpenPlanning()` stub).
- Message vide : `Aucune tâche à venir pour le moment.` si liste vide.

## Responsive
- Utiliser `LayoutBuilder` pour déterminer breakpoints (~600 px).
- Sur mobile : sections empilées, actions rapides en grille 2x2, indicateurs 1 colonne.
- Sur desktop : grille deux colonnes, actions rapides alignés, indicateurs sur deux colonnes, planning aligné à droite si largeur suffisante.

## Valeurs temporaires & TODO
- Valeurs indicateurs et planning sont des mocks définis dans `DashboardMockData`.
- Stubs à brancher : `onCreateBreeding`, `onCreateKindling`, `onCreateWeighing`, `onCreateHarvest`, `onQuickAddBreeder`, `onQuickAddBreeding`, `onQuickAddTask`, `onQuickAddLoss`, `onOpenPlanning`, `loadDashboardStats`.
- Documenter les TODO dans le code avec commentaire `// TODO: Brancher Supabase`.

## Tests
- Ajouter un test widget dans `test/features/dashboard/` qui rend `DashboardScreen` et vérifie la présence :
  - du texte `Bienvenue sur Khodan`
  - des boutons `Saillie`, `Mise bas`, `Pesée`, `Abattage`
  - du bloc `Planning des 7 prochains jours`
- Commandes à exécuter :
  - `flutter analyze`
  - `flutter test`

## Prochaines étapes manuelles
- Connecter les indicateurs à la RPC Supabase `get_dashboard_kpis` (à confirmer).
- Récupérer les événements réels depuis la table `events` pour le planning.
- Créer les écrans/formulaires cibles pour les actions rapides et menu +.

