# File de synchronisation et resolution de conflits

## Objectif
- Faire evoluer `OfflineSyncManager` pour persister la queue (Drift) et suivre l'etat de chaque operation (pending, running, failed, retriable).
- Supporter les operations animals, breeding et events (CRUD) avec prio et rollback si une operation echoue.
- Introduire une strategie de resolution de conflits (last write wins avec horodatage, ou merge specifique selon la table).

## Livrables
- Extension de `OfflineSyncManager` + nouveaux services stockant les actions en base locale (`queued_actions`).
- Integration dans `BreedingCubit` et `EventsCubit` (ajout des appels `_offlineManager.enqueue(...)` et traitement des retours).
- Mise a jour des ecrans Settings (`SettingsScreen`, `SettingsLogsScreen`) pour afficher l'historique synchronise via `SyncHistoryCubit`.

## Notes techniques
- Les actions doivent inclure un snapshot de la charge utile envoyee au backend afin de faciliter le retry.
- Prevoir un mecanisme de backoff exponentiel et de detection de connexion (`connectivity_plus`) pour relancer la synchro automatiquement.
- Documenter les scenarios conflits (ex. suppression backend alors qu'une update offline arrive) et la resolution appliquee.
