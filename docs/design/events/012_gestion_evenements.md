# Hub événements & tâches (Oct 2025)

Spécification design pour la tâche 012.

## 1. Objectif
- Centraliser toutes les actions opérationnelles (santé, maintenance, tâches équipe).
- Offrir vues multiples : liste, calendrier, kanban.
- Faciliter la création rapide d événements et affectations.

## 2. Écran hub événements
- **Header** : titre, filtre période, filtres type (santé, reproduction, maintenance, finance), bouton `Créer un événement` (primary).
- **Tabs** : `Liste`, `Calendrier`, `Kanban`.

### Vue Liste
- Table à colonnes : Titre, Type, Date, Assigné à, Statut, Actions.
- Tri par date asc/dsc, filtres (statut, assigné, module).
- Checkbox multi-sélection -> actions batch (`Marquer comme complété`, `Notifier équipe`).

### Vue Calendrier
- Calendrier mensuel (desktop), vue agenda jour/semaine (mobile).
- Événements colorés selon type.
- Cliquer => panneau latéral avec détails + CTA `Compléter` / `Éditer`.

### Vue Kanban
- Colonnes par statut : À faire, En cours, Terminé, En retard.
- Cartes événements -> drag & drop (si support technique) / sinon actions `Changer de statut`.
- Carte affiche Titre, date, assignee (avatar), tag type.

## 3. Création / Édition événement
- Form modal/drawer :
  - Titre, type (dropdown), date/heure, durée optionnelle.
  - Description rich text light.
  - Assignation (multi profil).
  - Attachments (fichiers/photos).
  - Lien module (animal, cycle reproduction, inventaire, finance) -> autocomplétion.
  - Options rappel (J-1, H-2, etc.).

## 4. Complétion événement
- Bouton `Marquer terminé` -> form résumé (notes, photo, dépenses associées).
- Si type Santé : checkboxes (traitement appliqué, dose).
- Log de l utilisateur et timestamp.

## 5. Notifications & offline
- Icône cloche sur cartes si notification programmée.
- Mode offline : bannière, certains filtres désactivés, événements affichés en read-only.

## 6. Accessibilité
- Navigation clavier sur tableau et kanban (focus géré).
- Utiliser icônes + texte pour type/statut.
- Couleurs par type compatibles daltonisme (utiliser palette design system + motifs).

## 7. Composants à implémenter
- `KhodanEventCard` (list/kanban).
- `KhodanKanbanBoard` (structure colonnes).
- `KhodanCalendar` (peut mutualiser avec reproduction).
- `KhodanAssignChip` (initiales, couleur, tooltip nom).

## 8. Livrables design
- Maquettes desktop/mobile pour chacune des vues.
- Modale création/édition + formulaire complétion.
- Iconographie par type (santé, reproduction, maintenance, finance).

## 9. Actions suivantes
1. Designer : produire maquettes, interactions.
2. PO : valider types et statuts.
3. Dev : préparer implé (tâche 034) + intégrer notifications (036).
