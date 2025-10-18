# Supabase Schema Reference

This document summarises the relational structure delivered by the initial migration (`20251015110000_initial_schema.sql`) and the follow-up feature migration (`add_features_tables`).

## profiles
- **Primary key:** `id` (`uuid`) mirrors `auth.users.id`.
- **Required:** `email`, `created_at`, `updated_at`.
- **Optional:** `farm_name`, `phone`, `locale`, `time_zone`, `deleted_at`.
- **Optional (Task 08):** `farm_location`, `billing_status`.
- **JSON metadata:** `legal_preferences` stores opt-ins (`termsAccepted`, `privacyAccepted`, `marketingOptIn`).
- **Relations:** Referenced by every domain table via `profile_id`. Cascade delete ensures agent-owned data is removed when an account is closed.

## species_config
- **Primary key:** identity `id` (`bigint`).
- **Required:** `profile_id`, `species_name`, `events_schema`, timestamps.
- **Optional:** gestation and weaning durations, `deleted_at`.
- **Indexes:** unique on (`profile_id`, `species_name`) plus filter index on `profile_id`.
- **Relations:** cascade delete when the owning profile is removed; referenced by `animals`, `breeding_metrics`, `food_types` (indirectly through profile).

## animals
- **Primary key:** `id` (`uuid`, generated).
- **Required:** `profile_id`, `species_id`, `tag_id`, `birth_date`, `sex`, `status`.
- **Optional:** identifiers for parents (`sire_id`, `dam_id`), descriptive fields, housing data, `deleted_at`.
- **Relations:** cascades to `animal_events` and `breeding_records`; self-referencing keys use `ON DELETE SET NULL` to break genealogy loops safely.
- **Indexes:** composite unique (`profile_id`, `tag_id`), lookup indexes on (`profile_id`, `species_id`) and (`sire_id`, `dam_id`).

## breeding_records
- **Primary key:** `id` (`uuid`, generated).
- **Required:** `profile_id`, `doe_id`, `buck_id`, `mating_date`.
- **Optional:** lifecycle dates, litter statistics, `notes`, soft-delete flag.
- **Integrity:** non-negative checks on counts and weight; cascade delete when linked animals or profile are removed.
- **Indexes:** (`profile_id`, `mating_date` desc) for timeline queries, (`doe_id`, `buck_id`) for genealogy analytics.

## breeding_metrics
- **Primary key:** identity `id`.
- **Required:** `profile_id`, `species_id`, `period_start`, `period_end`.
- **Optional:** aggregated KPIs, champion animal references, `deleted_at`.
- **Integrity:** `period_end >= period_start`, non-negative counters.
- **Indexes:** unique per (`profile_id`, `species_id`, `period_start`, `period_end`) to avoid duplicates.

## events
- **Primary key:** `id` (`uuid`, generated).
- **Required:** `profile_id`, `event_type`, `event_date`.
- **Optional:** `details` payload, `notes`, `deleted_at`.
- **Indexes:** (`profile_id`, `event_date` desc) and `event_type` for filtering in the event hub.

## animal_events
- **Purpose:** join table between `events` and `animals` with contextual `role`.
- **Primary key:** composite (`event_id`, `animal_id`, `role`).
- **Cascade rules:** removing an animal or event clears its links automatically.
- **Soft delete:** carries `created_at`, `updated_at`, `deleted_at` for parity with other tables.

## sync_queue
- **Primary key:** `id` (`uuid`, generated).
- **Required:** `profile_id`, `entity`, `operation`, `payload`, `status`.
- **Optional:** scheduling/processing timestamps, retry tracking, `error_message`.
- **Soft delete:** `deleted_at` flag matches offline reconciliation strategy.
- **Indexes:** (`profile_id`, `status`) for dashboards, `scheduled_at` for cron-based workers.

## feature tables (add_features_tables)
- `event_templates`: templates owned per user (`auth.uid()` RLS ready).
- `food_types` and `food_stock`: inventory management tables, each with row-level policies and cascade deletes back to Supabase Auth.
- Existing migration also augments `animals` with `health_status` (nullable text).

## support_requests
- **Purpose:** file the conversations entre utilisateurs et support.
- **Columns:** `subject`, `message`, `contact_email`, `channel`, `priority`, `status`, timestamps.
- **Indexes:** composite on (`profile_id`, `created_at DESC`) to faciliter le suivi chronologique.

## Soft delete strategy
Tables carrying `deleted_at` support logical deletion and offline sync. Future triggers (task 02) should update `updated_at` automatically and filter on `deleted_at IS NULL` in RLS policies.

## Seed data
The migration seeds at most one profile (if `auth.users` already contains entries), a sample species and a demo doe. These rows are idempotent thanks to conflict checks.
