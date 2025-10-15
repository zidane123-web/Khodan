# Refondre la couche de donnees Flutter

## Objectif
- Remplacer les repositories `InMemory*` utilises dans `main.dart` par des implementations Supabase ou offline selectionnees dynamiquement.
- Factoriser les appels reseau (gestion d'erreurs, mapping JSON, retry) dans une couche commune afin d'eviter la duplication dans chaque Cubit.
- Mettre en place une injection de dependances claire (ex. `RepositoryProvider` conditionnel ou service locator) pour simplifier les tests.

## Livrables
- Mise a jour de `lib/main.dart` et `lib/app/config/router.dart` pour fournir `SupabaseAnimalRepository`, `SupabaseBreedingRepository`, `SupabaseEventRepository`, etc.
- Nouveau module utilitaire (ex. `lib/data/services/api_client.dart`) gerant les exceptions `PostgrestException`, la journalisation, et la conversion des dates.
- Tests unitaires couvrant les repositories refactores, avec mock Supabase (utiliser `supabase_flutter` mocks ou `mocktail`).

## Notes techniques
- Conserver les versions in-memory uniquement pour les tests ou le mode demo; les injecter via un flag dans `KhodanApp`.
- Harmoniser les methodes (`fetchAnimals`, `createAnimal`, etc.) pour qu'elles retournent des resultats `Either` ou lancent des exceptions standardisees.
- Veiller a ce que les Cubits (`AnimalCubit`, `BreedingCubit`, `EventsCubit`, `DashboardCubit`) ne dependent plus de comportements specifiques a l'in-memory.
