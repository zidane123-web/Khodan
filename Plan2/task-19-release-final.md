# Tache 19 - Mise en production et livrables finaux

## Objectif
Assembler tout le travail pour livrer une version stable de Khodan, prete a etre deployee sur le web et sur mobile.

## Sous-taches
1. Rediger `docs/release-plan.md` avec une check-list pas a pas: (a) verifier les migrations appliquees, (b) controler les parametres Supabase (RLS active, storage configure), (c) tester la version mobile et web, (d) realiser la revue finale UX.
2. Mettre a jour `RELEASE.md` avec les commandes detaillees pour: build Android (`flutter build apk --release`), build web (`flutter build web`), eventuelle soumission sur Play Store ou hebergement web. Expliquer comment zipper les assets generes.
3. Creer un script PowerShell ou bash simple `tool/deploy.sh` (ou `.ps1`) qui automatise: tests, build, verification de la taille du bundle, copie des fichiers web vers un dossier `release/web`.
4. Rediger un document court `docs/formation-utilisateur.md` qui explique comment presenter Khodan a un elevage (plan de demo en 15 minutes, liens utiles, FAQ). Utiliser des phrases tres simples.
5. Verifier les licences et credits (icones, fonts) et ajouter une section "Mentions" dans le README si necessaire.
6. Faire une passe de nettoyage: supprimer TODO obsolete, verifier `dart analyze`, `flutter test`, `npm run lint` (si besoin pour le web). Noter les resultats dans `docs/release-plan.md`.
7. Proposer un point final avec le proprietaire du projet: resume d'une page sur ce qui reste a faire manuellement (parametres Stripe, achat nom de domaine, etc.).

## Livrables
- `docs/release-plan.md` complet.
- `RELEASE.md` mis a jour + script de deploy.
- `docs/formation-utilisateur.md`.
- Notes de verification des tests et des builds.

## Notes
- Garder le ton rassurant et pedagogique ("Commence par...", "Verifie que...").
- Ajouter un rappel visible pour sauvegarder la base avant toute mise en production.
- Aucun avertissement dans les commandes de build avant de cloturer la tache.
