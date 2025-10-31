# Module Planning - Specification de reference

Ce document formalise la refonte du module Planning en suivant les parcours observes dans Everbreed (captures et enregistrement video du 30/10/2025). Il couvre la structure de donnees, les vues attendues (Liste, Calendrier, Chaine), les workflows clefs, le mode hors-ligne et les exports.

## Modele de donnees des taches

Chaque tache planifiee est normalisee a partir des evenements (`events`) et des rappels reproduction (`breeding_records.tasks`). Les champs exposes au front sont :

| Champ | Description | Source / Notes |
| --- | --- | --- |
| `taskId` | Identifiant unique (UUID) | Cle de l evenement ou identifiant synthetique derive du rappel |
| `profileId` | Profil utilisateur | Transmis tel quel depuis la table d origine |
| `taskType` | Type fonctionnel (`mating`, `palpation`, `kindling`, `feeding`, `inventory`, `health_check`, etc.) | Liste basee sur Everbreed Schedule (carte Type + icons) |
| `category` | `reproduction`, `sante`, `logistique`, `suivi` | Regroupement pour filtres rapides |
| `title` | Intitule court affiche en liste | Compose a partir du type + animaux |
| `description` | Texte libre (notes) | Facultatif |
| `dueDate` | Date d echeance | Obligatoire |
| `dueTime` | Heure cible (optionnelle) | Null si non precisee |
| `timeSpan` | Fenetre horaire (`morning`, `afternoon`, `evening`) ou minute start/end | Legacy Everbreed pour planifier les tournAes |
| `status` | `planned`, `completed`, `skipped`, `cancelled` | `planned` par defaut, `completed` lorsque marque comme fait |
| `priority` | `normal`, `important`, `critical` | Pilotage badge rouge en liste |
| `animalIds` | Liste des animaux lies | Utilisee pour tags et filtres |
| `subjects` | Noms + tatouages concatAnes (`F01 Fiona`) | Deduit en front pour ne pas dupliquer les donnees |
| `litterId` | Id portee concerne (optionnel) | Pour vue chaine |
| `relatedTasks` | Ids des taches dependantes (palpation -> kindling -> sevrage) | Permet l affichage de timeline |
| `origin` | `manual`, `template`, `auto_breeding` | Historique Everbreed (Quick Schedule, Recurring Tasks) |
| `syncState` | `synced`, `pending`, `failed` | Lie a la file hors-ligne |
| `createdAt` / `updatedAt` | Horodatage | Audit |
| `completedAt` | Date marquage fait | Utilisee pour statistiques |
| `assignedTo` | Nom ou identifiant utilisateur | Everbreed permet l affectation a un employe |
| `recurrenceRule` | RRULE compatible iCal (optionnel) | Sert pour export iCal futur |

## Vues cibles

### Vue Liste
- Barre de recherche globale (nom/tatouage animal, type, note) avec highlight des correspondances.
- Filtres persistants en haut (chips) :
  - Statut (A faire, En retard, Termine)
  - Periode (Aujourd hui, 7 jours, 30 jours, plage custom)
  - Type (Palpation, Mise bas, Traitement, Nettoyage, Inventaire, Custom)
  - Especes / cages / operateurs (multi selection)
- Compteurs Everbreed-like : `A faire`, `En retard`, `Terminees` dans un header compact.
- Ligne de tache :
  - Badge couleur par categorie (Reproduction violet, Sante vert, Logistique gris, Suivi bleu).
  - Tag animaux (ex. `F01 Fiona`, `M01 Jasper`).
  - Horaire si precise, sinon `Toute la journee`.
  - Indicateur offline si action en attente (`syncState == pending`).
- Actions rapides (icones alignes a droite) :
  - Marquer comme termine
  - Reprogrammer (ouvre bottom sheet date + heure)
  - Exporter vers CSV (selection multiple)
  - Supprimer / Ignorer (selon droits)

