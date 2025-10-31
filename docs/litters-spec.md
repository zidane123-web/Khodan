# Module Portees & Clapiers ? Specification de reference

Specification dediee au module Portees & gestion des clapiers, redigee a partir des captures (Khodan.pdf) et tableaux Everbreed disponibles dans `Info-de reference/`. Elle sert de guide a l equipe produit/dev pour recreer les parcours MVP : creation de portee, edition groupee, assignation cage/enclos, suivi des kits et peses.

## Objectifs d experience
- Harmoniser l ecran Portees avec le vocabulaire Everbreed tout en restant compatible terminologie Khodan (numero de portee, cage, enclos, kits).
- Permettre une saisie rapide sur mobile (mode hors-ligne) et un controle plus complet sur bureau.
- Garder des hooks explicites pour raccorder Supabase (operations CRUD, synchronisation).
- Integrer les rappels de taches lies a la reproduction (palpation, sevrage, abattage) comme donnees contextuelles.

## Module Portees

### 1. Vue liste & navigation
- Presentation : tableau + cartes (responsive) tri par defaut sur `Date mise bas` desc; filtres : `Statut`, `Femelle`, `Cage`, `Intervalle dates`.
- Actions rapides : `Nouvelle portee`, `Edition groupee`, `Exporter`.
- Contenu carte : numero de portee, femelle + male, nb nes/sevres, statut, cage, prochain rappel.
- Badges statut : `Gestante`, `A palper`, `Sevrage`, `Prete abattage`, `Archive`.
- CTA mobile : FAB `Nouvelle portee` avec mini-fiche recap apres validation.

### 2. Formulaire de creation

| Champ | Obligatoire | Exemple | Validation | Notes |
| ----- | ----------- | ------- | ---------- | ----- |
| Numero de portee | Oui | `P-2025-18` | Regex alphanumerique unique | Genere par defaut (annee + incr), editable. |
| Femelle (tatouage) | Oui | `F01` | Doit exister dans referentiel animaux | Dropdown + recherche instantanee. |
| Male (tatouage) | Oui | `M12` | Idem | Suggestion par compatibilite (dernier accouplement). |
| Date saillie | Oui | `12/10/2025` | JJ/MM/AAAA, <= date mise bas | |
| Date mise bas | Oui | `14/11/2025` | JJ/MM/AAAA, >= saillie | |
| Nes vivants | Oui | `8` | entier >=0 | |
| Nes morts | Non | `1` | entier >=0 | Pre-rempli 0. |
| Sevres prevus | Oui | `7` | entier >=0 | |
| Cage / Clapier | Oui | `C-205` | non vide | Auto-rempli depuis femelle si dispo. |
| Enclos | Non | `Enclos plein air 2` | texte court | |
| Gabarit de taches | Non | `Cycle reproduction standard` | selection multiple (palpation J+12, sevrage J+35, rappel abattage). |
| Notes | Non | `Ligne maternelle performante` | <= 500 caracteres | |

**Controle validation** :
- Message `Champ obligatoire` sur champs requis.
- Interdiction `Date mise bas ne peut preceder la saillie`.
- Alerte `Nombre sevre > nes vivants` (warning avec confirmation).
- Hook placeholder `TODO(supabase): create litter` a l envoi (retourne ID local en attendant Supabase).

### 3. Edition groupee
- Selection multiple : cases a cocher sur lignes, compteur dans AppBar (desktop) ou barre flottante (mobile).
- Formulaire simplifie : statut (dropdown), rappel (date), cage/enclos, tags (texte).
- Confirmation : recap des portees impactees, messaging `Les modifications seront synchronisees avec Supabase des que connecte`.
- Hook `TODO(supabase): batch update litters` dans Cubit/repository.
- Annulation : snackbar `Modifications annulees`.

### 4. Affectation cage / enclos
- Sous-panneau dans fiche portee : `Cage actuelle`, `Historique de mouvements` (date, ancien, nouveau).
- Action : bouton `Deplacer` -> dialogue selection cage (filtre par zone, capacite restante). Message `Assigner egalement les kits`. Case `Appliquer aux kits` cochee par defaut.
- Validation : empeche selection cage pleine (`Capacite depassee`).
- Offline : creation d un brouillon `SyncAction` local, flag `pendingAssignment`.

