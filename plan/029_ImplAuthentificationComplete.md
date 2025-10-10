# Implementer l authentification complete

## Objectif / But
Completer le module auth avec tous les parcours utilisateurs et etats d erreur.

## Etapes concretes
- Mettre a jour `AuthRepository` pour supporter inscription, MFA et reinitialisation de mot de passe.
- Implementer les ecrans Flutter (login, signup, verification, reset).
- Gerer la persistence de session et le rafraichissement des tokens Supabase.
- Ajouter le tracking analytics des actions d auth.
- Ecrire des tests unitaires sur `AuthCubit` et des tests widget pour les formulaires.

## Fichiers ou modules concernes
- `lib/data/repositories/auth_repository.dart`
- `lib/features/auth/presentation`
- `test/features/auth`

## Resultat attendu / Critere de reussite
- Authentification robuste supportant tous les parcours et couverte par des tests.

## Prerequis eventuels
- 028_ImplFluxOnboarding.md

