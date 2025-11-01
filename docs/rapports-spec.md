# Specification module rapports

## Contexte et objectifs
- S'appuyer sur les captures Everbreed (dossier `Info-de reference/`) et la feuille de route (`Plan2/roadmap-khodan.md`) pour livrer des rapports reproductifs, de croissance et financiers en une page Flutter unifiee.
- Centraliser les formules dans Supabase via des vues materialisees ou simples pour assurer des exports coherents (CSV/Excel/PDF).
- Garder le vocabulaire court et accessible aux debutants; chaque indicateur doit pouvoir etre explique en deux phrases maximum dans l'interface.

## Reproduction
| Indicateur | Description | Source primaire |
| --- | --- | --- |
| Taux de fertilite | Saillies ayant mene a une portee / saillies totales | `breeding_records` |
| Taux de mise bas | Portees avec naissance confirmee / saillies positives | `breeding_records.kindling_date` |
| Taille moyenne portees | Moyenne des `kits_born_alive` par mise bas | `breeding_records.kits_born_alive` |
| Taux de sevrage | Kits sevres / kits nes vivants | `breeding_records.kits_weaned` |
| Intervalle entre mises bas | Jours moyens entre deux `kindling_date` pour une meme femelle | `breeding_records` (partition par `doe_id`) |

> Remarque: les donnees negatives ou nulles (kits inconnus) doivent etre ignorees dans le numerateur et denominateur pour ne pas fausser les ratios.

## Croissance
| Indicateur | Description | Source primaire |
| --- | --- | --- |
| Age moyen au sevrage | Moyenne de `weaning_date - birth_date` | `breeding_records` + `animals birth_date` |
| Poids moyen au sevrage | Moyenne des `average_weaning_weight` (kg) | `breeding_records` |
| Gain quotidien moyen | Moyenne des `(details->>'weightKg') / age_en_jours` pour les evenements `weight` | `events` + `animal_events` |
| Mortalite avant sevrage | (kits nes vivants - kits sevres) / kits nes vivants | `breeding_records` |
| Taux de retention 12 semaines | Animaux toujours `status = 'active'` a J+84 / kits sevres | `animals` (par date de naissance) |

## Finances
| Indicateur | Description | Source primaire |
| --- | --- | --- |
| Total recettes | Somme `amount` des transactions `flow = income` | `financial_transactions` |
| Total depenses | Somme `amount` des transactions `flow = expense` | `financial_transactions` |
| Marge nette | Recettes - depenses (par periode) | `financial_transactions` |
| Cout alimentaire par portee | Total depenses categorie `feed` / nombre de portees sevrees | `financial_transactions` + `breeding_records` |
| Revenu moyen par reproductrice | Recettes categorie `sales` / nb femelles actives | `financial_transactions` + `animals` (`sex = 'F'`) |

## Formules
| Cle | Formule | Commentaire |
| --- | --- | --- |
| `fertility_rate` | `confirmed_matings / total_matings` | `confirmed_matings`: `palpation_positive = true` ou `kindling_date non null` |
| `kindling_success_rate` | `kindlings / confirmed_matings` | Evite division par zero (`NULLIF`) |
| `average_litter_size` | `SUM(kits_born_alive) / NULLIF(kindlings,0)` | Exclure portees nulles |
| `weaning_rate` | `SUM(kits_weaned) / NULLIF(SUM(kits_born_alive),0)` | Pour limiter division |
| `average_weaning_age_days` | `AVG(weaning_date - birth_date)` | Convertir en jours via `EXTRACT(epoch)` |
| `average_weaning_weight` | `AVG(average_weaning_weight)` | Ignorer `NULL` |
| `average_daily_gain` | `AVG((details->>'weightKg')::numeric / GREATEST(age_days,1))` | `age_days = DATE_PART('day', event_date - birth_date)` |
| `preweaning_mortality` | `(SUM(kits_born_alive) - SUM(kits_weaned)) / NULLIF(SUM(kits_born_alive),0)` | Resultat en pourcentage |
| `twelve_week_retention` | `kept_12_weeks / NULLIF(SUM(kits_weaned),0)` | `kept_12_weeks`: compte `animals` n'es et encore actifs a J+84 |
| `net_margin` | `income_total - expense_total` | Sur la periode (mois) |
| `feed_cost_per_litter` | `feed_expense / NULLIF(kindlings,0)` | Filtre categorie `feed` |
| `doe_avg_revenue` | `sales_income / NULLIF(female_active,0)` | Femelles actives = `status in ('active','breeding')` |

