# Implementer le flux onboarding

## Objectif / But
Developper les ecrans et la logique d onboarding permettant de configurer la ferme et inviter l equipe.

## Etapes concretes
- Creer les ecrans Flutter dans `lib/features/onboarding/presentation` selon les maquettes.
- Connecter les formulaires aux repositories pour creer ferme, profils et importer donnees initiales.
- Ajouter la gestion d etat (Cubit/Bloc) pour suivre la progression et traiter les erreurs.
- Implementer les tests widget et integration du parcours complet.
- Brancher le flux dans la navigation initiale (avant login si compte inexistant).

## Fichiers ou modules concernes
- `lib/features/onboarding`
- `lib/data/repositories/farm_repository.dart (a creer)`
- `plan/007_DesignerParcoursOnboarding.md`

## Resultat attendu / Critere de reussite
- Flux onboarding fonctionnel, teste et integre a la navigation principale.

## Prerequis eventuels
- 027_StandardiserGestionEtat.md

