# Analyse Khodan vs Everbreed

## Tableau des modules

| Module Everbreed | Ce qui existe deja dans Khodan | Travail a prevoir |
| --- | --- | --- |
| Tableau de bord | Ecran dashboard de base (stats simples, RPC get_dashboard_kpis) | Ajouter raccourcis actions, planning rapide, indicateurs complets, design adapte |
| Eleveurs (Breeders) | Module animals partiel (fiche simple, pas de categories claires) | Completer fiches (categories, tatouage, parents), gerer import CSV, actions en masse |
| Portees et cages | Evenements et animals suivent la reproduction mais pas de page portees dediee | Creer ecran litters, gestion cages ou enclos, actions groupees |
| Agenda / Planning | Quelques evenements, pas de vues liste ou calendrier visibles | Construire module planning avec vues multiples et filtres |
| Modeles de taches | Aucun ecran specifique, logique non documentee | Ajouter creation de modeles reproduction et traitement + notifications |
| Sante | Tables support_requests, pas de module sante cote utilisateur | Construire bibliotheque maladies et suivi traitements |
| Finances et contacts | Aucun module Flutter visible, tables non presentes | Ajouter tables transactions/contacts, ecrans et export |
| Rapports avances | Dossier reports mais contenu tres simple | Etendre indicateurs (reproduction, croissance, finances) + graphiques |
| Pedigrees | Fonction absente | Creer fonction SQL pedigree et interface PDF |
| Cartes de clapier | Inexistant | Generateur de cartes + QR codes |
| Ventes / Transferts / Marketplace | Non implemente | Tables ventes/transferts, ecrans, lien avec finances |
| Mon compte et abonnements | Parametres basiques seulement | Definir plans, limites, ecran abonnement |
| Personnalisation et langues | Localisation partielle (arb) mais sans page utilisateur | Ajouter page preferences (langue, unite, devise, theme) |
| Notifications | Notifications non detaillees, semble basique | Clarifier canaux (email, SMS) et flux automatique |
| Knowledge base et support | Table knowledge_articles et support_requests presentes | Verifier ecran client, traductions, workflow assistance |

## Base de donnees (audit 2025-10-30)
- **Requetes executables dans le SQL Editor**  
  - `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;`  
  - `SELECT event_object_table, trigger_name FROM information_schema.triggers WHERE event_object_schema = 'public' ORDER BY event_object_table, trigger_name;`  
  - `SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;`
- **Etat observe**  
  - Tables presentes dans les migrations + API : `profiles`, `species_config`, `animals`, `breeding_records`, `breeding_metrics`, `events`, `animal_events`, `sync_queue`, `support_requests`, `event_templates`, `food_types`, `food_stock`, `knowledge_articles`, `user_preferences`, `animal_images`.  
    - Les deux dernieres n'apparaissent pas dans les migrations : a confirmer dans le SQL Editor (probables vues/tables manuelles).  
  - Tables critiques avec RLS et triggers `updated_at` deja definis : `support_requests`, `event_templates`, `food_types`, `food_stock`, `knowledge_articles`.  
  - Triggers en place d'apres `20251022120000_post_task15_adjustments.sql` : `trg_support_requests_updated_at`, `trg_event_templates_updated_at`, `trg_food_types_updated_at`, `trg_food_stock_updated_at`, `trg_knowledge_articles_updated_at`.
- **Lacunes / actions a mener**  
  - Verifier via SQL Editor que `breeding_records` et `breeding_metrics` existent bien (non exposes via PostgREST en mode anon).  
  - Ajouter un export des resultats de cheminement (copier/coller du SQL Editor) dans `docs/supabase-execution-guide.md` a chaque audit.  
  - Confirmer que `schema_migrations` est synchronise pour toutes les migrations appliquees manuellement.

## Points sensibles
- Connexion Supabase difficile via CLI; preferer l editeur SQL pour appliquer les migrations.
- Peu de documents sur les modules existants; risque d oublier des dependances.
- Pas de designer; il faudra proposer un style simple mais coherent.
- Veiller a garder la base actuelle sans casser les donnees deja en place.

## Reponses collectees
- Parcours et captures Everbreed : voir le dossier de reference (PDF, DOCX, images) — [ouvrir le PDF](../Info-de%20r%C3%A9f%C3%A9rence/Captures%20et%20formules%20Everbreed.pdf).
- Formules de rappels (palpation, sevrage, etc.) : voir [Captures et formules Everbreed.docx](../Info-de%20r%C3%A9f%C3%A9rence/Captures%20et%20formules%20Everbreed.docx).
- Organisation des roles : proprietaire qui peut attribuer des droits a une equipe (ouvrier, veterinaire, autres).
- Moyens de paiement : integrer Kkiapay et Feda (activation des comptes a venir, infos disponibles sur demande).
- Notifications : prevoir SMS et e-mail comme canaux principaux.
