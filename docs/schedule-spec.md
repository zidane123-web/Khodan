# Module Planning - Specification de reference

Ce document formalise la refonte du module Planning en s'appuyant sur les parcours observes dans Everbreed (captures et enregistrement du 30/10/2025). Il couvre la structure de donnees, les vues attendues (liste, calendrier, chaine), les workflows clefs, le mode hors-ligne et les exports.

## Modele de donnees des taches

Chaque tache planifiee est normalisee a partir des evenements (`events`) et des rappels de reproduction (`breeding_records.tasks`). Les champs exposes au front sont :

| Champ | Description | Source / Notes |
| --- | --- | --- |
| `taskId` | Identifiant unique (UUID). | Cle de l'evenement ou identifiant synthetique derive du rappel. |
| `profileId` | Profil utilisateur. | Transmis tel quel depuis la table d'origine. |
| `taskType` | Type fonctionnel (`mating`, `palpation`, `kindling`, `feeding`, `inventory`, `health_check`, etc.). | Liste alignes sur Everbreed Schedule (carte Type + icones). |
| `category` | `reproduction`, `health`, `logistics`, `monitoring`. | Regroupement pour filtres rapides. |
| `title` | Intitule court. | Compose a partir du type + animaux. |
| `description` | Notes libres. | Facultatif. |
| `dueDate` | Date d'echeance. | Obligatoire. |
| `dueTime` | Heure cible. | Optionnelle. |
| `timeSpan` | Fenetre horaire (`morning`, `afternoon`, `evening`) ou fenetre minute. | Legacy Everbreed pour planifier les tournees. |
| `status` | `planned`, `completed`, `skipped`, `cancelled`. | `planned` par defaut, `completed` quand l'utilisateur marque comme fait. |
| `priority` | `normal`, `important`, `critical`. | Conduit l'affichage des badges rouges. |
| `animalIds` | Liste des animaux lies. | Pour tags et filtres. |
| `subjects` | Noms + tatouages concatentes (`F01 Fiona`). | Derive en front pour eviter la duplication. |
| `litterId` | Identifiant de portee. | Optionnel, alimente la vue chaine. |
| `relatedTasks` | Ids des taches dependantes. | Palpation -> kindling -> sevrage. |
| `origin` | `manual`, `template`, `auto_breeding`. | Historique Everbreed (Quick Schedule, Recurring Tasks). |
| `syncState` | `synced`, `pending`, `failed`. | Lie a la file hors-ligne. |
| `createdAt` / `updatedAt` | Horodatage. | Audit. |
| `completedAt` | Date de marquage. | Utilisee pour les statistiques. |
| `assignedTo` | Nom ou identifiant d'utilisateur. | Everbreed permet l'affectation a un employe. |
| `recurrenceRule` | RRULE compatible iCal. | Sert pour le futur export iCal. |

## Modeles de taches

Les elevages preparent des gabarits pour automatiser les sequences observees dans Everbreed (`Mating -> Palpation -> Kindling`). Un modele encapsule des metadonnees communes et une liste ordonnee d'etapes generees lors de l'application.

### Champs d'un modele

| Champ | Type | Description |
| --- | --- | --- |
| `templateId` | UUID | Identifiant unique. |
| `profileId` | UUID | Proprietaire du gabarit (policy RLS). |
| `name` | text | Libelle affiche dans la bibliotheque (`Gestation standard 31 j`, `Soin vermifuge 45 j`). |
| `slug` | text (optionnel) | Cle technique pour import/export rapide. |
| `category` | enum | `reproduction`, `health`, `logistics`, `monitoring`. |
| `scopeType` | enum | `litter`, `treatment`, `custom`. Conditionne l'ecran d'attribution (Everbreed: `Apply to Breeding` vs `Apply to Task Queue`). |
| `speciesId` | bigint (optionnel) | Restreint aux animaux d'une espece (Everbreed distingue lapin / chevre). |
| `defaultAnchor` | enum | Point de depart `template_start`, `mating_date`, `kindling_date`, `custom_date`. Utilise quand aucun evenement n'est precise. |
| `visibility` | enum | `private`, `shared_team`, `library`. |
| `isActive` | boolean | Masque le modele sans le supprimer (toggle Everbreed). |
| `tags` | text[] | Mots cles (`Quick Schedule`, `Weaning`, `Health`). |
| `notes` | text | Instructions internes. |
| `createdAt` / `updatedAt` / `archivedAt` | timestamptz | Suivi audit. |

