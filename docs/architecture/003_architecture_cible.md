# Architecture cible Khodan (Oct 2025)

Ce document cadre la structure logicielle cible de l application Khodan afin de soutenir les evolutions backlog P0/P1 tout en maintenant une qualite industrielle.

## 1. Vision d ensemble
- **Presentation** : couches `lib/features/<feature>/presentation` composées de widgets, pages et Cubits/Blocs. Objectif : n exposer que de la logique d interface et de l orchestration simple.
- **Domaine** : nouvelle couche a introduire `lib/domain` regroupant use cases, entites metier et validations. Cette couche est pure Dart (pas de Flutter) et ne depend que des interfaces de repositories.
- **Data** : `lib/data` conserve les models DTO, repositories et services externes (Supabase, Drift, FCM). Cette couche implemente les interfaces definies dans le domaine.
- **Infrastructure Backend** : Supabase (Postgres + edge functions) versionne via `supabase/migrations` et `supabase/functions`. Politique RLS et scripts deploy traites dans les taches 017-019.
- **App Core** : `lib/app` contient configuration (router, theme), bootstrap, DI leger. A completer avec un module `lib/app/core/bootstrap` pour initialiser services et environnements.

L objectif est de tendre vers un schema Clean Architecture en couches, en limitant les dependances descendantes : Presentation -> Domaine -> Data -> External.

## 2. Gestion d etat et patterns recommendes
- Standardiser sur **Bloc/Cubit** (package `flutter_bloc`) pour la presentation. Chaque feature expose un `Cubit` ou `Bloc` et ne manipule pas directement les repositories.
- Introduire une interface `UseCase<Input, Output>` dans `lib/domain/core` pour favoriser testabilite et clarte.
- Utiliser `sealed classes` / `union types` (en Dart 3) pour les resultats de use cases (`Success`, `Failure`).
- Centraliser le traitement d erreurs dans la couche domaine via objets `Failure` pour harmoniser l UI.

## 3. Convention de dossiers et nommage
```
lib/
  app/
    config/
    core/
      bootstrap/
      constants.dart
      di/
  domain/
    animals/
      entities/
      usecases/
      repositories/ (interfaces)
    common/
      usecase.dart
      failure.dart
  data/
    models/
    repositories/
    services/
    datasources/
  features/
    animals/
      presentation/
        cubit/
        screens/
        widgets/
      mapper/ (facultatif pour translater entity <-> ui models)
```
- Fichiers `repository.dart` dans `lib/domain/.../repositories` contiennent les **interfaces**.
- Implementation `SupabaseAnimalRepository` dans `lib/data/repositories` implemente l interface et gere conversions DTO <-> entity.
- Les Cubits utilisent les use cases (`GetAnimalsUseCase`, `CreateAnimalUseCase`).
- Nommer les entites metier au singulier (`Animal`, `BreedingRecord`), DTO suffixes `Dto`, models UI `ViewModel` si necessaire.

## 4. Navigation & configuration
- `lib/app/config/router.dart` devient la source unique des routes. Ajouter une couche `RouteGuards` (auth, roles, abonnement) dans `lib/app/config/guards` (tache 026).
- Maintenir un `NavigationShell` pour la bottom bar, mais externaliser les destinations dans un fichier `navigation_items.dart` pour re-utilisation.
- Prevoir `lib/app/config/app_flavors.dart` pour gerer env (dev/staging/prod) charge via `--dart-define`.

## 5. Gestion des dependances
- Introduire un registrant simple via `get_it` ou pattern manuel dans `lib/app/core/bootstrap/bootstrap.dart` :
  - Enregistrer services (Supabase client, Drift Database, NotificationService).
  - Enregistrer repositories (implementation data) exposes via interfaces.
  - Enregistrer use cases relies aux interfaces.
- Injection via `MultiRepositoryProvider` / `MultiBlocProvider` au plus haut niveau (`KhodanApp`).

## 6. Donnees & offline
- Les DTO Supabase residuent dans `lib/data/models`. Ajouter un `lib/data/datasources` pour isoler :
  - `remote/` : clients Supabase (REST/RPC) et Edge Functions.
  - `local/` : Drift DAOs et caches.
- Synchronisation offline (tache 023) : service `SyncCoordinator` dans `lib/data/services` orchestrant merges et conflits. Il appelle use cases specifiques (domaine) pour appliquer modifications.

## 7. Securite et configuration Supabase
- Tache 017 regenere migrations pour toutes tables (animals, breeding_records, finances...).
- Introduire un script `supabase/scripts/export_schema.sh` (ensuite) pour alignement.
- RLS : chaque table doit se baser sur `auth.uid()` + `farm_id`. Le domaine porte la logique d autorisation (ex: `CanEditAnimalUseCase`).

## 8. Qualite & tests
- Tests unitaires domaine et data (taches 038-039) reposent sur cette separation claire.
- Dossier `test/domain/...` et `test/data/...` pour valider use cases et repositories.
- Ajout de golden tests pour composants communs (tache 039) -> necessite design system.

## 9. Roadmap de refactorisation
1. **Phase 1 (parallele aux dev P0)** :
   - Creer dossiers `lib/domain`, `lib/app/core/bootstrap`.
   - Extraire interfaces repositories existantes (animaux, auth) vers `domain`.
   - Ajouter premiers use cases (auth/login, animals/load) et brancher Cubits.
2. **Phase 2** :
   - Introduire `get_it` (ou DI manuel) et re-cabler `KhodanApp`.
   - Decouper fichiers volumineux en sous composants.
3. **Phase 3** :
   - Etendre architecture aux nouveaux modules (finances, notifications) directement selon ce schema.

## 10. Actions concretes immediates
- Ouvrir stories techniques :
  - ARCH-01 : Initialiser structure `lib/domain` + use case base.
  - ARCH-02 : Extraire `AuthRepository` interface/d implementation.
  - ARCH-03 : Mettre en place bootstrap + injection services.
- Ajouter reference a ce document dans le README/Contributing (tache documentation 046).

Cette architecture cible sert de reference commune. Toute nouvelle feature doit verifier qu elle ne depend pas directement d une couche inferieure non autorisee.
