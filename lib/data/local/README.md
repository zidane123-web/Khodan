# Local Persistence Strategy

The Drift schema defined in `local_database.dart` mirrors the core Supabase tables
(`profiles`, `species_config`, `animals`, `breeding_records`, `events`, and the
`animal_events` join table). All domain objects are stored as JSON payloads with
`updated_at` and `sync_state` columns so that pending offline changes can be tracked.

## Schema updates

When a breaking change is required:
1. Bump the `schemaVersion` of `LocalDatabase`.
2. Provide a migration strategy that either transforms the existing tables or
   wipes the cache (`clearAll`) if the change cannot be reconciled safely.
3. Keep the Supabase migrations in sync. Column removals/additions should be
   reflected both locally and remotely.

Because the cache is derived from Supabase, wiping the local data on a migration
is acceptable: the next online sync repopulates the database.

## Sync lifecycle

* **Reads**: `Synced*Repository` objects attempt to return cached data first when
  `OfflineSyncManager` reports offline, otherwise remote fetches refresh the cache.
* **Writes**: Remote successes immediately update the cache. Offline operations
  mark rows with `sync_state = 'pending'` so queued actions can reconcile later.
* **Queue replay**: Once the app is back online, queued actions call the same
  repository methods, which convert pending rows back to `sync_state = 'synced'`.

Tests in `test/data/repositories/synced_*_repository_test.dart` cover the offline
paths to guarantee that lists and details remain functional without a network
connection.
