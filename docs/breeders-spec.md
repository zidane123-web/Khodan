# Module Eleveurs — Specification de reference

Cette page decrit l experience cible pour la gestion des eleveurs (breeders) en s appuyant sur la roadmap Khodan et les captures Everbreed. Elle sert de guide pour la liste, la fiche detaillee, l import CSV/Excel et les messages utilisateurs.

## Filtres et recherche intelligente
- **Recherche predictive** : champ unique qui suggere (nom, tatouage/ID, cage) des 2 caracteres, avec possibilite de naviguer au clavier. Les suggestions affichent `Nom · Tatouage · Cage`.
- **Statut** : multi-selection (« Actif », « Repos », « Archive », « Vendu »).
- **Race** : multi-selection basee sur les races connues ou saisie libre (fallback texte).
- **Categorie** : multi-selection (« Lapine », « Lapin », « Remplacante », « Reproducteur », « Reforme »).
- **Sexe** : choix unique (« Femelle », « Male »).
- **Periode de naissance** : plage de dates.
- **Periode d entree** : plage de dates.
- **Portees recentes** : toggle « A eu une portee sur les 90 derniers jours ».
- **Filtres sauvegardes** : bouton pour enregistrer/rappeler une combinaison (future iteration, pas prioritaire MVP).

## Colonnes de la liste
- **Tatouage / ID** (obligatoire) : ex. `F01`.
- **Nom** (optionnel).
- **Race** (texte court).
- **Categorie** (badge colore).
- **Sexe**.
- **Statut** (badge).
- **Age** (affiche « 14 mois », calcule depuis la date de naissance).
- **Cage** (ex. `C-205`).
- **Derniere saillie** (date courte ou « — »).
- **Prochaine action** (resume du planning si disponible, sinon « Aucune tache »).
- **Origine** (tooltip/infobulle).

Actions contextualisees : ouverture de fiche, modification, archiver, vente/saillie groupee (via selection multiple).

## Fiche eleveur — onglets et validations
### 1. Informations
- Identite : tatouage, nom, race, categorie, sexe.
- Statut + badges (« Actif », « Repos »…).
- Dates : naissance (obligatoire), entree (obligatoire), premiere saillie (optionnelle).
- Origine (texte), cage, parents (selecteurs).
- Indicateurs synthetiques : nombre de portees, taux de reussite, jeunes sevres.
- **Validations** : dates au format JJ/MM/AAAA, entree >= naissance, premiere saillie >= entree. Messages : « Champ obligatoire », « Date invalide », « La date doit etre posterieure a la naissance ».

### 2. Portees
- Tableau avec date de mise bas, nb nes, nb sevres, statut (Reussie, Echec, Avortement).
- Bouton « Nouvelle portee » dirige vers la capture de portee (nouvel ecran).
- Filtre rapide « Derniers 12 mois ».
- Message vide : « Aucune portee enregistree ».

### 3. Sante
- Timeline regroupee (traitements, peses, soins).
- Ajout rapide : bouton flottant qui ouvre un formulaire (type d evenement, date, note).
- Validations : poids numerique (message « Valeur numerique attendue »), date obligatoire.
- Message vide : « Aucun evenement de sante pour l instant ».

### 4. Documents
- Galerie photos (miniatures cliquables).
- Liste de documents (CSV, PDF) avec telechargement/suppression si disponibles.
- Message vide : « Ajoutez des documents ou photos pour garder un suivi ».

## Import CSV/Excel — parcours MVP
1. Depuis la liste, action « Importer » ouvre une boite de dialogue.
2. Choix du fichier (CSV ou Excel). Sur mobile : selecteur de fichiers.
3. Parsing local (sans envoi serveur) et affichage d un apercu des 50 premieres lignes.
4. L utilisateur confirme l import partiel : seuls les enregistrements valides sont transmis au Cubit.
5. Les enregistrements invalides sont listes avec message d erreur.
6. Un recapitulatif explique que la synchronisation Supabase reelle reste a implementer.

### Colonnes attendues
| Colonne | Obligatoire | Exemple | Notes |
| --- | --- | --- | --- |
| `tag_id` | Oui | `F01` | Tatouage ou identifiant unique |
| `name` | Non | `Fiona` | |
| `sex` | Oui | `Femelle` / `Male` | Normalise en francais |
| `status` | Oui | `Actif` | Doit correspondre a la liste de statuts supportes |
| `breed` | Non | `Neo-Zelandais` | |
| `category` | Oui | `Lapine` | |
| `birth_date` | Oui | `2022-04-18` | ISO 8601 ou JJ/MM/AAAA |
| `entry_date` | Oui | `2022-06-01` | |
| `first_breeding_date` | Non | `2022-09-10` | |
| `origin` | Non | `Elevage interne` | |
| `cage` | Non | `C-205` | |
| `notes` | Non | `Remplacera Opale` | Importe comme commentaire libre |

### Messages d erreur import
- « Fichier non pris en charge » (extension differente de `.csv` ou `.xlsx`).
- « Colonne obligatoire manquante : {nom} ».
- « Champ obligatoire » (cellule vide pour colonne obligatoire).
- « Date invalide (format attendu JJ/MM/AAAA ou ISO 8601) ».
- « Valeur numerique attendue » (pour colonnes futures type poids).
- « Aucune ligne importable » quand toutes les lignes echouent.

## Commandes utilisees / limites (a mettre a jour lors des runs)
- `flutter analyze` — verifie les avertissements Dart/Flutter.
- `flutter test` — lance les tests existants et ceux ajoutes pour la liste.
- `flutter pub get` — met a jour les dependances apres ajout de `file_picker`.
- Les imports Supabase ne sont **pas** encore executes : la creation reelle des eleveurs reste manuelle ou via la base de donnees.
- L import CSV actuel effectue un parsing local et renvoie les lignes valides au Cubit ; la persistance Supabase et la prise en charge Excel multi-feuilles restent a implementer.
- La sauvegarde de filtres favoris et l edition des documents depuis la galerie sont reportees.
