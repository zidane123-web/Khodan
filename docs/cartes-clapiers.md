# Cartes de clapier (inspiré Everbreed)

Ce document synthétise la tâche _Plan2/task-14-cartes-clapier.md_, les captures Everbreed (`Info-de référence/Captures et formules Everbreed.pdf`), la roadmap Khodan (`Plan2/roadmap-khodan.md`) et la vidéo de référence. L'objectif est de livrer une expérience proche d'Everbreed tout en gardant l'identité Khodan.

## Acc�s dans l''application

Les cartes sont accessibles depuis le raccourci `+` (plus) de la barre lat�rale gr�ce � la route `/animals/cage-cards`. Le `GoRouter` expose `CageCardsRoute` et la page est �galement list�e dans le sous-menu Animaux (`lib/app/config/router.dart`).

## Donn�es consomm�es

- `CageCardService` lit maintenant les �leveurs via `SyncedAnimalRepository` (Supabase + Drift) **et** les port�es via `SyncedLitterRepository`.
- Les poids r�cents proviennent des �v�nements Supabase (`event_type = weight`). Le service croise les `AnimalEventLink` pour relier la pes�e au reproducteur.
- Les port�es restent rafra�chies dans la base locale (`LocalLitterDataSource`) pour permettre l''usage hors ligne.

## Actions PDF

- **T�l�charger** : enregistre un PDF dans `Documents/cage_cards/` (via `path_provider`).
- **Imprimer** : ouvre le dialogue natif avec `printing.layoutPdf`.
- **Exporter vers imprimeur** : charge le PDF dans Supabase Storage (`bucket cage_cards/{profileId}`) via `CageCardService.exportToStorage`.

Les messages de succ�s sont affich�s depuis l''UI et les erreurs (absence de session Supabase, stockage indisponible, etc.) sont remont�es au Snackbar.
## Formats et gabarits

| Format | Usage principal | Slots / feuille | Particularités alignées Everbreed |
| --- | --- | --- | --- |
| A4 portrait | Impression groupe (mur de clapier) | 4 cartes (2x2, marges 12 mm) | Idéal pour les élevages qui misent sur la lisibilité depuis 1‑2 m, mêmes proportions que les cartes Everbreed Desktop. |
| A5 paysage | Cartes individuelles | 2 cartes (1x2) | Permet d'ajouter le QR à droite façon fiche Everbreed mobile, plus d'espace pour notes sanitaires. |
| Étiquette 95 × 57 mm | Etiqueteuse thermique / badge | 1 carte | Aligné sur le format d'étiquettes utilisé sur Everbreed pour les cages de maternité. Police condensée, QR centré. |

Chaque gabarit expose la même liste de champs (voir ci‑dessous). La taille du QR s'ajuste automatiquement pour conserver une lisibilité de ≥25 mm sur les formats papier et ≥15 mm sur étiquettes.

## Champs disponibles

- **Identité** : nom du lapin, tatouage / identifiant court, race/couleur, statut (reproducteur, portée, engraissement).
- **Localisation** : cage / clapier, ligne / colonne, bâtiment.
- **Reproduction** : éleveur / propriétaire, parents, date de naissance portée, taille portée, nombre sevré.
- **Suivi santé** : poids actuel, date dernière pesée, prochaine pesée prévue, plan alimentaire (mélange, ration).
- **Dates clés** : saillie, palpation, nid, mise bas, sevrage (pré-remplis via templates Everbreed-like).
- **Options** : pictogrammes libre-service (alerte santé, gants requis), liens Supabase (ID portée, ID élevage).
- **QR** : URL profonde vers la fiche Supabase (`/breeders/{id}` ou `/litters/{id}`) encodée avec `qr_flutter`.
- **Données sensibles masquables** : prix d'achat, coût aliment, marge, note confidentielle.

Les champs facultatifs sont activés/désactivés via `cage_card_templates` et peuvent être masqués globalement (voir service Flutter).

## Exemple de contenu par carte (1 ligne)

- **A4** : `Neige #B-014 | Cage C12 | Née 14/08/25 | 3,2 kg (02/11) | Saillie 01/10 • Nid 27/10 • Sevrage 12/11 | QR → Supabase`
- **A5** : `Portée Jazz × Oslo | Clapier G5 | 8 nés / 7 sevrés | 1,15 kg moyen (05/11) | Prochaine pesée 12/11 | QR + note sanitaire`
- **Étiquette** : `Blitz C07 | 2,85 kg | Né 21/09/25 | Palpation 06/10 | QR`

Chaque bloc texte utilise des séparateurs courts (`|`, `•`) pour tenir sur une ligne comme recommandé par la tâche.

## QR codes et stockage

- Utiliser `qr_flutter: ^4.1.0` (déjà compatible avec Flutter 3.24). Ajouter la dépendance avec `flutter pub add qr_flutter` et vérifier qu'aucune version transitive de `qr` ne provoque de conflit (le lockfile sera mis à jour automatiquement).
- Les PDF générés sont nommés `cage_cards_<yyyyMMdd_HHmm>.pdf`. Pour l'option « Exporter vers imprimeur », sauvegarder dans Supabase Storage (`storage/cage_cards/`) via l'API Storage ou localement si hors-ligne.
- Stocker les templates et préférences utilisateur dans `cage_card_templates` (voir migration) pour répliquer la logique de personnalisation d'Everbreed.

## Données sensibles

- Le service Flutter expose `includeSensitiveData` (par défaut `false` pour refléter la prudence recommandée dans la roadmap).
- Le bouton « Masquer les données sensibles » applique une surcouche floutée dans l'aperçu, supprime les colonnes sensibles du PDF et remplace les valeurs par `***` sur les étiquettes.

## Migration Supabase

- Créer/mettre à jour la table `cage_card_templates` avec : `id`, `profile_id` (FK `profiles`), `label`, `format`, `enabled_fields` (JSONB), `color`, `created_at`, `updated_at`.
- Commande CLI standard :\
  `npx supabase migration new cage_card_templates`\
  `npx supabase db push`
- Si la CLI bloque (cf. risques de la roadmap), copier le SQL depuis `supabase/migrations/<timestamp>_cage_card_templates.sql` et l'exécuter dans **Supabase Studio → SQL Editor → Run**.

## Vérifications Flutter

Exécuter systématiquement :

```
flutter analyze
flutter test
```

Les tests incluent le service PDF (mock) et un widget test sur `CageCardsPage` pour garantir qu'aucune régression n'est introduite.


