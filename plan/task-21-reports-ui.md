# Task 21 - Corriger l'ecran Rapports (overflow & charts)

## Objectif
- Eliminer les messages `TEXT OVERFLOW BY X PIXELS` et les caracteres parasites visibles dans les dropdowns.
- Harmoniser la mise en page des graphiques (FL Chart) pour supporter diverses tailles d'ecran.
- Verifier que les donnees remontent correctement une fois les tables Supabase alimentees.

## Livrables
- Correctifs Flutter (mise en page, theme, labels) merges.
- Tests widget simples assurant l'absence d'overflow sur des resolutions communes.
- Capture ecran de reference (dev build) sans alertes visuelles.

## Etapes
1. Identifier la cause de l'overflow (Widget `DropdownButton`, padding insuffisant, police fallback).
2. Appliquer un `LayoutBuilder` ou des contraintes flexibles pour eviter les labels hors cadre.
3. Desactiver le diagnostic FL Chart en mode release (et eventuellement en debug via option).
4. Normaliser les textes (utiliser `AppLocalizations` + encodage UTF-8 corrige via Task 22).
5. Ajouter un test widget qui pompe l'ecran Rapports et valide l'absence d'erreur Flutter (`expect(tester.takeException(), isNull)`).
6. Actualiser la documentation QA avec les resolutions mini supportees.

## Dependances
- Task 19 (donnees distantes actives).
- Task 22 (nettoyage encodage) a executer en parallele ou juste avant la validation finale.

