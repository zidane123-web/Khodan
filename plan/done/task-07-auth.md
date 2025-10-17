# Experience d'authentification complete

## Objectif
- Finaliser le flux d'inscription avec creation du profil elevage et gestion de l'email de confirmation Supabase.
- Ajouter la recuperation de mot de passe, la persistance de session (auto login) et la gestion des erreurs utilisateur (credentials invalides, compte suspendu).
- Affiner l'UI (`LoginScreen`, `LoginForm`) pour couvrir les cas de chargement et les messages localises.

## Livrables
- Mise a jour de `AuthCubit` pour exposer `resetPassword`, `magicLink`, `listenAuthChanges` et rafraichir le profil.
- Ecran/dialogue de reset password et feedback visuel (SnackBars) pour chaque etat.
- Tests unitaires/cubit garantissant la bonne reaction aux flux `onAuthStateChange` et aux erreurs `AuthException`.

## Notes techniques
- Synchroniser la table `profiles` lors du login (fetch + cache) pour alimenter le tableau de bord et les settings.
- Prevoir un traitement specifique lorsque Supabase requiert une confirmation email (afficher un ecran d'attente + option renvoi).
- S'assurer que `SplashScreen` redirige correctement selon l'etat de session (eviter les boucles en cas d'erreur).
