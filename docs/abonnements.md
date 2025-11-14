# Abonnements Khodan

Synthèse réalisée à partir de la roadmap (`Plan2/roadmap-khodan.md`), de l'analyse Everbreed (`docs/everbreed-gap-analysis.md`) et des captures/vidéo du dossier `Info-de référence/`. L'objectif est d'aligner l'expérience « Mon compte » sur la vision Khodan : quatre plans clairs, un flux de paiement rassurant et des garde-fous techniques côté Supabase/Flutter.

## 1. Plans et limites

| Plan | Positionnement | Modules inclus | Limites éleveurs / membres | Stockage Supabase |
| --- | --- | --- | --- | --- |
| **Gratuit (code `free`)** | Démarrage autonome pour petites fermes | Tableau de bord, Éleveurs, Planning léger, accès web/mobile (navigation conforme à `docs/navigation-khodan.md`) | 5 éleveurs actifs, 1 membre (propriétaire) | 100 Mo (photos compressées uniquement) |
| **Standard (code `standard`)** | Suivi quotidien des élevages en croissance | Modules Gratuit + Portées & cages, Rapports essentiels, Ventes locales | 50 éleveurs, 3 membres (propriétaire + 2 assistants) | 2 Go |
| **Pro (code `pro`)** | Fermes multi-sites avec reporting | Modules Standard + Santé, Stocks alimentaires, Marketplace locale | 250 éleveurs, 10 membres | 10 Go |
| **Entreprise (code `enterprise`)** | Coopératives / intégrateurs, support dédié | Tous les modules + personnalisation avancée (workflows, notifications, API) | 500 éleveurs (extensible via contrat), membres illimités validés par Khodan | 50 Go (extensions possibles) |

Notes rapides :

- Les limites sont matérialisées dans `subscription_plans.max_breeders`, `max_members` et `storage_limit_mb`. Les comptes gratuits affichent automatiquement un bandeau d'alerte quand la limite est atteinte (voir `MonComptePage`).
- Chaque plan référence les modules dans `subscription_plans.modules` (tableau texte) ; cette liste sert à masquer les écrans non inclus et à piloter les upsells dans la navigation.

## 2. Processus de montée / descente en gamme

1. **Depuis Mon compte** (`Paramètres > Mon compte`) :
   - Onglet *Abonnement* affiche le plan courant, les quotas utilisés et le bouton *Changer de plan*.
   - Un tutoriel succinct rappelle les étapes (sélection du plan → instructions de paiement → validation manuelle/cron).
2. **Choix du plan** : sélection d'une carte plan → confirmation des limites → génération d'une référence (`PLAN-<code>-<horodatage>`).
3. **Flux manuel / mobile money** : tant que Stripe n'est pas actif, la mise à niveau crée un enregistrement `user_subscriptions` avec `status = 'pending_manual_payment'`, le champ `manual_payment_reference` et un bloc `metadata.payment` décrivant les instructions.
4. **Validation** : après réception du justificatif (upload du reçu dans Supabase Storage ou ajout `invoice_url`), un administrateur passe le statut à `active`. En cas de rétrogradation, la date `end_at` est renseignée et l'ancien plan reste actif jusqu'à l'échéance.
5. **Blocages automatiques** :
   - Si `quota_breeders_used >= plan.max_breeders`, les créations d'éleveurs sont bloquées (bouton grisé + lien *Changer de plan*).
   - Idem pour `farm_members` (limite d'équipe). Les limites de stockage déclenchent une alerte mais l'upload reste possible tant que Supabase accepte les fichiers.

## 3. Paiement et justificatifs

- **Manuel aujourd'hui** :
  - Référence unique affichée à l'utilisateur et envoyée via `NotificationServiceRegistry` (`event = subscription.payment.requested`).
  - L'utilisateur verse le montant sur le compte mobile money indiqué, puis ajoute la preuve (photo PDF) ; le lien est stocké dans `user_subscriptions.invoice_url`.
  - Conserver : référence, reçu/payment slip, identité du payeur, date d'encaissement.
- **Mobile money (USSD / app)** : scénario similaire mais la référence devient le message reçu. `user_subscriptions.metadata` contient `{"payment_channel":"mobile_money","msisdn":"..."}`.
- **Stripe (à venir)** :
  - Prévoir `metadata.stripe_checkout_session_id` et `status = 'pending_stripe'` tant que la session n'est pas confirmée.
  - Libération du plan après webhook → `status = 'active'`, `invoice_url` pointe vers la facture Stripe.
- **Archivage** : conserver tous les justificatifs dans Supabase Storage (`billing-receipts/{profile_id}/...`) + `metadata.audit` (JSON) pour tracer l'opérateur (admin, cron, edge function).

## 4. Commandes de vérification

Avant publication ou QA, lancer les vérifications suivantes (issue #16) :

```bash
flutter analyze
flutter test
```

> En cas de blocage de la CLI Supabase sous Windows, appliquer la migration via l'éditeur SQL (voir `docs/supabase-execution-guide.md`) puis relancer les commandes ci-dessus pour s'assurer que l'UI *Mon compte* et les bannière quotas restent sans avertissement.

