# Configurer les services de synchronisation et cache

## Objectif / But
Implementer les services gerant le temps reel, la synchronisation offline et les conflits de donnees.

## Etapes concretes
- Mettre en place des canaux Supabase Realtime pour les tables critiques.
- Ajouter un service de sync qui ecrit dans un store local (par ex. Hive) et gere les flags de dirty data.
- Implementer la resolution de conflits (strategies merge, override, duplication).
- Exposer des callbacks vers la couche presentation pour afficher l etat de sync.
- Ecrire des tests d integration simulant les scenarios online/offline.

## Fichiers ou modules concernes
- `lib/data/services/realtime_service.dart (a creer)`
- `lib/features/offline (a creer ou completer)`
- `plan/022_RationaliserRepositories.md`

## Resultat attendu / Critere de reussite
- Services de sync et cache operationnels et testes en conditions offline.

## Prerequis eventuels
- 022_RationaliserRepositories.md

