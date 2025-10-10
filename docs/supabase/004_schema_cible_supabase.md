# Schema Supabase cible (Oct 2025)

Ce document decrit le schema de donnees cible pour Supabase afin d aligner le backend avec le backlog priorise et l architecture cible.

## 1. Etat actuel
- Une seule migration versionnee `add_features_tables` cree `event_templates`, `food_types`, `food_stock` et ajoute `health_status` sur `animals`.
- Les tables critiques utilisees par l application (animals, breeding_records, profiles, events, settings) ne sont pas versionnees -> schema reel inconnu.
- Aucune politique RLS sur les tables historiques, aucune function ou trigger referencee.

## 2. Principes directeurs
1. **Multi tenant ferme** : toutes les donnees metier sont rattachees a `farm_id` et verrouillees par RLS (auth.uid() membre de la ferme, voir module roles).
2. **Separation metier** : decouper finance, inventaire, notifications en tables specialises pour faciliter reglages.
3. **Historisation** : timestamps `created_at`, `updated_at` (trigger) et si besoin `deleted_at` pour soft delete.
4. **Identifiants** : utiliser UUID (Supabase gen_random_uuid) pour entites principales, BIGINT sequence pour tables volumetriques (logs, mouvements).
5. **Nom des colonnes** : snake_case, cle etrangere `<entity>_id`.
6. **Performance** : index composites sur colonnes de filtre (farm_id + status, farm_id + date, etc.).

## 3. Modules et tables cibles

### 3.1 Comptes, fermes, roles
- `profiles` (id UUID pk, user_id Supabase auth, full_name, phone, locale, avatar_url, created_at, updated_at).
- `farms` (id UUID pk, owner_profile_id, name, country, timezone, herd_type, created_at, updated_at).
- `farm_members` (farm_id, profile_id, role_id, status, invited_by, invited_at, joined_at) pk composite.
- `roles` (id UUID pk, code, label, description, permissions JSONB).
- `role_permissions` (role_id, permission_code) si granularite fine.
- `user_settings` (profile_id pk, notifications JSONB, theme, language, offline_mode_enabled).

### 3.2 Animaux et taxonomy
- `species` (id SERIAL pk, name, gestation_days, weaning_days, metadata JSONB).
- `animal_tags` (id UUID pk, farm_id, code, label, color, created_at).
- `animals` (id UUID pk, farm_id, profile_id, species_id, tag_id, name, sex, status, birth_date, image_url, sire_id, dam_id, cage_number, origin, entry_date, first_breeding_date, health_status, created_at, updated_at, deleted_at).
- `animal_metrics` (id BIGINT pk, animal_id, metric_type, metric_value NUMERIC, metric_unit, recorded_at, recorded_by).
- `animal_documents` (id UUID pk, animal_id, file_url, file_type, description, uploaded_at).

### 3.3 Reproduction, evenements et taches
- `breeding_records` (id UUID pk, farm_id, doe_id, buck_id, mating_date, palpation_date, palpation_positive, kindling_date, kits_born_alive, kits_born_dead, adopted_kits_in, kits_removed, weaning_date, kits_weaned, average_weaning_weight, notes, created_at, updated_at).
- `breeding_tasks` (id BIGINT pk, record_id, task_type, due_date, completed_date, created_at).
- `events` (id UUID pk, farm_id, category, title, description, event_date, status, related_animal_id, recorded_by, created_at, updated_at).
- `event_assignments` (event_id, profile_id, assigned_at, completed_at, completion_notes).
- `event_templates` (existant) -> ajouter `farm_id`, `category`, `default_duration`, `reminder_offset_days`.
- `reminders` (id UUID pk, event_id nullable, record_id nullable, type, due_date, sent_at, delivery_channel, payload JSONB).

### 3.4 Inventaire et finances
- `inventory_items` (id UUID pk, farm_id, category, name, sku, unit, min_stock_level, created_at, updated_at).
- `inventory_batches` (id UUID pk, item_id, quantity NUMERIC, cost NUMERIC, batch_date, supplier, expires_at, created_at).
- `inventory_movements` (id BIGINT pk, farm_id, item_id, movement_type (in,out,adjust), quantity NUMERIC, reason, related_event_id, recorded_at, recorded_by).
- `financial_accounts` (id UUID pk, farm_id, type (asset, liability, revenue, expense), name, currency, created_at).
- `financial_transactions` (id UUID pk, farm_id, account_id, counterparty, amount NUMERIC(12,2), currency, transaction_type, transaction_date, notes, related_animal_id, created_at).
- `invoices` (id UUID pk, farm_id, invoice_number, customer_name, status, issue_date, due_date, total_amount, currency, pdf_url, created_at, updated_at).
- `invoice_lines` (id BIGINT pk, invoice_id, description, quantity NUMERIC, unit_price NUMERIC, tax_rate, total_line_amount).

