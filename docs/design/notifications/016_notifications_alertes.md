# Notifications & alertes critiques (Oct 2025)

Spécification design pour la tâche 016.

## 1. Objectifs
- Définir la stratégie de notification multi-canal (push, email, in-app).
- Mettre en place un centre de notifications clair et actionnable.
- Permettre aux utilisateurs de configurer leurs préférences.

## 2. Types de notifications
- **Reproduction** : palpation à venir, mise bas, sevrage.
- **Santé** : traitement à renouveler, alerte sanitaire.
- **Stocks** : niveau critique, date péremption.
- **Finances** : facture en retard, paiement reçu.
- **App** : mise à jour, information système.

## 3. Canal & format
| Type | Push | Email | In-app (centre) |
| --- | --- | --- | --- |
| Reproduction | Oui | Optionnel | Oui |
| Santé | Oui (urgent) | Oui | Oui |
| Stocks | Oui | Optionnel | Oui |
| Finances | Oui (résumé) | Oui | Oui |
| App | Oui | Optionnel | Oui |

- Push format : titre court + message, CTA (ouvrir écran pertinent).
- Email : template HTML simple, branding Khodan, CTA bouton.
- In-app : cards listées dans centre notifications.

## 4. Centre de notifications (UI)
- Accessible via icône cloche (badge).
- Panneau latéral (desktop) ou page (mobile).
- Sections : Non lues, Toutes, Archives.
- Carte notification : icône type, titre, message, timestamp, CTA («Voir», «Marquer comme lu»).
- Actions bulk : `Tout marquer comme lu`, `Effacer toutes` (confirmation).
- Mode offline : afficher icône, message «Notifications disponibles dès reconnexion».

## 5. Préférences notifications
- Présent dans Paramètres > Notifications (cf. tâche 014).
- Switch par type/canal.
- Option résumé quotidien (heure configurable).

## 6. Notifications critiques (alerting)
- Cas santé/stock : afficher toast + possibilité marqueur prioritaire (couleur danger).
- Notifications persistantes (dans top bar) tant que non résolues -> `KhodanTag` danger.

## 7. Accessibilité
- Notifications push: inclure texte complet, éviter reliance uniquement aux emojis.
- Centre in-app: navigation clavier, rôle ARIA (tablist/listitem).
- Couleurs: respecter contraste (danger red sur fond clair, etc.).

## 8. Composants à implémenter
- `KhodanNotificationBell` (badge nombre).
- `KhodanNotificationDrawer`.
- `KhodanNotificationCard`.
- `KhodanNotificationPreferences` (list switch).

## 9. Livrables design
- Maquettes centre notifications (desktop/mobile).
- Template push/email (Figma + HTML de référence).
- Icônes type (reproduction, santé, stock, finance, info).
- Documentation ton/message (ex: style voix).

## 10. Actions suivantes
1. Designer: produire maquettes + templates.
2. PO: valider types critiques et SLA (qui reçoit quoi, quand).
3. Dev: préparer implémentation (tâches 024, 036) + intégration Supabase/FCM.
