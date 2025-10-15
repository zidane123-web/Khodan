# Gestion des environnements et secrets

## Objectif
- Normaliser la facon d'injecter `SUPABASE_URL` et `SUPABASE_ANON_KEY` pour toutes les plateformes (Android, iOS, Web, Desktop).
- Securiser la configuration en evitant la presence de secrets dans le repository et en documentant une procedure de rotation.
- Preparer un jeu de configurations `dev/staging/prod` avec detection automatique dans l'application.

## Livrables
- Module Flutter (ex. `lib/app/config/app_env.dart`) encapsulant la lecture des `--dart-define` et fournissant des valeurs par defaut en dev local.
- Mise a jour de la documentation (`README.md`) avec les commandes `flutter run` appropriees et la marche a suivre pour generer un fichier `.env` non versionne.
- Scripts ou fichiers de configuration (GitHub Actions, Fastlane, etc.) positionnant les variables d'environnement lors du build CI/CD.

## Notes techniques
- Ajouter un exemple `.env.example` avec des placeholders et mettre a jour `.gitignore` si necessaire.
- Prevoir un fallback lisant `const String.fromEnvironment` pour ne pas bloquer l'execution tests widget.
- Valider que `Supabase.initialize` n'est invoque que lorsque les deux valeurs sont presentes.
