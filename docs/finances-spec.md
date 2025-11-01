# Specification module finances et contacts

## Contexte et objectifs
- S'inspirer des ecrans et formulaires Everbreed (voir dossier `Info-de reference/`) pour guider les besoins Khodan.
- Offrir un registre financier simple relie aux contacts de l'elevage (eleveurs partenaires, fournisseurs, clients).
- Garantir une experience coherente mobile/desktop avec pieces jointes (photos de recu) et export CSV.

## Categories de transactions (par defaut)
| Code | Libelle | Type par defaut | Description Everbreed/Khodan |
| --- | --- | --- | --- |
| feed | Alimentation | depense | Achat de granules, foin, complements, rapproche Everbreed Feed. |
| health | Soins et veterinaire | depense | Traitements, vaccins, visites, coherent avec Everbreed Health. |
| supplies | Materiel et consommables | depense | Cage, biberon, litiere, equipement quotidien. |
| transport | Transport et logistique | depense | Deplacement animaux, livraisons, carburant. |
| breeding | Reproduction (saillie, IA) | depense | Frais de saillie externe, semence. |
| housing | Infrastructure et maintenance | depense | Reparation clapiers, electricite, eau. |
| sales | Ventes de lapins et produits | recette | Recettes ou acomptes clients, alignement Everbreed Sales. |
| transfer | Transferts internes | neutre | Mouvement entre comptes internes, doit toujours equilibrer. |
| subsidy | Subventions et aides | recette | Subventions agricoles, primes. |
| other | Autre / a classer | neutre | Placeholder si la categorie n'existe pas encore. |

> Les categories peuvent etre actives/inactives, et l'utilisateur peut en ajouter de nouvelles via Supabase ou future interface (champ `is_custom`).

## Modele de donnees propose

