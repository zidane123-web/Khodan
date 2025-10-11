# Bootstrap applicatif (Oct 2025)

- `lib/app/core/bootstrap/bootstrap.dart` centralise l initialisation (Supabase, Firebase Messaging, services).
- `AppBootstrap.ensureInitialized()` doit être appelé avant `runApp`.
- `BootstrapResult` stocke `SupabaseClient`, `SyncCoordinator`, `NotificationService`, `ImportExportService` pour DI future.
- `main.dart` consomme `AppBootstrap` et ne gère plus Supabase directement.
- TODO : intégrer fournisseur DI (get_it / provider) et gérer Firebase options/erreurs.
