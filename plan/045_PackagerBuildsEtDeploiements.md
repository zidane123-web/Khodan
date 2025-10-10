# Packager les builds et lancer les deploiements

## Objectif / But
Assembler et valider les builds (Android, iOS, Web) et les deployer sur les stores ou environnements prod.

## Etapes concretes
- Generer les builds signes (Android App Bundle, IPA, Web bundle).
- Executer la checklist de validation (tests manuels smoke, acces offline).
- Soumettre aux stores (Play Store, App Store) et deployer web (Firebase Hosting).
- Surveiller les crashs et analytics post-deploiement (Sentry, Firebase).
- Communiquer le go-live aux parties prenantes et mettre a jour le changelog public.

## Fichiers ou modules concernes
- `android/`
- `ios/`
- `web/`
- `plan/043_MettreEnPlaceCI_CD.md`

## Resultat attendu / Critere de reussite
- Application publiee sur tous les canaux avec monitoring post lancement actif.

## Prerequis eventuels
- 043_MettreEnPlaceCI_CD.md