### 5. Suivi poids & abattage
- Tableau kits : colonnes `Tatouage kit`, `Sexe`, `Poids naissance (g)`, `Poids sevrage (g)`, `Poids pre-abattage (g)`, `Poids carcasse (kg)`, `Valeur marchande (FCFA)`, `Destination` (abattu, vendu, garde).
- Saisie rapide : double-clic / tap -> champ numerique, validation `>=0`.
- Bouton `Enregistrer peses` : appelle repository `saveWeights(litterId, kits)`.
- Abattage groupe : selection des kits -> form `Date abattage`, `Poids carcasse`, `Prix de vente`; validation numeric + message `Entrer 0 si non pese`.
- Alertes : si difference poids pre/post > 30 %, warning `Verifier la saisie`.

## Module Clapiers

### 1. Vue globale
- Grille responsive (`GridView` 2-4 colonnes) listant clapiers/enclos.
- Carte Clapier : `Numero` (`C-205`), `Statut` (Disponible, Occupe, Maintenance), `Capacite`, `Occupants` (liste femelles + kits), `Dernier nettoyage`.
- Badge `En retard entretien` si nettoyage > 7 jours.
- Bouton `Ajouter un clapier` -> formulaire (numero unique, zone, capacite, notes maintenance).

### 2. Detail clapier
- Onglets `Occupants`, `Historique`, `Maintenance`.
- Occupants : table kits + mere, actions `Reattribuer`, `Enregistrer poids`, `Marquer en sortie`.
- Historique : timeline des portees qui ont occupe ce clapier.
- Maintenance : date dernier nettoyage, prochaine visite, checklist (texte multi-lignes).

### 3. Formulaire poids express
- Depuis carte Clapier : bouton `Peser kits` ouvre bottom sheet.
- Contenu : liste kits avec champ `Poids actuel (g)` + toggle `Abattage programme`.
- Bouton `Enregistrer` -> appelle `HutchRepository.saveWeightSamples`.
- Message success `Mesures sauvegardees, synchronisation a venir`.

### 4. Recherche & filtres
- Champ `Rechercher` (numero, zone).
- Filtre `Statut` (Disponible, Occupe, Maintenance).
- Filtre `Occupation` (Femelle gestante, Kits sevrage < 7 jours).
- Tri `Numero`, `Date nettoyage`.

## Messages hors-ligne & synchronisation
- Lors d une creation/edition sans connexion : banniere `Mode hors-ligne ? Les enregistrements seront envoyes a Supabase automatiquement`.
- Chaque action pousse `OfflineAction` (litter create, batch update, cage move, weight sample). Repository stocke en memoire + TODO integrer a `OfflineSyncManager`.
- Sur reouverture d une portee : badge `Brouillon (non synchronise)` et CTA `Ressayer maintenant`.
- Suggestion aide : `Saisissez les poids au carnet papier puis synchronisez des que possible`.

## Architecture & hooks Supabase
- `LitterRepository` interface : `Future<List<Litter>> fetchLitters()`, `Future<Litter> createLitter(LitterDraft draft)`, `Future<void> updateLittersBatch(...)`, `Future<void> saveKitWeights(...)`, `Stream<List<Litter>> watchLitters()`.
- `HutchRepository` interface : `Future<List<Hutch>> fetchHutches()`, `Future<void> saveHutch(HutchDraft draft)`, `Future<void> recordMaintenance(...)`, `Future<void> assignLitter(...)`.
- Implementations initiales en memoire (listes statiques, `const sampleLitters`) dans `lib/data/repositories/litter_repository.dart`.
- Marquage `TODO(supabase): wire remote data source` + injection via `RepositoryProvider`.

## UX microcopy & messages
- Confirmation creation : `Portee {numero} creee. Synchronisation des taches en cours.`
- Snackbar offline : `Action mise en file d attente (mode hors-ligne)`.
- Empty states :
  - Portees : `Aucune portee enregistree. Lancez votre premiere reproduction !`
  - Clapiers : `Aucun clapier configure. Ajoutez votre premier enclos.`
- Erreurs : `Impossible de charger les portees. Verifiez votre connexion ou reessayez.`

## Limites temporaires (31/10/2025)
- Pas de connexion Supabase encore : les donnees sont locales au runtime.
- Pas d integration au moteur de taches automatique (les rappels sont notes mais non planifies).
- Statistiques de productivite en attente (pas de taux de sevrage instantane).
- Pas encore de persistance Drift : redemarrage de l app reinitialise les listes.
- Synchronisation OfflineSyncManager non branchee pour ce module (brouillons volatils).

## Commandes de verification
- `flutter analyze` : zero warning requis.
- `flutter test` : inclut `litters_clapiers_smoke_test.dart`.
- `flutter gen-l10n` si nouvelles cles ajoutees (non necessaire dans MVP).

Documentation mise a jour le 31/10/2025.
