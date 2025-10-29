# Task 23 - Nettoyage des donnees avant release

## Objectif
- Purger les donnees de demonstration restantes (animaux fictifs, evenements tests, tickets support dummy) dans Supabase.
- Mettre en place un script de reset leger pour repartir d'une base saine avant publication.
- Verifier que les synchros offline ne re-injectent pas les anciennes donnees apres purge.

## Livrables
- Script (SQL ou CLI) supprimant les entrees demo identifiees.
- Rapport de verification listant les tables nettoyees et l'etat final (counts).
- Mise a jour de la documentation release (RELEASE.md) integrant cette etape.

## Etapes
1. Cartographier les donnees de test (IDs, tags, emails) a supprimer.
2. Executer des requetes `DELETE` ciblees ou `truncate` si approprie, en conservant au moins un compte admin de test.
3. Vider le bucket `animal-media` des fichiers de demo (cf. Task 18) et reinitialiser les queues `sync_queue`.
4. Lancer l'application, effectuer quelques insertions, confirmer que les nouvelles donnees apparaissent et persistent.
5. Documenter le processus dans `RELEASE.md` et ajouter une checklist "Pre-prod cleanup".

## Dependances
- Tasks 16 a 22 completes pour eviter des surprises (schema, encodage, UI).

