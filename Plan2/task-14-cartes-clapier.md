# Tache 14 - Cartes de clapier et impressions

## Objectif
Fournir un generateur de cartes de clapier imprimables (A4 ou A5) avec QR code pour ouvrir la fiche du lapin.

## Sous-taches
1. Rediger `docs/cartes-clapiers.md` pour decrire: (a) les formats proposes (A4, A5, etiquette), (b) la liste des champs disponibles, (c) un exemple de bloc de texte court par carte.
2. Verifier la structure Supabase: ajouter si besoin une table `cage_card_templates` pour sauvegarder les choix de l'utilisateur (taille, champs, couleur). Noter dans la fiche comment saisir la migration via l'editeur SQL si le CLI echoue.
3. Implementer un service Flutter qui lit les eleveurs/portees actifs et prepare les donnees d'impression (nom, cage, date de naissance, poids, etc.).
4. Creer une page `CageCardsPage` avec: choix du template, apercu dynamique, checkboxes pour choisir les lapins a imprimer, bouton `Telecharger PDF` et bouton `Imprimer`. Penser a une barre d'aide simple en haut.
5. Ajouter la generation d'un QR code par carte (utiliser `qr_flutter` ou equivalent). Expliquer dans une note comment installer le package et eviter les conflits.
6. Prevoir un bouton "Exporter vers imprimeur" qui sauvegarde un PDF dans `storage/cage_cards/<date>.pdf` via Supabase Storage ou sur le disque local. Documenter la marche a suivre.
7. Ajouter un test widget qui verifie le rendu d'une carte exemple et un test de service sur la generation du fichier PDF (mock si besoin).

## Livrables
- `docs/cartes-clapiers.md`.
- Migration Supabase eventuelle pour la table des templates.
- Ecran Flutter avec generation PDF + tests.

## Notes
- Les textes sur les cartes doivent tenir en une ligne pour ne pas deborder.
- Prevoir une option qui cache les donnees sensibles (par exemple prix d'achat) en un clic.
- Nettoyer tous les avertissements avant de cloturer la tache.
