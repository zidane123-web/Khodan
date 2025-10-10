# Ecrire les tests widgets et flux critiques

## Objectif / But
Assurer la stabilite des ecrans et interactions en automatisant les tests widget/golden.

## Etapes concretes
- Selectionner les ecrans critiques (dashboard, fiche animal, formulaires finances).
- Ecrire des tests widgets couvrant etats succes/erreur/chargement.
- Mettre en place des golden tests pour les composants communs.
- Automatiser la verification des regressions visuelles (flutter test --update-goldens en mode controle).
- Integrer ces tests a la pipeline CI.

## Fichiers ou modules concernes
- `test/widget`
- `goldens/ (a creer)`
- `plan/006_IndustrialiserComposantsCommuns.md`

## Resultat attendu / Critere de reussite
- Tests widgets et golden stables assurant l absence de regressions visuelles majeures.

## Prerequis eventuels
- 038_EcrireTestsUnitairesDomaine.md

