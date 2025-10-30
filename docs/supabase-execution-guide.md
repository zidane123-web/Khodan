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

-- Triggers actifs
SELECT event_object_table, trigger_name
FROM information_schema.triggers
WHERE event_object_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Policies RLS
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

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

## Migrations futures a planifier
- **Finances** : tables `transactions`, `transaction_items`, `contacts`, vues de synthese.
- **Sante** : tables `health_records`, `health_templates`, `medications`, journaux de traitements.
- **Notifications** : table `notification_preferences`, table `notifications` (log) + edge function.
- **Abonnements** : tables `plans`, `subscriptions`, `invoices`, `subscription_limits`.
- **Rapports avances** : vues materialisees pour reproduction, croissance, finance; fonction `get_advanced_reports`.
- **Pedigrees** : table `pedigree_exports` + fonction recursive generant l'arbre.
- **Cartes de clapier / QR** : table `cage_card_templates`, stockage des exports generes.
- **Personnalisation** : etendre `user_preferences` (langue, unite, theme) si non couvre deja les besoins.
