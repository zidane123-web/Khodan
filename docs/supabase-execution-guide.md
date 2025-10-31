# Guide d'execution des migrations Supabase

Derniere mise a jour : 2025-10-30 (tache 03).

## Pre-requis communs
- Installer la CLI Supabase (`npm install -g supabase` ou `npx supabase`).
- Disposer du `SUPABASE_ACCESS_TOKEN` lie au projet `rmtkvalfhbhhqczwvtoz`.
- Conserver le fichier `.env` a jour (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Activer une session `authenticated` lors des verifications PostgREST (voir ci-dessous pour la commande de creation d'utilisateur jetable).

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

**Problemes rencontres frequents**
- `Error: failed to link project`: le token n'a pas la portee necessaire; regenerer un access token depuis le dashboard.
- `FATAL: password authentication failed`: la CLI tente de joindre la base sans WSL -> utiliser `supabase link --password <db_password>` (mot de passe visible dans Settings → Database).
- Blocage sous Windows (PowerShell) : lancer la commande via Git Bash ou executer `supabase db push --db-url postgres://postgres:<db_password>@db.rmtkvalfhbhhqczwvtoz.supabase.co:5432/postgres`.

## Methode B : SQL Editor (fallback)
1. Ouvrir `https://app.supabase.com/project/rmtkvalfhbhhqczwvtoz/sql`.
2. Coller le contenu de la migration a appliquer (exemple) :
   ```sql
   -- 20251022120000_post_task15_adjustments.sql
   <contenu du fichier>
   ```
3. Executer en mode `Run` (s'assurer que l'onglet est configure sur la base `postgres`).
4. Enregistrer la migration dans `schema_migrations` pour garder la coherence :
   ```sql
   INSERT INTO supabase_migrations.schema_migrations (version, name)
   VALUES ('20251022120000', '20251022120000_post_task15_adjustments.sql')
   ON CONFLICT (version) DO NOTHING;
   ```
5. Noter le resultat (copier/coller du panneau de sortie) dans le present guide.

## SQL de controle apres migration
Executer les requetes suivantes dans le SQL Editor (ou via `psql`) et archiver les sorties :
```sql
-- Liste des tables publiques
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```
**Résultat le 31/10/2025**  
Tables `breeding_records` et `breeding_metrics` absentes. Leur création devra être planifiée (méthode B recommandée tant que la CLI est instable).

-- Triggers actifs
SELECT event_object_table, trigger_name
FROM information_schema.triggers
WHERE event_object_schema = 'public'
ORDER BY event_object_table, trigger_name;
```
**Résultat le 31/10/2025**
```text
event_object_table | trigger_name
-------------------|--------------------------------
event_templates    | trg_event_templates_updated_at
food_stock         | trg_food_stock_updated_at
food_types         | trg_food_types_updated_at
knowledge_articles | trg_knowledge_articles_updated_at
support_requests   | trg_support_requests_updated_at
```
→ Les triggers `trg_*_updated_at` sont bien présents sur les tables critiques pour mettre à jour `updated_at`.

-- Policies RLS
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```
**Résultat le 31/10/2025**
```text
schemaname | tablename        | policyname
-----------|------------------|---------------------------------------------
public     | animal_events    | Les utilisateurs peuvent gérer leurs propres liens animal_events
public     | animal_images    | Les utilisateurs peuvent insérer des images pour leurs propres animaux
public     | animal_images    | Les utilisateurs peuvent voir leurs propres images d’animaux
public     | animaux          | Les utilisateurs peuvent gérer leurs propres animaux
public     | event_templates  | event_templates_owner_all
public     | épreuves         | Les utilisateurs peuvent gérer leurs propres événements
public     | food_stock       | food_stock_owner_all
public     | food_types       | food_types_owner_all
public     | knowledge_articles | knowledge_articles_manage_service_role
public     | knowledge_articles | knowledge_articles_read_authenticated
public     | profils          | Les utilisateurs peuvent créer leur propre profil
public     | profils          | Les utilisateurs peuvent modifier leur propre profil
public     | profils          | Les utilisateurs peuvent voir leur propre profil
public     | species_config   | Les utilisateurs peuvent gérer leurs propres configurations
public     | support_requests | support_requests_delete_service_role
public     | support_requests | support_requests_insert_owner
public     | support_requests | support_requests_select_owner
public     | support_requests | support_requests_update_service_role
public     | user_preferences | Les utilisateurs peuvent gérer leurs propres préférences
```
→ Toutes les tables sensibles restent protégées par des policies RLS actives.

Comptes `codex-agent+…@example.com` supprimés le 30/10/2025 (Auth > Users).

## Creation rapide d'un jeton `authenticated` pour tests API
```powershell
$env:SUPABASE_ANON_KEY = '<copie depuis .env>'
$headers = @{ apikey=$env:SUPABASE_ANON_KEY; 'Content-Type'='application/json'; Accept='application/json' }
$email = 'codex-agent+' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + '@example.com'
$body = @{ email=$email; password='TempPass123!' } | ConvertTo-Json
$session = Invoke-RestMethod -Uri 'https://rmtkvalfhbhhqczwvtoz.supabase.co/auth/v1/signup' -Headers $headers -Method Post -Body $body
$session.access_token
```
Utiliser le jeton renvoye dans l'en-tete `Authorization: Bearer <token>` pour tester les endpoints PostgREST qui sont proteges par RLS.

## Lancement Flutter (web)
Depuis l'activation de Drift sur IndexedDB, la version web peut etre testee directement :
```bash
flutter run -d chrome
```
> Note : lors du premier lancement, Chrome peut afficher un log `Opening web database khodan_local for the first time`. Ce message est attendu et n'indique pas d'erreur.

## Migrations futures a planifier
- **Finances** : tables `transactions`, `transaction_items`, `contacts`, vues de synthese.
- **Sante** : tables `health_records`, `health_templates`, `medications`, journaux de traitements.
- **Notifications** : table `notification_preferences`, table `notifications` (log) + edge function.
- **Abonnements** : tables `plans`, `subscriptions`, `invoices`, `subscription_limits`.
- **Rapports avances** : vues materialisees pour reproduction, croissance, finance; fonction `get_advanced_reports`.
- **Pedigrees** : table `pedigree_exports` + fonction recursive generant l'arbre.
- **Cartes de clapier / QR** : table `cage_card_templates`, stockage des exports generes.
- **Personnalisation** : etendre `user_preferences` (langue, unite, theme) si non couvre deja les besoins.