### 3.5 Notifications, sync, audit
- `notification_channels` (id UUID pk, profile_id, device_token, platform, last_seen_at).
- `notifications` (id UUID pk, farm_id, profile_id, type, title, body, metadata JSONB, delivered_at, read_at, created_at).
- `sync_logs` (id BIGINT pk, profile_id, farm_id, table_name, sync_type (full, delta), started_at, completed_at, status, details JSONB).
- `activity_logs` (id BIGINT pk, farm_id, profile_id, action, target_type, target_id, metadata JSONB, created_at).

### 3.6 Support, configuration et pieces jointes
- `app_settings` (key pk, value JSONB, updated_at) pour flags fermes.
- `documents` (id UUID pk, farm_id, module, file_url, mime_type, uploaded_by, uploaded_at).

## 4. Relations clefs
- `profiles` 1..n `farm_members` (via profile_id) et 1..n `notifications`.
- `farms` 1..n `animals`, `inventory_items`, `financial_transactions`, `events`.
- `animals` auto reference (sire_id, dam_id) et 1..n `breeding_records` (doe/buck).
- `breeding_records` 1..n `breeding_tasks`.
- `events` optionnellement lie a `animals`, `inventory_movements`, `financial_transactions`.
- `inventory_items` 1..n `inventory_batches` et `inventory_movements`.
- `invoices` 1..n `invoice_lines`.

## 5. Index et contraintes recommends
| Table | Index / Constraint |
| --- | --- |
| animals | unique (farm_id, tag_id); index (farm_id, status); index (farm_id, species_id); fk sire/dam -> animals ON DELETE SET NULL |
| breeding_records | index (farm_id, mating_date); constraint check kits_born_alive >= 0 |
| events | index (farm_id, event_date DESC); index (farm_id, status); |
| inventory_movements | index (farm_id, recorded_at DESC); |
| financial_transactions | index (farm_id, transaction_date DESC); index (farm_id, account_id); |
| notifications | index (profile_id, created_at DESC); |
| farm_members | unique (farm_id, profile_id); fk role_id -> roles |
| invoices | unique (farm_id, invoice_number); |

Triggers `set_updated_at()` sur tables principales pour rafraichir `updated_at`.

## 6. RLS et securite
- Tables rattachees a `farm_id`: politique `USING farm_id IN (SELECT farm_id FROM farm_members WHERE profile_id = auth.uid())`.
- Tables rattachees a `profile_id`: politique `profile_id = auth.uid()`.
- Roles: proprietaire peut gerer `farm_members`; lecture partagee selon permissions.
- Activer RLS avant insertion de donnees. Fournir policies specifiques pour operations de maintenance (service role) utilisees par edge functions.

## 7. Roadmap migrations (taches 017-019)
1. **Phase M0 (stabilisation)**
   - Exporter schema actuel et comparer avec cible.
   - Creer migrations base `profiles`, `farms`, `farm_members`, `roles`.
   - Script `set_updated_at` et triggers standards.
2. **Phase M1 (module animaux/reproduction)**
   - Migrer `animals`, `breeding_records`, `breeding_tasks`, `event_templates` (ajout farm_id, colonnes manquantes), `events`, `event_assignments`, `reminders`.
   - Ajout indexes et policies RLS.
3. **Phase M2 (finances/inventaire)**
   - Creer tables finances et inventaire, plus `inventory_movements` triggers pour calcul stock.
   - Edge functions `generate_invoice_number`, `recalculate_stock` (tache 019).
4. **Phase M3 (notifications/sync)**
   - Tables `notification_channels`, `notifications`, `sync_logs`, `activity_logs`.
   - Edge functions pour envoi push et log activation.
5. **Phase M4 (nettoyage)**
   - Supprimer colonnes obsoletes, renommer si besoin.
   - Ajouter `app_settings`, `documents`.

Chaque phase inclut migration SQL + tests (`supabase db reset` + jeux de donnees seeds) + mise a jour des modeles Dart (tache 021).

## 8. Actions immediates
- Creer un script `supabase/scripts/schema_status.md` pour suivre evolution (optionnel).
- Ouvrir stories techniques :
  - DB-01 Export schema actuel.
  - DB-02 Ecrire migrations Phase M0 (tache 017).
  - DB-03 Definir policies RLS globales (tache 018).
  - DB-04 Implementer fonctions/triggers Phase M2-M3 (tache 019).
- Synchroniser ce schema avec l equipe produit pour validation metier (notamment finances et inventaire).

## 9. Annexes
- Diagramme entite relation (a produire dans un outil externe, exemple dbdiagram.io) base sur la liste ci-dessus.
- Referencer ce document depuis `docs/architecture/` et la documentation projet (tache 046).
