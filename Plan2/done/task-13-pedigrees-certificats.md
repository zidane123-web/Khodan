# Tache 13 - Pedigrees et certificats

## Objectif
Permettre aux eleveurs de generer des pedigrees lisibles et des certificats de naissance propres a Khodan, tout en respectant la base de donnees actuelle.

## Sous-taches
1. Rediger `docs/pedigree-certificats.md` avec: (a) les champs obligatoires par generation, (b) la mise en page souhaitee (format A4 et partage numerique), (c) des exemples de textes en francais simple.
2. Controler les tables Supabase liees aux reproducteurs (`breeders`, `breeding_records`). Ajouter une fonction SQL `fn_pedigree_tree(breeder_id uuid, generations int)` qui retourne les ancetres jusqu'a 4 generations. Utiliser l'editeur SQL si le CLI refuse la connexion, puis copier la requete dans une migration.
3. Cote Flutter, creer un service qui appelle la fonction et transforme la reponse en structure exploitable pour l'affichage et le PDF.
4. Concevoir une page `PedigreePage` avec: selection du lapin, apercu a l'ecran, boutons `Telecharger PDF` et `Partager lien`. Utiliser un style original (couleurs Khodan, icones locales) et expliquer dans le spec comment ajuster les couleurs.
5. Ajouter la creation d'un QR code qui renvoie vers une page web partageable (generer une URL en utilisant Supabase Edge Functions ou un simple `supabase` storage selon ce qui existe). Documenter les etapes a faire manuellement si une fonction serverless est necessaire.
6. Ecrire un test de service (verifie que la fonction renvoie bien le bon nombre d'ancetres) et un test widget pour le rendu d'un pedigree simple.

## Livrables
- `docs/pedigree-certificats.md`.
- Migration Supabase pour la fonction pedigree.
- Ecran Flutter et tests correspondants.

## Notes
- Chaque phrase dans le PDF doit rester courte (max 12 mots) pour etre lisible.
- Prevoir un message clair quand un parent manque dans la base ("information a completer").
- Eviter tout avertissement dans Flutter avant de clore la tache.
