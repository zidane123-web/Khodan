# Task 18 - Provisionner le bucket de medias animaux

## Objectif
- Creer (ou verifier) le bucket Supabase Storage `animal-media` attendu par `SupabaseMediaRepository`.
- Declarer des regles d'acces cohentes (lecture via URL signee, ecriture par les utilisateurs authentifies).
- Script d'automatisation pour recreer le bucket sur de nouveaux environnements.

## Livrables
- Script `supabase/storage/animal_media_bucket.sql` (ou documentation CLI) pour provisionner le bucket et les politiques.
- Mise a jour de `supabase/README.md` et `README.md` pour expliquer le flux d'upload et les permissions.
- Test manuel documente (upload depuis l'app ou via script) prouvant que les medias sont accessibles avec URLs signees.

## Etapes
1. Auditer le projet Supabase: `supabase storage list` pour confirmer l'absence/presence du bucket.
2. Si besoin, creer le bucket via CLI (`supabase storage create-bucket animal-media --public false`) ou via script SQL.
3. Ajouter les policies:
   - Upload: role `authenticated` peut `insert`/`update` dans le bucket sous le dossier `<profile_id>/<animal_id>/`.
   - Lecture: `authenticated` et `anon` uniquement via URL signee.
4. Documenter les dossiers attendus (`profileId/animalId/filename.ext`) et le TTL par defaut (1h).
5. Mettre a jour la pipeline (Task 24) pour nettoyer le bucket avant release si necessaire.
6. Tester un cycle complet: upload via l'app ou script, recuperation via `createSignedUrls`, suppression.

## Dependances
- Task 16 (migrations rejouees).
- Credentials `service_role` pour gerer le storage.

