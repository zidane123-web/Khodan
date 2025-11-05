# Pedigrees et certificats Khodan

## Contexte et ressources
- Objectif : proposer un pedigree clair et un certificat de naissance simple pour chaque lapin.
- Sources : captures Everbreed (`Info-de reference/`), analyse roadmap (`Plan2/roadmap-khodan.md`), maquette video.
- Contraintes : phrases courtes (max 12 mots), vocabulaire francais courant, support PDF A4 et partage numerique.

## Structure des donnees
| Generation | Relation | Champs obligatoires | Champs optionnels | Notes |
| --- | --- | --- | --- | --- |
| 0 (Sujet) | Lapin selectionne | Nom (ou tatouage), Identifiant, Sexe, Date naissance, Eleveur | Race, Couleur, Poids actuel, Numero cage, Photo | Sert de base pour certificat |
| 1 | Pere / Mere | Nom ou tatouage, Sexe, Date naissance | Race, Couleur, Eleveur, Lien fiche | Afficher `Information a completer` si donnees manquantes |
| 2 | Grands-parents | Nom ou tatouage, Sexe | Date naissance, Race, Eleveur, Notes | Aligne colonne haute et basse |
| 3 | Arriere grands-parents | Nom ou tatouage | Sexe si connu, Date naissance | Utiliser placeholders `Ancetre P/M` si inconnus |
| 4 | Generation bonus (facultatif) | Identifiant si disponible | Texte libre | N'afficher que si `generations >= 4` |

Champs supplementaires recuperes via Supabase :
- `last_mating_date`, `last_kindling_date` pour montrer activite recente.
- `status` pour indiquer `Actif`, `Repos`, `Archive`.
- `origin`, `entry_date` pour certificat.

## Mise en page PDF (format A4 portrait)
- Marges : 18 mm haut/bas, 15 mm gauche/droite.
- En-tete : logo Khodan (placeholder), titre `Pedigree officiel` (page 1) ou `Certificat de naissance` (page 2).
- Bandeau couleur : degrade vert Khodan (#0E7F45 -> #198754).
- Police : `Inter` si disponible, sinon `Roboto`. Tailles : 18 pour titres, 12 pour textes, 10 pour legends.
- Page 1 : grille 4 colonnes (une par generation) avec cartes alignées verticalement. Utiliser cadres arrondis (rayon 8) et fond clair (#F2F7F3).
- Page 2 : carte centrale regroupant informations sujet, parents, details portee. Inclure espace signature elevage et date.
- QR code placé en bas a droite de la page 2 avec mention `Scanner pour voir la fiche en ligne`.

## Textes types (phrases <= 12 mots)
- `Pedigree officiel de {nom}`
- `Certificat de naissance Khodan`
- `Eleveur : {farm_name}`
- `Sexe : {sex}`
- `Ne(e) le : {birth_date}`
- `Statut actuel : {status}`
- `Derniere saillie enregistree : {last_mating}`
- `Derniere mise bas : {last_kindling}`
- `Information a completer` (pour parent manquant)
- `Signature de l elevage`
- `Document genere via Khodan`

## Options de couleurs
| Nom | Code | Usage |
| --- | --- | --- |
| Vert principal | #0E7F45 | Bandeaux, boutons primaires |
| Vert clair | #C8E6C9 | Fonds cartes pedigree |
| Beige | #F6F0E5 | Fund certificat (fond general) |
| Gris texte | #4A4A4A | Corps texte |
| Gris clair | #E0E0E0 | Separateurs, encadres vide |

Personnalisation :
1. Palette exposee via `PedigreeTheme` (Flutter) pour bascule rapide (vert, bleu, sable).
2. Documenter variables dans `PedigreePage` (`primaryColor`, `accentColor`).
3. Pour impressions noir/blanc, forcer contraste (bordures #B0B0B0).

## Partage numerique et QR code
- Bucket prive Supabase : `pedigrees`, chemin par fichier `pedigrees/{profile_id}/{breeder_id}.pdf` (politique RLS limitant l'acces a `auth.uid()`).
- Edge Function `create-pedigree-share` (voir `supabase/functions/create-pedigree-share/index.ts`) :
  1. Verifie que le token (`Authorization: Bearer <jwt>`) correspond bien a `profileId`.
  2. Cree une URL signee (`storage.createSignedUrl`) valable 24 h (min 60 s, max 7 jours).
  3. Retourne `{ shareUrl, storagePath, expiresAt }` pour rafraichir le QR code.
- Flow applicatif :
  1. Bouton `Telecharger PDF` genere localement le PDF (avec le theme et les donnees en cache).
  2. Le service `PedigreeService.uploadPdf` envoie le PDF dans `pedigrees/{profile_id}/{breeder_id}.pdf` (upsert).
  3. `PedigreeService.createShareLink` appelle l'Edge Function pour recuperer l'URL partageable, qui est sauvegardee dans l'UI et encodee dans le QR code.
- Les textes UI indiquent maintenant : `Generez un PDF pour activer le QR code et obtenir un lien partageable.` (plus de message "configurer Edge Function").

## Execution Supabase
1. Ouvrir editeur SQL Supabase.
2. Lancer la requete :
   ```sql
   select *
   from public.fn_pedigree_tree(
     '00000000-0000-0000-0000-000000000000', -- id lapin
     4
   );
   ```
3. Verifier que chaque generation contient 2^n lignes (ou placeholders `missing=true`).
4. Pour exporter JSON : `select jsonb_pretty(jsonb_agg(t)) from fn_pedigree_tree(... ) t;`.

## Commandes de tests
- `flutter analyze`
- `flutter test`

Executer ces commandes avant validation pour garantir absence d avertissements et de regressions.
