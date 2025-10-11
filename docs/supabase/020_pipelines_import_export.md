# Pipelines import/export (Oct 2025)

Spécifie les scripts et processus pour la tâche 020.

## Import
- Format CSV supporté pour : animaux, événements, stocks.
- Localisation : /imports/<type>/<timestamp>.csv (storage Supabase ou local). 
- Validation :
  - Structure conforme (en-têtes obligatoires).
  - Données normalisées (dates ISO8601, montants décimaux, IDs.
  - Vérification existence ferme/profil.
- Processus :
  1. Upload CSV -> table staging (stg_animals, stg_events).
  2. Fonction SQL/edge function valide & insère dans tables cibles.
  3. Notifications en cas d erreurs (stockées dans 
otifications_queue).
- Service Flutter : ImportExportService (lecture / écriture CSV). 

## Export
- Options : CSV (animaux, événements, transactions), PDF (rapports).
- Flow :
  1. User sélectionne colonnes/période.
  2. App appelle edge function (génération fichier).
  3. Fichier stocké (Supabase Storage) + lien disponible.
- Génération PDF -> future (utiliser package pdf existant).

## Scripts suppl.
- supabase/functions/notification-dispatcher/index.ts (déjà créé) extensible pour notifier résultat import.
- Prévoir edge function import_animals (future tâche) -> insert orchestrée.

## TODO
- Créer tables staging, validations (phases M1/M2).
- Lier process à UI (modules Animaux, Finances).
- Configurer CRON pour flush staging et queue notifications.