### Vue Calendrier
- Toggle `Mois` / `Semaine` (Everbreed affiche un switch en haut a droite).
- Calendrier mensuel a cases fermee avec comptage par jour (`3 taches`).
- Panneau lateral (ou bottom sheet sur mobile) listant les taches du jour selectionne.
- Drag & drop desktop pour replanifier (MVP : picker date + heure via dialog).
- Filtre "Afficher seulement reproduction" active un overlay couleur (Everbreed reproduction rings).
- Bandeau recap du jour : `Taches du 12 nov` + quick actions (`Terminer la selection`, `Exporter`).
- Icals gArAs par slot (non implAmentA -> message info).

### Vue Chaine (timeline reproduction)
- Timeline verticale par portee :
  1. Saillie
  2. Palpation (12 jours)
  3. Mise bas
  4. Sevrage
  5. Post-sevrage (suivi poids)
- Chaque etape affiche : date prevue, date effectuee, statut (planifie, fait, en retard).
- Bouton `Marquer etape faite` -> met a jour `completedAt`.
- Bouton `Planifier etapes` -> genere les taches manquantes selon gabarit Everbreed (`Mating + Kindling + Weaning`).
- Affiche badges animaux (lapine, lapin, portee).
- Filtre lateral : `Toutes`, `En retard`, `Cette semaine`, `A configurer`.

## Workflows utilisateur

1. **Creation rapide** : FAB ouvre un formulaire concis (type, date, animaux, notes, assignation). Si offline, insertion locale + queue `event.create`.
2. **Modale detail** : tap sur une tache ouvre detail (informations, historique, boutons Marquer termine, Reprogrammer, Dupliquer).
3. **Marquage termine** :
   - Si connecte : `event.update` immediate.
   - Si offline : `sync_queue` enregistre `event.update` avec rollback -> restauration du statut initial si echecs.
4. **Reprogrammer** : modifie `dueDate`/`dueTime`, re-calcule `status` (en retard si < now).
5. **Filtre sauvegarde** : MVP stocke dernier filtre dans `SharedPreferences` (clavier).
6. **Export** :
   - CSV : selection multiple -> bouton `Exporter CSV`. Fichier genere localement via package `csv`, partage via `share_plus`. Format colonnes `Date;Heure;Type;Animaux;Statut;Notes`.
   - iCal : non implAmente dans cette itAration. UI affiche lien `Export iCal (soon)` avec tooltip `Priorite basse, a livrer apres integration Supabase`.

## Mode hors-ligne

- Utilise `OfflineSyncManager` + `LocalEventDataSource` (deja en place pour events).
- Actions offline prevues :
  - Creation tache -> `SyncActionType.createEvent`.
  - Mise a jour statut / dates -> ajouter `updateEvent` (nouvelle methode).
  - Suppression -> `deleteEvent`.
- La vue liste affiche badge `Hors-ligne (3 actions en attente)` dans l entete avec bouton `Voir les actions` ouvrant un dialog listant la queue.
- Les reprogrammations effectuees hors ligne sont appliquees localement et planifiees pour sync automatique.
- Historique sync (comme Everbreed) : message toast `Planifie pour synchronisation` + `Voir la file`.

## Gestion des filtres et recherche

- Recherche texte appliquee sur `title`, `description`, `subjects`.
- Filtres se combinent (statut + periode + type + animal).
- Calcul derive :
  - `isOverdue` si `status == planned && dueDate < today`.
  - `isToday` si `dueDate` = date courante.
  - `timeBucket` pour regroupement (`Matin`, `Apres-midi`, `Soiree`).
- Le cubit expose `filteredTasks`, `calendarSlots` et `breedingChains`.
- Tests unitaires sur la fonction de filtrage (selection, tri, regroupement).

## Export et synchronisation externe

- **CSV** : MVP livre.
- **iCal** : placeholder dans UI (bouton desactive + message). Spec indique de reutiliser `recurrenceRule` lorsque l integration sera priorisee.
- **Sync externe** : Etape future pour publier vers Google Calendar ou ics. Noter dependance a Supabase (webhook ou API server).

## Commandes a executer pour verifier le module

- `flutter pub get` (des que de nouvelles dependances sont ajoutees).
- `flutter analyze`
- `flutter test`
- `dart run tools/generate_mocks.dart` (si on ajoute de nouveaux stubs pour tests).

Les deux dernieres commandes sont a rejouer avant livraison. L export iCal et l integration Supabase restent des travaux manuels (voir liste de suivi dans la conclusion).

