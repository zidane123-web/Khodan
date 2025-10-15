# Khodan

Flutter application for livestock management powered by Supabase.

## Environment configuration

Secrets are injected at build time using `--dart-define` or `--dart-define-from-file`.  
Start by creating your local file:

```bash
cp .env.example .env
```

Edit `.env` with the Supabase project values (do **not** commit the file). The app bootstrap loads the `APP_ENV` flavour (`dev`, `staging`, `prod`) and falls back to safe local defaults when values are missing, so widget tests continue to run even without real credentials.

### Run commands

```bash
# Development (default environment)
flutter run --dart-define-from-file=.env

# Target staging profile
flutter run --dart-define-from-file=.env.staging --dart-define APP_ENV=staging

# Widget & unit tests
flutter test \
  --dart-define-from-file=.env \
  --dart-define APP_ENV=dev
```

For CI/CD providers that cannot use `--dart-define-from-file`, pass the variables directly:

```bash
flutter build apk \
  --dart-define SUPABASE_URL=$SUPABASE_URL \
  --dart-define SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define APP_ENV=prod
```

### Rotating Supabase keys

1. Generate the new anon key from the Supabase dashboard.
2. Update your secret manager (.env files, GitHub Actions secrets, Fastlane match, etc.).
3. Restart the running applications: the new values are picked up on the next launch thanks to `AppEnv`.

## Continuous integration

A sample GitHub Actions workflow (`.github/workflows/flutter_ci.yml`) installs Flutter, restores packages, injects Supabase secrets from repository settings, and runs `flutter analyze` plus the test suite with staging variables.

## Project structure

- `lib/app/config/app_env.dart` centralises environment detection (`dev`, `staging`, `prod`) and Supabase credentials.
- `supabase/` contains database migrations and documentation.
- `plan/` lists the high-level roadmap, with completed tasks archived in `plan/done/`.

Refer to `supabase/README.md` for RLS policies, RPC helpers, and dashboard integration details.
