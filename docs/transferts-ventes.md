# Vente et transferts - Alignement Everbreed

S'inspirer des parcours Everbreed relevés dans `Info-de référence/` (captures, PDF et vidéo) permet d'offrir une expérience rassurante aux débutants : chaque action est contextualisée, les montants sont reliés au ledger et une notification confirme la réception côté acheteur ou destinataire. Les trois sous-flux ci-dessous s'appuient sur le socle Finances (`docs/finances-spec.md`), Notifications (`docs/notifications-plan.md`) et Rapports (`docs/rapports-spec.md`) afin de rester cohérents avec la feuille de route (`Plan2/roadmap-khodan.md`).

## Vente locale

**Champs clefs**

| Champ | Description | Notes Everbreed/Khodan |
| --- | --- | --- |
| `animal_id` | Lapin à vendre (liste filtrée sur `status in ('active','breeding')`). | Afficher le tag + photo miniature comme Everbreed lors de la sélection. |
| `contact_id` | Acheteur existant (type `client`) ou création rapide depuis le formulaire. | Reprendre les validations de `docs/finances-spec.md`. |
| `price` + `currency` | Montant TTC, verrouillé sur `currency` du profil. | Encadrement : `price > 0` et rappel du prix moyen (Everbreed affiche des bornes). |
| `payment_method` | Cash, Mobile Money, Chèque, Autre. | Pré-rempli avec la dernière méthode utilisée. |
| `proof_url` / `proof_name` | Photo de reçu ou PDF signé. | Stockage dans `receipts/` comme pour les pièces financières. |
| `notes` | Conseils post-vente, numéro d'enregistrement. | Visible sur le reçu exporté. |
| `status` | `draft`, `pending`, `completed`, `cancelled`. | Bouton "Confirmer la vente" verrouille l'édition. |

**Flux financiers**

- La création appelle `RabbitSalesService.createLocalSale()` qui :
  - Résout l'ID de catégorie `sales` et enregistre un `financial_transactions` (flow `income`).
  - Insère `rabbit_sales` avec `financial_transaction_id` pour tracer la pièce.
  - Passe le lapin en `status = 'sold'` et `deleted_at = NOW()` dès que la vente est marquée `completed`.
- Annulation : `RabbitSalesService.cancelSale()` supprime le mouvement financier (rollback) et remet `animals.status = 'active'`.
- Export : bouton `Exporter > CSV` reprend les colonnes `sale_id, animal_tag, contact_name, price, payment_method, status, occured_on`.

**Notifications & garde-fous**

- Dès qu'une vente est créée ou confirmée, `NotificationServiceRegistry` propage un `NotificationPayload` (`metadata.event = sale.created|sale.completed`) vers les hooks Email/SMS (cf. `docs/notifications-plan.md`). Message court : "Nouvelle vente ${price} FCFA - confirmer le paiement".
- Avertissements pour débutants :
  1. Bannière "Vérifiez le poids récent avant la vente" (Everbreed propose un rappel similaire).
  2. Dialogue de confirmation listant animal, contact, prix et mode de paiement.
  3. Astuce "Conservez la preuve dans Supabase Storage" avec lien d'aide.

## Transfert vers un compte Khodan

**Champs et validations**

| Champ | Description | Garde-fous |
| --- | --- | --- |
| `animal_id` | Même picker que la vente mais limité aux animaux non vendus ni transférés. | Badge rouge si le lapin possède des tâches en retard. |
| `recipient_profile_id` | UUID du compte cible (saisi par e-mail ou code ferme). | Auto-complétion basée sur les invitations envoyées récemment. |
| `contact_id` (optionnel) | Contact temporaire si le destinataire n'a pas encore accepté l'invitation. | Permet de garder un numéro de téléphone en cas d'échec. |
| `status` | `pending`, `accepted`, `rejected`, `cancelled`, `completed`. | Transition `completed` force l'archive du lapin côté source. |
| `transfer_fee` | Frais logistique éventuels. | Génère un mouvement `financial_transactions` (flow `neutral`, catégorie `transfer`). |
| `notes` | Raison, conditions de quarantaine. | Injecté dans la notification envoyée. |

**Processus**

1. `RabbitSalesService.initiateTransfer()` insère `rabbit_transfers` (statut `pending`), relie éventuellement un flux financier neutre et crée une notification "Transfert en attente" pour l'autre profil.
2. Le destinataire utilise le même écran pour `accepter` ou `rejeter`. Acceptation :
   - Met à jour `rabbit_transfers.status = 'completed'`.
   - Archive le lapin dans la ferme source (`deleted_at` renseigné) et ouvre une tâche manuelle "Importer l'animal" pour le destinataire (à connecter plus tard).
3. Rejet/annulation : statut `cancelled`/`rejected`, suppression du flux financier et message "Transfert annulé".

**Notifications & garde-fous**

- Hooks Email/SMS : sujet "Transfert de ${animalTag}" + CTA "Accepter dans les 48h".
- Débutant :
  - Carte tutorielle "Comment fonctionne un transfert ?" (inspirée de l'overlay Everbreed).
  - Timer visuel (badge `J-2`) avant expiration automatique.
  - Bloc "Rappel finances" expliquant que les frais sont neutres dans le ledger.

## Mini-annonces marketplace

**Champs principaux**

| Champ | Description |
| --- | --- |
| `title` / `description` | Titre court (<= 60 caractères) et description structurée (points clés : âge, poids, lignée). |
| `animal_id` | Optionnel pour publier un lot générique. Lorsqu'il est renseigné, on affiche pedigree + dernière pesée. |
| `contact_id` ou `contact_channel` | Email/téléphone à exposer publiquement. |
| `price`, `currency`, `is_negotiable` | Bornes de prix affichées sous forme de chips (Everbreed liste les fourchettes). |
| `media_urls` | Jusqu'à 5 images stockées dans un bucket `marketplace`. |
| `status` | `draft`, `published`, `paused`, `expired`, `sold`, `withdrawn`. |
| `published_at` / `expires_at` | Permet de masquer automatiquement les annonces (cron côté Supabase à prévoir). |
| `fee_transaction_id` | Référence vers les frais de mise en avant (categorie `sales` ou `other`). |

**Fonctionnalités clés**

- Publication : `RabbitSalesService.publishListing()` crée ou met à jour `marketplace_listings`, déclenche une notification interne "Annonce publiée".
- Mise en pause / retrait : boutons secondaires sur chaque carte, confirmation avant suppression.
- Export : bouton "Exporter en PDF" (todo) + CSV minimal (`listing_id,title,status,price,expires_at`).
- Responsive : grille sur bureau (2 colonnes, ratio 4/3), liste verticale sur mobile.

**Garde-fous & notifications**

- Aperçu avant publication reprenant l'affichage final (Everbreed propose la même prévisualisation).
- Limite de 10 annonces actives par profil (message d'erreur pédagogique).
- Notification automatique 72h avant expiration (`metadata.event = marketplace.expiring`) envoyée via les hooks enregistrés.

### Commandes de vérification Flutter

Toujours rejouer les commandes suivantes avant publication d'une évolution liée aux ventes / marketplace :

```bash
flutter analyze
flutter test
```

Elles garantissent que les formulaires (widget test) et la logique métier restent cohérents avec les attentes décrites ci-dessus.

