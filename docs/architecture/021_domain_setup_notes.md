# Domain layer setup (Oct 2025)

## Fichiers ajoutés
- lib/domain/common/failure.dart : hiérarchie de Failure.
- lib/domain/common/use_case.dart : base UseCase.
- lib/domain/animals/entities/animal_entity.dart : entité domaine.
- lib/domain/animals/repositories/animal_repository_interface.dart : abstraction repository.
- lib/domain/animals/usecases/fetch_animals_use_case.dart : exemple use case.
- lib/data/repositories/animal_repository_impl.dart : impl. Supabase de l interface.
- lib/data/services/import_export_service.dart : service CSV pour import/export (tâche 020, déjà ajouté).

## TODO
- Compléter mapping farm_id depuis Supabase (champ manquant dans modèle data -> tache 021/022).
- Ajouter tests unitaires domaine/données (tâches 038+).
- Étendre use cases et repo aux autres modules.