### Champs d'une etape

Chaque etape correspond a une tache planifiee generee lors de l'application.

| Champ | Type | Description |
| --- | --- | --- |
| `stepId` | bigint | Identifiant sequentiel. |
| `templateId` | UUID | Reference au modele parent. |
| `profileId` | UUID | Proprietaire, facilite RLS. |
| `position` | int | Ordre d'execution (Everbreed affiche une timeline triee). |
| `title` | text | Libelle visible (`Palpation`, `Vermifuge`). |
| `taskType` | text | Type fonctionnel (`palpation`, `treatment`, `checkup`, etc.). |
| `category` | enum | Meme mapping que les taches planifiees. |
| `description` | text | Instructions operatoires (optionnelles). |
| `offsetDays` | int | Decalage en jours par rapport a l'ancre (`+12` jours apres saillie pour la palpation). |
| `offsetMinutes` | int | Ajustement intra-journee (peut etre negatif pour preparation la veille). |
| `anchor` | enum | `template_start`, `previous_step`, `mating_date`, `palpation_date`, `kindling_date`, `weaning_date`, `custom_date`. |
| `autoCompleteRule` | jsonb | Automatismes Everbreed (ex: marquer comme complete quand l'evenement amont est termine). |
| `notificationOffsets` | int[] | Minutes relatives a `eventDate` pour programmer les rappels (J-1, J0, J+1). |
| `priority` | enum | `normal`, `important`, `critical`. |
| `assignTo` | text | Utilisateur cible ou role d'equipe. |
| `createdAt` / `updatedAt` | timestamptz | Maintenus via trigger. |

### Workflow d'application

1. L'utilisateur choisit un modele puis selectionne une portee, un traitement ou une liste libre d'animaux (captures Everbreed 21, 35).
2. L'ancre proposee suit `defaultAnchor`. Le formulaire permet de la remplacer par une date precise (saillie, palpation, mise bas) ou par une date custom.
3. `TaskTemplateService.applyTemplate` calcule la date de chaque etape a partir de `anchor` et des offsets. Les etapes sont triees par `position` pour respecter la timeline.
4. Chaque etape genere un `LivestockEvent` rattache aux animaux concernes et cree un lien `task_template_assignment_event` pour le suivi.
5. Pour chaque `notificationOffset`, `LocalNotificationService.scheduleTaskReminder` enregistre un rappel local. Les cibles email/SMS facultatives alimentent `notifications_outbox` pour traitement externe.
6. Les evenements sont sauvegardes en local puis synchronises via Supabase. En mode hors-ligne, les actions rejoignent la queue `SyncActionType.createEvent` et sont rejouees des que la connexion revient.

### Alignement Everbreed et UX

- Les categories et types reprennent les cartes `Schedule > Quick Schedule`.
- `scopeType` couvre `Apply to Breeding` (portee) et `Apply to Task Queue` (traitement generique).
- `isActive` permet de masquer un modele tout en conservant les historiques, comme le toggle Active d'Everbreed.
- Les etapes respectent une contrainte d'unicite `(template_id, position)` pour reproduire la timeline et autoriser le drag & drop.
- Les rappels multiples (J-1, J0, J+1) suivent les options Email/SMS observees sur les captures 43-48.
- `anchorMetadata` (JSON) stocke les IDs de breeding ou de traitement afin d'expliquer la provenance quand on re-ouvre la fiche d'attribution.

## Vues planification

### Vue Liste

- Header avec segments `Taches`, `Modeles`, `Assignments`.
- Barre de recherche texte sur `title`, `description`, `subjects`.
- Filtres persistants (chips) :
  - Statut (`A faire`, `En retard`, `Terminees`).
  - Periode (`Aujourd'hui`, `7 jours`, `30 jours`, plage custom).
  - Type (`Palpation`, `Mise bas`, `Traitement`, `Nettoyage`, `Inventaire`, `Custom`).
  - Especes, cages, operateurs (multi-selection).
- Compteurs Everbreed-like : `A faire`, `En retard`, `Terminees` dans un header compact.
- Ligne de tache :
- Badge couleur par categorie (Reproduction violet, Health vert, Logistics gris, Monitoring bleu).
  - Tags animaux (`F01 Fiona`, `M01 Jasper`).
  - Horaire ou mention `Toute la journee`.
  - Indicateur hors-ligne si `syncState == pending`.
- Actions rapides (icones a droite) :
  - Marquer comme termine.
  - Reprogrammer (bottom sheet date + heure).
  - Exporter CSV (selection multiple).
  - Supprimer / Ignorer (suivant les droits).

### Vue Calendrier

- Toggle `Mois` / `Semaine` (placement haut droite).
- Calendrier mensuel en cases fermees avec comptage (`3 taches`).
- Panneau lateral (ou bottom sheet mobile) listant les taches du jour choisi.
- Drag & drop desktop pour reprogrammer (MVP: dialog date + heure).
- Filtre "Afficher reproduction uniquement" ajoute un overlay couleur.
- Bandeau recap du jour : `Taches du 12 nov` + actions `Terminer la selection`, `Exporter`.
- Slots iCal prepares (placeholder, bouton desactive `Export iCal (bientot)`).

### Vue Chaine (timeline reproduction)

- Timeline verticale par portee :
  1. Saillie.
  2. Palpation (J+12).
  3. Mise bas.
  4. Sevrage.
  5. Post-sevrage (suivi poids).
- Chaque etape affiche : date prevue, date effectuee, statut (`planifie`, `fait`, `retard`).
- Bouton `Marquer etape faite` met a jour `completedAt`.
- Bouton `Planifier etapes` genere les taches manquantes selon le gabarit.
- Affichage des badges animaux (lapine, lapin, portee).
- Filtre lateral : `Toutes`, `En retard`, `Cette semaine`, `A configurer`.

## Workflows utilisateur

1. **Creation rapide** : FAB ouvre un formulaire concis (type, date, animaux, notes, assignation). Hors-ligne, insertion locale + queue `event.create`.
2. **Modale detail** : ouverture d'une tache -> informations, historique, boutons `Marquer termine`, `Reprogrammer`, `Dupliquer`.
3. **Marquage termine** :
   - Connecte : `event.update` immediat.
   - Hors-ligne : enregistre `event.update` dans la queue avec rollback possible.
4. **Reprogrammer** : modifie `dueDate` / `dueTime` et recalcule `status` (`overdue` si date < now).
5. **Filtre sauvegarde** : le MVP conserve le dernier filtre dans `SharedPreferences`.
6. **Export** :
   - CSV : selection multiple -> bouton `Exporter CSV` (package `csv`, partage via `share_plus`).
   - iCal : placeholder (UI desactivee). Message `Priorite basse, arrive apres integration Supabase`.

## Mode hors-ligne

- Utilise `OfflineSyncManager` + `LocalEventDataSource`.
- Actions hors-ligne :
  - Creation tache -> `SyncActionType.createEvent`.
  - Mise a jour statut / dates -> `updateEvent`.
  - Suppression -> `deleteEvent`.
- La vue liste affiche un badge `Hors-ligne (3 actions en attente)` dans l'entete avec bouton `Voir les actions`.
- Les reprogrammations hors-ligne s'appliquent localement puis se synchronisent automatiquement.
- Historique sync : toast `Planifie pour synchronisation` + lien `Voir la file`.

## Gestion des filtres et recherche

- Recherche texte sur `title`, `description`, `subjects`.
- Filtres combinables (statut + periode + type + animal).
- Calcul derive :
  - `isOverdue` si `status == planned` et `dueDate < today`.
  - `isToday` si `dueDate` == date courante.
  - `timeBucket` pour regroupement (`Matin`, `Apres-midi`, `Soiree`).
- Le cubit expose `filteredTasks`, `calendarSlots`, `breedingChains`.
- Tests unitaires sur la fonction de filtrage (selection, tri, regroupement).

## Export et synchronisation externe

- **CSV** : MVP livre.
- **iCal** : placeholder UI (bouton desactive + message). Reutiliser `recurrenceRule` quand priorise.
- **Synchronisation externe** : futur webhook/worker pour Google Calendar ou ICS. Depend de Supabase (edge functions).

## Commandes a executer pour verifier le module

- `flutter pub get` (apres ajout de dependances).
- `flutter analyze`.
- `flutter test`.
- `dart run tools/generate_mocks.dart` (si de nouveaux stubs sont requis).

Les deux dernieres commandes sont a rejouer avant livraison. L'export iCal et l'integration Supabase restent des travaux manuels (voir backlog).
