

# Infos à retenir – Intégration WhatsApp / Email / SMS pour Khodan

## Contexte rapide

- Projet Khodan : appliquer les notifications réelles (paiement manuel, ventes, transferts…).
- Objectif : centraliser les étapes pour brancher des services externes (email, SMS, WhatsApp) sur les hooks (`NotificationServiceRegistry`).
- On suppose que Supabase est déjà configuré et que l’app Flutter utilise `NotificationServiceRegistry` (cf. `lib/data/services/notification_hooks.dart`).

## Options service par service

### Email

| Fournisseur | Avantages | Limites / coûts |
| --- | --- | --- |
| SendGrid | Offre gratuite (100 e-mails/jour), API simple (`POST /mail/send`), docs FR/EN abondantes | Surcroît de configuration DNS (SPF/DKIM), facturation USD si dépassement |
| Mailgun | Excellente délivrabilité, API claire | Forfait gratuit limité aux envois US, zone FR payante |
| Amazon SES | Prix imbattables si déjà sur AWS | Mise en route plus technique (IAM, vérifications DNS) |
| Brevo (Sendinblue) | Interface francisée, SMS intégrés | 300 e-mails/jour en gratuit, API parfois plus lente |

### SMS

| Fournisseur | Avantages | Limites / coûts |
| --- | --- | --- |
| Twilio | Couverture mondiale, docs très complètes | Prix USD et frais additionnels selon pays |
| Vonage (Nexmo) | Bon équilibre prix/services | Support parfois plus lent |
| Africa’s Talking | Spécialisé Afrique (SMS + Mobile Money) | Moins global que Twilio, API moins standard |
| Sinch | Pensé pour gros volumes | Mise en route plus lourde |

### WhatsApp Business Cloud (Meta)

- **Création** : via Meta Developers → créer une app → activer WhatsApp → obtenir un “Phone Number ID”, “WhatsApp Business Account ID” et un token d’accès.
- **Mode test** : Meta fournit un numéro temporaire + token valable 23 h.
- **Mode production** :
  - Vérifier l’entreprise dans Meta Business Manager (documents légaux).
  - Enregistrer son propre numéro (usage exclusif WhatsApp Business).
  - Créer un “system user” pour générer un access token long (à stocker dans `.env`).
- **Envoi** : appeller `POST https://graph.facebook.com/v18.0/<Phone-Number-ID>/messages` :
  ```json
  {
    "messaging_product": "whatsapp",
    "to": "<numéro client>",
    "type": "template",
    "template": { ... }  // modèle validé (ex: payment_pending)
  }
  ```
  - Utiliser l’entête `Authorization: Bearer <token>`.
  - Les templates doivent être pré-validés par Meta (catégories : transaction, alerte, marketing).
- **Webhooks** : optionnel, mais recommandé pour recevoir les accusés de réception / réponses. Nécessite une URL HTTPS (Supabase Edge Function, Cloud Run…).
- **Coûts** :
  - 1 000 conversations/mois gratuites (toutes régions cumulées).
  - Ensuite, facturation par conversation (24 h), tarif dépend du pays du destinataire (0,02 à 0,06 USD en Afrique francophone pour les notifications “utility”).
  - Conversations initiées par l’utilisateur moins chères.

## Étapes recommandées pour le projet

1. **Choisir les fournisseurs** :
   - Email : SendGrid pour démarrer (facile, plan gratuit).
   - SMS : Africa’s Talking si cible Afrique, sinon Twilio.
   - WhatsApp : API Meta (cloud) pour toucher les clients WhatsApp.
2. **Créer les comptes et récupérer les identifiants** :
   - Chaque service fournit une clé API ou un token (ex. `SENDGRID_API_KEY`, `TWILIO_ACCOUNT_SID`, `WHATSAPP_ACCESS_TOKEN`).
   - Stocker ces valeurs dans `.env` (ne pas les versionner).
3. **Brancher les hooks** :
   - Implémenter `EmailNotificationHook`, `SmsNotificationHook`, `WhatsAppNotificationHook`.
   - Dans l’initialisation de l’app (ex. `main.dart` ou un module DI), enregistrer :
     ```dart
     final registry = NotificationServiceRegistry.instance;
     registry.register(EmailNotificationHook(apiKey: env.sendgrid));
     registry.register(SmsNotificationHook(apiKey: env.sms));
     registry.register(WhatsAppNotificationHook(
       phoneNumberId: env.whatsAppPhoneId,
       accessToken: env.whatsAppToken,
     ));
     ```
4. **Configurer les templates (WhatsApp)** :
   - Créer au moins trois templates : `payment_pending`, `payment_confirmed`, `payment_rejected`.
   - Soumettre via Meta Business Manager → attendre l’approbation (quelques minutes/ heures).
5. **Tester bout en bout** :
   - Utiliser des adresses / numéros de test.
   - Vérifier que les notifications partent bien (et que Supabase enregistre les envois dans `notifications_outbox` si encore utilisé).
6. **Documenter pour l’équipe** :
   - Ajouter dans `docs/notifications-plan.md` ou ce fichier les variables d’environnement et les URL d’API utilisées.
   - Noter les coûts estimés (à jour en fonction des pays ciblés).

## Checklist rapide avant intégration

- [ ] Comptes créés (SendGrid, Twilio/Africa’s Talking, Meta WhatsApp).
- [ ] Clés/API stockées dans `.env` (`SENDGRID_API_KEY`, `SMS_API_KEY`, `WHATSAPP_PHONE_ID`, `WHATSAPP_ACCESS_TOKEN`…).
- [ ] Hooks implémentés et enregistrés.
- [ ] Templates WhatsApp validés.
- [ ] Tests réalisés avec comptes/téléphones de test.
- [ ] Documentation mise à jour (ici + `docs/notifications-plan.md`).

Tu peux revenir à ce document dès que tu as choisi le fournisseur le moins cher pour brancher directement le hook correspondant.
