# Task 19 - Stabiliser la configuration Flutter / data layer

## Objectif
- Garantir que l'application utilise les repositories Supabase plutot que les mocks in-memory en environnement dev/staging.
- Documenter les variables `USE_IN_MEMORY_REPOSITORIES`, `APP_ENV`, `SUPABASE_URL` et leur impact sur le comportement hors-ligne.
- Mettre en place une verification automatique (ex: test d'integration ou assert) pour detecter les builds mal configures.

## Livrables
- Mise a jour de `.env.example` et documentation (README) expliquant la configuration recommandee.
- Eventuelle modification de `AppEnv` ou d'un guard au demarrage pour logger clairement le mode en cours.
- Test manuel consigne montrant que les Cubits chargent les donnees distantes apres un hot restart.

## Etapes
1. Auditer `AppEnv` et les usages de `useInMemoryRepositories` pour confirmer quand les repos offline prennent le relais.
2. Mettre a jour `.env`, `.env.staging` (a creer si besoin) avec `USE_IN_MEMORY_REPOSITORIES=false` et les identifiants Supabase valides.
3. Ajouter un log ou une alerte UI si l'app demarre en mode in-memory alors que `APP_ENV=prod` ou `staging`.
4. Tester `flutter run --dart-define-from-file=.env` puis Hot Restart pour verifier que les ecrans Dashboard/Events consomment bien les donnees Supabase.
5. Noter dans `README.md` les etapes pour basculer temporairement en mode demo (offline) pour les tests.

## Dependances
- Task 16 et 18 pour disposer des resources distantes a jour.