## Exemples chiffrés
| Periode | Total saillies | Fertilite | Taille portee | Taux sevrage | Cout alim/portee |
| --- | --- | --- | --- | --- | --- |
| Mars 2025 | 18 | `14 / 18 = 77.8 %` | `103 kits / 12 portees = 8.6` | `87 / 103 = 84.5 %` | `140 000 FCFA / 12 = 11 667 FCFA` |

| Periode | Age sevrage | Poids sevrage | Gain quotidien | Mortalite pre-sevrage | Retention 12 semaines |
| --- | --- | --- | --- | --- | --- |
| Mars 2025 | `31.2 j` | `1.95 kg` | `2.1 kg / 60 j = 35 g/j` | `16 %` | `78 / 87 = 89.6 %` |

| Periode | Recettes | Depenses | Marge nette | Revenu doe active |
| --- | --- | --- | --- | --- |
| Mars 2025 | `385 000 FCFA` | `242 000 FCFA` | `143 000 FCFA` | `285 000 / 22 = 12 955 FCFA` |

> Les exemples reprennent les formats attendus dans le futur ecran (pourcentages arrondis a une decimale, montants formates via locale `fr`).

## Export
- Onglet Flutter `Rapports > Export` proposera **CSV** (structure `rapports_<onglet>_<AAAAMM>.csv`) et **Excel** (`.xlsx`) utilises pour partager depuis mobile/desktop.
- Generation CSV: reutiliser `ListToCsvConverter` avec encodage UTF-8 et separateur `;` (plus simple a ouvrir dans Excel francophone). Inclure colonnes `periode`, `indicateur`, `valeur`, `formule`, `commentaire`.
- Generation Excel: package `excel` (Dart pur) pour fabriquer un classeur avec une feuille par onglet (`Reproduction`, `Croissance`, `Finances`). Ajouter une ligne d'entete grisee et figer la premiere ligne pour lecture facile.
- Les exports reutilisent les memes jeux de donnees que l'affichage. Le bouton `Exporter CSV`/`Exporter Excel` doit afficher un toast de succes ou d'erreur (utiliser `ScaffoldMessenger`).
- Documenter dans l'application le chemin de sauvegarde:
  - Mobile: dossier telechargements via `path_provider.getDownloadsDirectory`.
  - Web: telechargement direct (anchor blob).

## Instructions Supabase
- Deux vues et une fonction sont necessaires:
  - `view_reports_reproduction` (granularite mensuelle par `profile_id`).
  - `view_reports_growth` (mesures poids + progression sevrage).
  - `view_reports_finances` + `fn_report_finance_summary(profile uuid, start date, end date)` pour calculer les totaux filtre periode.
- Conformement au guide (`docs/supabase-execution-guide.md`), si la CLI `supabase db push` echoue, copier le script dans le SQL Editor, l'executer puis enregistrer l'insertion `schema_migrations`. Reporter les sorties dans le journal (section a ajouter en bas du guide).

## Commandes developpeur
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs` (si modele modifie)
- `flutter analyze`
- `flutter test`
- `supabase db lint` (optionnel, sinon fallback SQL Editor)

Consigner ces commandes dans le rapport de tache a la fin du sprint et rappeler l'utilisateur qu'il doit lancer la migration sur l'environnement Supabase de production.
