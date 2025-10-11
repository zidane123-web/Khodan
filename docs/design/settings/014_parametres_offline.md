# Paramètres & mode offline (Oct 2025)

Spécification design pour la tâche 014.

## 1. Objectifs
- Offrir une gestion complète des préférences utilisateur/ferme, équipe, notifications.
- Présenter clairement l état de synchronisation offline et permettre sa gestion.

## 2. Structure page paramètres (desktop)
- **Navigation latérale** (tabs) : Profil, Équipe & rôles, Fermes, Notifications, Offline & synchronisation, Sécurité, Support.
- **Zone contenu** : cartes/sections détaillées.

### Profil
- Champs : nom, photo, coordonnées, langue, thème (clair/sombre futur), fuseau horaire.
- Boutons : `Enregistrer`, `Changer mot de passe`, `Supprimer compte` (danger).

### Équipe & rôles
- Tableau membres (Nom, Rôle, Statut, Dernière connexion).
- Bouton `Inviter un membre` (modale email + rôle).
- Dropdown rôle (Admin, Manager, Technicien, Observateur).
- Actions : réinviter, désactiver, transférer propriété.

### Fermes
- Liste fermes accessibles, possibilité basculer (tag `Courante`).
- Bouton `Créer une ferme` -> form (nom, localisation, devise).

### Notifications
- Switch par canal : push mobile, email, SMS (future).
- Liste catégories : reproduction, santé, stocks, finances.
- Option de résumé quotidien.

### Offline & synchronisation
- Banner état : `Connecté`, `Mode hors ligne`, `Sync en attente`.
- Dernière sync, taille des données locales, bouton `Forcer synchronisation`.
- Liste files pending (ex: 5 fiches animaux en attente) -> `KhodanCard`.
- Option `Purger cache local` (danger + confirmation).

### Sécurité
- MFA (activer/désactiver), appareils enregistrés.
- Logs d activité (derniers accès).

### Support
- Liens vers FAQ, contact support, rapport bug, versions app.

## 3. Mode mobile
- Navigation par onglets horizontaux ou menu déroulant.
- Sections empilées, CTA sticky en bas.

## 4. Accessibilité
- Focus visible (inputs, boutons).
- Composants switch accessibles.
- Feedback clair sur sync (texte + icône).

## 5. Composants à implémenter
- `KhodanSettingsList` (sections + titrage).
- `KhodanSyncStatusBanner` (évolution selon état).
- `KhodanMemberInviteDialog`.
- `KhodanNotificationToggle`.

## 6. Livrables design
- Maquettes desktop & mobile.
- Illustrations ou icône offline.
- Messages d état (succès, erreur sync, purge cache).

## 7. Actions suivantes
1. Designer : produire maquettes.
2. PO : valider rôles/permissions et options notifications.
3. Dev : préparer implémentation (tâches 037, 024, 036, 030).
