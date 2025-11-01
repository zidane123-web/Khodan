# Guide d'execution des migrations Supabase

Derniere mise a jour : 2025-11-01 (Plan2 - tache 09).

## Pre-requis communs

- Installer la CLI Supabase (`npm install -g supabase` ou `npx supabase`).
- Disposer du `SUPABASE_ACCESS_TOKEN` lie au projet `rmtkvalfhbhhqczwvtoz`.
- Conserver le fichier `.env` a jour (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Activer une session `authenticated` lors des verifications PostgREST (commande de creation d'utilisateur jetable plus bas).

## Methode A : CLI (`supabase db push`)

1. Charger les variables :
   ```bash
   set SUPABASE_ACCESS_TOKEN=<token_personnel>
   ```
2. Lier le projet (une seule fois par machine) :
   ```bash
   supabase login
   supabase link --project-ref rmtkvalfhbhhqczwvtoz
   ```
3. Verifier les migrations en local :
   ```bash
   supabase db lint
   ```
4. Envoyer les migrations :
   ```bash
   supabase db push
   ```
5. Controler l'etat distant :
   ```bash
   supabase db remote commit --dry-run
   ```

**Problemes frequents**

- `Error: failed to link project` : le token n'a pas la portee necessaire. Regenerer un access token depuis le dashboard.
- `FATAL: password authentication failed` : la CLI tente de joindre la base sans WSL. Utiliser `supabase link --password <db_password>` (mot de passe visible dans Settings > Database).
- Blocage sous Windows (PowerShell) : executer la commande via Git Bash ou lancer `supabase db push --db-url postgres://postgres:<db_password>@db.rmtkvalfhbhhqczwvtoz.supabase.co:5432/postgres`.

## Methode B : SQL Editor (fallback)

1. Ouvrir `https://app.supabase.com/project/rmtkvalfhbhhqczwvtoz/sql`.
2. Coller le contenu de la migration a appliquer :
   ```sql
   -- 20251101090000_task_templates_and_notifications.sql
   <contenu du fichier>
   ```
3. Executer en mode `Run` (onglet configure sur la base `postgres`).
4. Enregistrer la migration :
   ```sql
   INSERT INTO supabase_migrations.schema_migrations (version, name)
   VALUES ('20251101090000', '20251101090000_task_templates_and_notifications.sql')
   ON CONFLICT (version) DO NOTHING;
   ```
5. Noter le resultat (copier/coller du panneau de sortie) dans cette section.

### Journal 2025-11-01 (Plan2 tache 09)

- Migration a appliquer : `supabase/migrations/20251101090000_task_templates_and_notifications.sql`.
- Statut CLI : encore instable sous Windows -> utiliser **Methode B**.
- Requetes de verification a lancer apres execution :
  ```sql
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name LIKE 'task_template%';

  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name LIKE 'notification%';
  ```
- Resultats attendus :
  ```
  task_template_assignment_events
  task_template_assignments
  task_template_steps
  task_templates

  notification_preferences
  notifications_outbox
  ```

  **Execute le 01/11/2025 - OK**

```text
task_template_assignment_events
task_template_assignments
task_template_steps
task_templates
```

```text
notification_preferences
notifications_outbox
```

**Migration 20251101103000 (01/11/2025) - OK via SQL Editor**

```text
health_records
health_treatments
```

```text
ailments
```

_Remarque : LIKE utilise `_` comme joker, remplacer par `LIKE 'health%'` pour verifier les tables._

## SQL de controle apres migration

Executer les requetes suivantes dans le SQL Editor (ou `psql`) et archiver les sorties.

```sql
-- Liste des tables publiques
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```
**Resultat du 31/10/2025**  
Tables `breeding_records` et `breeding_metrics` absentes. Leur creation reste a planifier (Methode B recommandee tant que la CLI est instable).

```sql
-- Triggers actifs
SELECT event_object_table, trigger_name
FROM information_schema.triggers
WHERE event_object_schema = 'public'
ORDER BY event_object_table, trigger_name;
```
**Resultat du 31/10/2025**
```
event_object_table | trigger_name
-------------------|--------------------------------
event_templates    | trg_event_templates_updated_at
food_stock         | trg_food_stock_updated_at
food_types         | trg_food_types_updated_at
knowledge_articles | trg_knowledge_articles_updated_at
support_requests   | trg_support_requests_updated_at
```
=> Les triggers `trg_*_updated_at` sont bien presents pour maintenir `updated_at`.

```sql
-- Policies RLS
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```
**Resultat du 31/10/2025**
```
schemaname | tablename           | policyname
-----------|---------------------|---------------------------------------------
public     | animal_events       | animal_events_owner_manage
public     | animal_images       | animal_images_insert_owner
public     | animal_images       | animal_images_select_owner
public     | animals             | animals_owner_manage
public     | event_templates     | event_templates_owner_all
public     | events              | events_owner_manage
public     | food_stock          | food_stock_owner_all
public     | food_types          | food_types_owner_all
public     | knowledge_articles  | knowledge_articles_manage_service_role
public     | knowledge_articles  | knowledge_articles_read_authenticated
public     | profiles            | profiles_insert_self
public     | profiles            | profiles_update_self
public     | profiles            | profiles_select_self
public     | species_config      | species_config_owner_all
public     | support_requests    | support_requests_delete_service_role
public     | support_requests    | support_requests_insert_owner
public     | support_requests    | support_requests_select_owner
public     | support_requests    | support_requests_update_service_role
public     | user_preferences    | user_preferences_owner_all
```
=> Toutes les tables sensibles restent protegees par des policies RLS actives.

Comptes `codex-agent+*@example.com` supprimes le 30/10/2025 (Auth > Users).

### Journal 2025-11-01 (Plan2 tache 10)

- Migration a appliquer : `supabase/migrations/20251101103000_health_module.sql`.
- Contexte : la CLI reste instable sous Windows -> preferer **Methode B** (SQL Editor).
- Requetes de verification a executer apres application :
  ```sql
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('ailments', 'health_records', 'health_treatments');
  ```
- Resultats attendus :
  ```text
  ailments
  health_records
  health_treatments
  ```
- Pour controler les index :
  ```sql
  SELECT indexname, tablename
  FROM pg_indexes
  WHERE schemaname = 'public'
    AND tablename IN ('ailments', 'health_records', 'health_treatments');
  ```
- Pour valider les policies RLS :
  ```sql
  SELECT tablename, policyname
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('ailments', 'health_records', 'health_treatments');
  ```
- Statut : a executer via SQL Editor (copier le fichier + insertion dans `schema_migrations` avec la version `20251101103000`).

### Journal 2025-11-01 (Plan2 tache 11)

- Migration a appliquer : `supabase/migrations/20251101120000_finances_and_contacts.sql`.
- Instructions : utiliser **Methode B** (SQL Editor) si `supabase db push` continue d'echouer sur PowerShell.
- Requetes de verification :
  ```sql
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('contacts', 'transaction_categories', 'financial_transactions');

  SELECT policyname, tablename
  FROM pg_policies
  WHERE schemaname = 'public'
    AND tablename IN ('contacts', 'transaction_categories', 'financial_transactions')
  ORDER BY tablename, policyname;

  SELECT indexname, tablename
  FROM pg_indexes
  WHERE schemaname = 'public'
    AND tablename IN ('contacts', 'transaction_categories', 'financial_transactions');
  ```
- Enregistrer le resultat du SQL Editor ici une fois applique. Inclure la commande d'insertion dans `supabase_migrations.schema_migrations` :
  ```sql
  INSERT INTO supabase_migrations.schema_migrations (version, name)
  VALUES ('20251101120000', '20251101120000_finances_and_contacts.sql')
  ON CONFLICT (version) DO NOTHING;
  ```
**Ex�cut� le 01/11/2025 � OK via SQL Editor**

```text
contacts
financial_transactions
transaction_categories
```

```text
contact_owner_all
financial_transactions_owner_all
transaction_categories_owner_all
```

```text
financial_transactions_profile_idx
transaction_categories_profile_idx
```

## Creation rapide d'un token `authenticated` pour tests API

```powershell
$env:SUPABASE_ANON_KEY = '<copie depuis .env>'
$headers = @{ apikey=$env:SUPABASE_ANON_KEY; 'Content-Type'='application/json'; Accept='application/json' }
$email = 'codex-agent+' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + '@example.com'
$body = @{ email=$email; password='TempPass123!' } | ConvertTo-Json
$session = Invoke-RestMethod -Uri 'https://rmtkvalfhbhhqczwvtoz.supabase.co/auth/v1/signup' -Headers $headers -Method Post -Body $body
$session.access_token
```
Utiliser le token renvoye dans l'en-tete `Authorization: Bearer <token>` pour tester les endpoints PostgREST proteges par RLS.

## Lancement Flutter (web)

Depuis l'activation de Drift sur IndexedDB, la version web peut etre testee directement :

```bash
flutter run -d chrome
```

> Note : lors du premier lancement, Chrome peut afficher un log `Opening web database khodan_local for the first time`. Message attendu, pas une erreur.

## Migrations futures a planifier

- **Finances** : tables `transactions`, `transaction_items`, `contacts`, vues de synthese.
- **Sante** : tables `health_templates`, `medications`, vues de synthese (complements au module livre).
- **Notifications** : table `notification_preferences`, table `notifications` (log) + edge function.
- **Abonnements** : tables `plans`, `subscriptions`, `invoices`, `subscription_limits`.
- **Rapports avances** : vues materialisees reproduction, croissance, finance; fonction `get_advanced_reports`.
- **Pedigrees** : table `pedigree_exports` + fonction recursive pour l'arbre genealogique.
- **Cartes de clapier / QR** : table `cage_card_templates`, stockage des exports generes.
- **Personnalisation** : etendre `user_preferences` (langue, unite, theme) si besoin.

### Journal 2025-11-02 (Plan2 tache 12)

- Migration a appliquer : `supabase/migrations/20251101143000_reports_views.sql`.
- Contexte : ajoute trois vues (`view_reports_reproduction`, `view_reports_growth`, `view_reports_finances`) et la fonction `fn_report_finance_summary`.
- Si la CLI reste instable, utiliser **Methode B** (SQL Editor) : coller le script complet, executer, puis enregistrer la version via
  ```sql
  INSERT INTO supabase_migrations.schema_migrations (version, name)
  VALUES ('20251101143000', '20251101143000_reports_views.sql')
  ON CONFLICT (version) DO NOTHING;
  ```
- Requetes de verification :
  ```sql
  SELECT table_schema, table_name
  FROM information_schema.views
  WHERE table_schema = 'public'
    AND table_name IN (
      'view_reports_reproduction',
      'view_reports_growth',
      'view_reports_finances'
    );

  SELECT proname
  FROM pg_proc
  WHERE proname = 'fn_report_finance_summary';

  SELECT *
  FROM view_reports_reproduction
  WHERE period_start >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
  LIMIT 10;
  ```
- Resultats attendus : trois vues retournees + fonction. Archiver les extraits SQL Editor dans le rapport de tache.
