# Tache 17 - Personnalisation et langues

## Objectif
Offrir une interface facile a adapter (langue, theme, unite, devise) pour coller aux attentes locales et a Everbreed.

## Sous-taches
1. Rediger `docs/personnalisation-l10n.md` qui explique: (a) la liste des langues cible (francais, anglais, langues locales a ajouter plus tard), (b) les elements personnalisables (couleurs, logo, unite poids, devise), (c) les regles pour garder des phrases courtes.
2. Configurer Flutter `gen_l10n` si ce n'est pas deja fait: verifier `l10n.yaml`, ajouter les fichiers `lib/l10n/app_fr.arb`, `app_en.arb`, etc. Inclure des exemples de phrases simples.
3. Implementer un service de preferences (`UserSettingsService`) lie a Supabase (table `user_settings` ou champs dans `profiles`). Ajouter la migration si besoin.
4. Ajouter dans l'application un ecran `PersonnalisationPage` avec des toggles ou listes de selection pour: langue, unite de poids, devise, theme (clair/sombre), couleur secondaire. Prevoir un bouton `Appliquer` qui confirme les changements.
5. Mettre a jour les ecrans existants pour utiliser les textes localises (remplacer les chaines en dur). Ecrire une check-list dans le doc pour ne rien oublier.
6. Ajouter une verification au demarrage: si la langue n'est pas definie, proposer un petit assistant (dialogue 2 etapes) pour guider le debutant.
7. Ecrire des tests: (a) test unitaire sur la sauvegarde des preferences, (b) test widget sur la bascule de langue.

## Livrables
- `docs/personnalisation-l10n.md`.
- Migrations Supabase si une table de settings est necessaire.
- Fichiers de traduction `.arb`, service de preferences et ecran de personnalisation.
- Tests passes.

## Notes
- Limiter les termes techniques dans les traductions (prefere "clapier" a "module").
- Documenter comment ajouter une langue locale supplementaire (exemple pas a pas dans le doc).
- S'assurer qu'aucune chaine francaise ne reste en dur dans le code Flutter.