### Table `contacts`
- `id uuid primary key default gen_random_uuid()`
- `profile_id uuid references profiles(id)` (filtrer par proprietaire de l'elevage).
- `display_name text not null`
- `type text check (type in ('breeder','supplier','client','staff','other')) default 'other'`
- `email text`
- `phone text`
- `address text`
- `notes text`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### Table `transaction_categories`
- `id uuid primary key default gen_random_uuid()`
- `profile_id uuid references profiles(id)`
- `code text not null unique`
- `label text not null`
- `default_flow text check (default_flow in ('income','expense','neutral')) not null`
- `is_active boolean default true`
- `is_custom boolean default false`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### Table `financial_transactions`
- `id uuid primary key default gen_random_uuid()`
- `profile_id uuid references profiles(id) not null`
- `category_id uuid references transaction_categories(id)`
- `contact_id uuid references contacts(id)`
- `title text not null` (ex: "Achat foin octobre")
- `notes text`
- `flow text check (flow in ('income','expense','neutral')) not null`
- `amount numeric(12,2) not null` (montant en devise principale)
- `currency text not null default 'XOF'` (option future pour personnalisation)
- `occured_on date not null` (date de transaction)
- `payment_method text` (cash, mobile_money, cheque, other)
- `attachment_url text` (URL Supabase Storage)
- `attachment_name text` (nom original fichier)
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### Vues et index
- Index sur `(profile_id, occured_on desc)` pour affichage.
- Index sur `(profile_id, category_id)` pour filtres.
- Vue `financial_transactions_with_contacts` combinant jointure contacts/categories pour PostgREST.

### RLS (a definir dans migration ulterieure)
- Politique SELECT/INSERT/UPDATE/DELETE limitee a `profile_id = auth.uid()`.
- Service role conserve acces complet.
- Triggers `tg_maintain_timestamps` sur chaque table pour maintenir `updated_at`.

## Experience Flutter attendue

### Liste ledger
- Filtre par periode (7 derniers jours, mois courant, intervalle libre), categorie, type de flux, contact.
- Groupement par date (en-tetes "29/10/2025") avec totaux partiels.
- Indicateurs en haut : solde net, total depenses, total recettes (placeholders si Supabase hors-ligne).
- Etats vides : message "Aucune transaction enregistree pour le moment" + bouton "Ajouter".
- Actions par element : voir detail, modifier, dupliquer, supprimer.

### Formulaire transaction
- Champs : titre, date (defaut = aujourd'hui), categorie (dropdown), type (expense/income neutral auto selon categorie mais modifiable), montant (format FCFA), devise (dropdown courte), contact (facultatif), methode paiement, notes, piece jointe.
- Piece jointe : selection image depuis galerie/appareil photo (utiliser `image_picker` + stockage Supabase).
- Validation :
  - Montant > 0 sauf type `neutral` (autorise 0).
  - Categorie obligatoire.
  - Message en cas d'echec upload : "Echec de l'envoi du recu. Reessaye ou enregistre sans piece jointe."
- Confirmation apres succes : "Transaction enregistree avec contact {nom}" ou "Transaction enregistree".

### Carnet de contacts
- Liste alphabetique avec recherche (nom, type).
- Fiche detaillee (nom, type, coordonnees, notes, total transactions associees).
- Formulaire edition/creation identique aux champs table, validation simple (nom obligatoire, au moins un moyen de contact recommande).
- Suppression autorisee uniquement si aucune transaction liee (sinon message "Ce contact est lie a des transactions. Supprime ou reassocie ces transactions avant de continuer.").

### Liaison transactions <-> contacts
- Dans le formulaire ledger, lier `contact_id`.
- Afficher sur la carte transaction : badge contact (ex: "Fournisseur: Abena Feed").
- Depuis fiche contact, section "Transactions recentes" (liste 10 dernieres operations).

### Export CSV
- Bouton "Exporter CSV" sur la liste ledger.
- Colonnes : `transaction_id,occured_on,title,flow,amount,currency,category_code,category_label,contact_name,payment_method,notes`.
- Support filtre courant : exporter uniquement ce qui est visible.
- Nom fichier : `ledger_<profile_id>_<YYYYMMDD-HHmm>.csv`.
- Message succes : "Fichier ledger_...csv enregistre dans le dossier telechargements."
- Message erreur : "Impossible de generer l'export. Verifiez l'espace disque ou les permissions."
- Utiliser package `csv` + `path_provider` (mobile) / `AnchorElement` (web).

### Import CSV (specification fonctionnelle)
- Disponible via menu overflow (option "Importer CSV").
- Attendu : fichier delimite par virgules, encodage UTF-8, entete obligatoire.
- Colonnes minimales : `occured_on,title,flow,amount,currency,category_code,contact_name`.
- Colonnes optionnelles : `payment_method,notes,attachment_url`.
- Workflow :
  1. Choix du fichier => previsualisation (10 premieres lignes) avec detection categories inconnues.
  2. Si `category_code` absent ou inconnu => proposer map vers categorie existante ou creation rapide (flag `is_custom`).
  3. Option pour creer automatiquement les contacts inconnus.
  4. Validation finale resume : nombre de lignes, depenses, recettes, erreurs.
  5. Import en lots via Supabase (utiliser RPC ou insert multiple).
- Gestion erreurs : afficher detail ligne + raison (ex: "Ligne 4 : montant invalide").

## Messages utilisateurs (etat et erreurs)
- `ledger_empty_state` : "Aucune transaction enregistree." + CTA "Ajouter une transaction".
- `ledger_filter_no_result` : "Aucun resultat pour ces filtres. Ajustez la periode ou la categorie."
- `ledger_save_success` : "Transaction enregistree."
- `ledger_save_success_with_contact` : "Transaction enregistree pour {contact}."
- `ledger_save_error` : "Impossible d'enregistrer la transaction. Verifiez votre connexion."
- `ledger_delete_confirm` : "Supprimer cette transaction ? Cette action est definitive."
- `ledger_delete_blocked_contact` : "Suppression impossible tant que la transaction est reliee a un contact obligatoire."
- `contact_save_success` : "Contact mis a jour."
- `contact_save_error` : "Impossible d'enregistrer le contact. Completer les champs requis."
- `contact_delete_blocked` : "Ce contact est lie a des transactions. Supprimez-les ou reassociez-les."
- `import_summary` : "Import termine : {count} transactions ajoutees, {errors} erreurs."
- `import_error` : "Echec de l'import. Verifiez le format CSV."
- `export_success` : "Export termine."
- `export_error` : "Echec de l'export."

## Dependances techniques
- Stockage Supabase (bucket `receipts`) pour les pieces jointes.
- Service de temps reel (optional) pour rafraichissement auto du ledger.
- Packages Flutter suggeres : `hooks_riverpod`, `image_picker`, `file_picker`, `csv`, `path_provider`, `open_filex`.

## Tests a prevoir
- Tests unitaires sur parsing CSV (import/export).
- Tests widget : ajout d'une transaction liee a un contact (obligatoire dans cette tache).
- Tests integration futurs : verif RLS via PostgREST (profil vs service_role).

## Commandes de verification
- `flutter analyze`
- `flutter test`

## Points ouverts / limites
- Conversion devise : placeholder, conversion automatique hors scope.
- Pieces jointes multiples non supportees (une seule photo).
- Import CSV : verification storage piece jointe non prevue (l'utilisateur devra reupload manuellement).
- Pas encore d'automatisation pour generer categories custom; interface a livrer plus tard.
