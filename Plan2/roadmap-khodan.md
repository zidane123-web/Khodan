# Roadmap Khodan

Guide d'action pour transformer l'analyse 'Everbreed vs Khodan' en plan concret. Chaque phase indique les livrables, les dependances et les impacts sur Flutter, Supabase et les tests.

## Phase 1 : Base solide

**Pre-requis techniques**
- Verifier que la navigation Flutter fonctionne sur mobile et web (Navigator 2.0 ou Routemaster deja en place).
- Mettre a jour le schema Supabase de base (tables `breeders`, `litters`, `events`) et definir des politiques RLS simples.
- Mettre en place un jeu de donnees de demonstration pour tester les ecrans sans production.

### Navigation et structure de l'application
- Faire une navigation laterale sur desktop et une barre inferieure avec menu 'Plus' sur mobile.
- Dependances : demande que toutes les routes de la phase soient definies et reliees a l'authentification existante.
- Impacts Flutter : creer un `Scaffold` racine commun, configurer les icones, les etats actifs et un bouton flottant global.
- Impacts Supabase : pas de nouveau schema, mais prevoir une table `user_settings` pour garder la derniere section visitee.
- Tests : widget tests pour la navigation entre sections et la gestion des roles.

### Tableau de bord de demarrage
- Faire un ecran d'accueil avec indicateurs de cheptel, raccourcis d'actions et apercu du planning.
- Dependances : utilise les KPIs des modules Eleveurs, Portees et Planning.
- Impacts Flutter : assembler des cartes reutilisables (`DashboardCard`, `ActionShortcut`), penser responsive.
- Impacts Supabase : etendre la RPC `get_dashboard_kpis`, ajouter des vues materialisees si besoin.
- Tests : tests d'integration pour le chargement des KPIs et des actions rapides.

### Module Eleveurs (Breeders)
- Faire une liste filtrable, des fiches completes (categories, parents, tatouages) et l'import CSV.
- Dependances : demande un systeme de categories et un lien avec Portees et Planning.
- Impacts Flutter : creer vues liste/table, fiche avec onglets ('Profil', 'Historique', 'Actions'), modales d'edition.
- Impacts Supabase : completer tables `breeders`, `breeder_categories`, ecrire fonctions pour import CSV et actions groupees.
- Tests : tests unitaires pour les conversions CSV, tests d'integration pour la creation/edition et les filtres.

### Module Portees et cages
- Faire un ecran dedie aux portees, gestion des cages et fusion de portees.
- Dependances : s'appuie sur Eleveurs pour les parents et sur Planning pour les rappels.
- Impacts Flutter : creer vues cartes + tableau, formulaires pour affecter une cage, enregistrer une naissance, fusionner des portees.
- Impacts Supabase : creer tables `litters`, `cages`, `litter_events`, ecrire triggers pour le calcul de la taille et du statut.
- Tests : tests de regles metier (limite de capacite), tests widget pour fusionner ou deplacer une portee.

### Planning (Agenda)
- Faire une vue liste + calendrier, filtres (type de tache, lapine, periode) et generation d'export.
- Dependances : consomme les taches des modules Eleveurs, Portees et Modeles de taches.
- Impacts Flutter : integrer un calendrier (table_calendar ou equivalent), etats termines/a faire, boutons de validation.
- Impacts Supabase : etendre table `events`, creer vues `upcoming_events` et fonction pour exporter en iCal.
- Tests : tests d'integration pour la creation de rappel, tests de generation d'iCal.

### Modeles de taches de reproduction
- Faire un gestionnaire de chaines de taches (palpation, nid, sevrage) ajustables par elevage.
- Dependances : Planning doit pouvoir instancier ces modeles lors d'une saillie.
- Impacts Flutter : formulaires dynamiques (liste d'etapes, delais relatifs), duplication depuis modeles par defaut.
- Impacts Supabase : tables `task_templates`, `task_template_steps`, fonction pour instancier des evenements a partir d'un modele.
- Tests : tests unitaires des calculs de dates (saillie + delai), tests widget pour ajouter ou retirer une etape.

### Notifications de base
- Faire des notifications in-app ou e-mail pour les taches critiques (palpation, nid, sevrage).
- Dependances : demande le Planning operationnel et la collecte des preferences utilisateur.
- Impacts Flutter : badge sur l'onglet Tasks et banniere dans le dashboard.
- Impacts Supabase : table `notifications`, fonction edge qui envoie l'e-mail via Supabase.
- Tests : tests automatises pour verifier le declenchement lors de la creation d'un evenement.

## Phase 2 : Modules avances

**Pre-requis techniques**
- Mettre en place un design system simple (palette, typographie, composants) pour harmoniser les nouveaux ecrans.
- Activer la journalisation des actions (table `audit_logs`) pour tracer sante, finances et transferts.
- Stabiliser les politiques RLS avant d'ajouter des tables sensibles.

### Sante et suivi des traitements
- Faire une bibliotheque de maladies, des fiches traitement et des rappels de soins.
- Dependances : Planning pour generer les rappels, Notifications pour alerter.
- Impacts Flutter : formulaires multi-etapes (diagnostic, prescription, pieces jointes), tableaux de bord sante.
- Impacts Supabase : tables `ailments`, `health_records`, `treatment_templates`, stockage des fichiers dans Supabase Storage.
- Tests : tests d'integration sur la creation de traitement, tests unitaires sur les calculs de dates de rappel.

### Finances et contacts
- Faire un ledger revenus/depenses, gestion de contacts (clients, veterinaire) et exports.
- Dependances : Ventes/Transferts fournit des transactions, Abonnements (phase 3) reutilise le ledger.
- Impacts Flutter : vues tableau avec filtres, graphiques simples via `charts_flutter`.
- Impacts Supabase : tables `transactions`, `contacts`, `payment_methods`, fonctions d'agregation mensuelle.
- Tests : tests d'integration pour les exports CSV, tests unitaires sur le calcul des soldes.

### Rapports avances
- Faire rapports reproduction, croissance, finances avec graphiques et PDF.
- Dependances : demande des donnees fiables des modules Eleveurs, Portees, Finances.
- Impacts Flutter : ecran ' Rapports ' avec filtres et generation PDF (package printing).
- Impacts Supabase : vues agregees, fonctions RPC pour series temporelles, job planifie pour le rafraichissement.
- Tests : tests d'instantane (golden tests) pour le PDF, tests unitaires sur les agregations.

### Pedigrees
- Faire un generateur d'arbre genealogique et export PDF.
- Dependances : module Eleveurs doit stocker parents et lignees.
- Impacts Flutter : widget arbre dynamique, options d'impression.
- Impacts Supabase : fonction recursive (SQL ou edge function) pour remonter quatre generations, table `pedigree_exports`.
- Tests : tests unitaires sur la fonction recursive, tests widget sur le rendu d'un arbre simple.

### Cartes de clapier et QR codes
- Faire un generateur de cartes imprimables avec QR vers la fiche du lapin.
- Dependances : Eleveurs et Portees pour alimenter les donnees.
- Impacts Flutter : page de configuration (format, informations visibles), generation PDF, integration `qr_flutter`.
- Impacts Supabase : stocker des modeles (`cage_card_templates`), fonction de rendu (peut rester cote Flutter si offline).
- Tests : tests widget sur l'apercu PDF, tests unitaires pour verifier les URL/QR.

### Ventes, transferts et marketplace
- Faire un flux pour vendre, transferer un lapin et suivre l'etat (en attente, livre, archive).
- Dependances : Finances pour la compta, Contacts pour l'acheteur, Notifications pour les alertes.
- Impacts Flutter : formulaires, liste de transactions, indicateur d'avancement.
- Impacts Supabase : tables `sales`, `transfers`, triggers pour mettre a jour l'inventaire et le ledger.
- Tests : tests d'integration sur une vente complete, tests unitaires sur les validations (stock disponible).

### Notifications multi-canaux
- Faire le support SMS et e-mail avec preferences par type d'alerte.
- Dependances : Notifications de base, Finances (paiements), Sante (soins).
- Impacts Flutter : page de preferences, opt-in par canal.
- Impacts Supabase : integrer un fournisseur SMS (Kkiapay ou passerelle locale via API REST), table `notification_preferences`.
- Tests : tests unitaires sur la selection du canal, tests d'integration avec simulateur de webhooks.

## Phase 3 : Personnalisation et abonnements

**Pre-requis techniques**
- Mettre en place un systeme de roles (proprietaire, ouvrier, veterinaire) aligne avec les policies RLS.
- Preparer l'integration paiement (Kkiapay, Feda) via edge functions securisees.
- Documenter les limites de plans (nombre de lapins, utilisateurs, stockage) avant de coder.

### Mon compte et abonnements
- Faire une page compte avec gestion des plans, factures, limites et annulations.
- Dependances : Finances pour la facturation, systeme de roles pour limiter l'acces.
- Impacts Flutter : ecrans de parametres, formulaire de changement de plan, affichage des factures PDF.
- Impacts Supabase : tables `subscriptions`, `invoices`, edge functions pour creer les sessions de paiement.
- Tests : tests d'integration sur le changement de plan (mock API), tests unitaires sur le calcul des quotas.

### Personnalisation et preferences
- Faire reglages langue, unite, devise, themes, modules visibles.
- Dependances : demande `user_settings` (phase 1) et localisation existante.
- Impacts Flutter : gestion dynamique de la locale (fr, en, ar), theme clair/sombre, toggles par module.
- Impacts Supabase : etendre `user_settings`, stocker devise/unite, recharger les modules via `supabase.auth.onAuthStateChange`.
- Tests : tests widget pour le changement de langue et de theme, tests unitaires sur la conversion des unites.

### Knowledge base et support
- Faire une base d'articles + un flux de tickets support.
- Dependances : Notifications multi-canaux pour les accuses, roles pour limiter l'acces.
- Impacts Flutter : page FAQ avec recherche, formulaire ticket (categorie, priorite, piece jointe).
- Impacts Supabase : tables `knowledge_articles`, `support_requests`, workflow d'assignation avec statuts et commentaires.
- Tests : tests d'integration pour la creation/modification de ticket, tests unitaires sur la recherche d'articles.

### Gestion d'equipe et permissions fines
- Faire une interface pour inviter des collaborateurs, attribuer roles et permissions par module.
- Dependances : systeme de roles finalise, modules existants pour delimitation.
- Impacts Flutter : ecrans pour invitations, liste d'utilisateurs, toggles par permission.
- Impacts Supabase : tables `team_members`, `invitations`, policies detaillees, edge function pour les e-mails d'invitation.
- Tests : tests de securite (policies) via `pgTAP` ou `supabase test`, tests widget pour les changements de permissions.

### Experience premium et marketplace future
- Faire des scenarios pour les options premium (analyses avancees, vitrine marketplace regionale).
- Dependances : Abonnements, Ventes, Finances.
- Impacts Flutter : bannieres d'upsell, pages vitrine premium.
- Impacts Supabase : colonnes `plan_required` sur les modules, flags pour activer ou non certaines APIs.
- Tests : tests unitaires pour verifier les restrictions selon le plan, tests d'integration des flux d'upgrade.

## Risques et astuces

- **Connexion Supabase instable** : si la CLI bloque, appliquer les migrations via l'editeur SQL web en copiant les scripts.
- **Donnees sensibles sante/finance** : activer les policies RLS avant production et tester avec des roles differents.
- **Charge de tests** : planifier des tests automatiques a chaque fin de phase (CI GitHub Actions) pour eviter les regressions.
- **Design sans designer** : adopter une palette simple (vert Khodan, gris, blanc) et reutiliser les memes composants.
- **Performances mobiles** : charger les donnees par pagination et Riverpod/FutureBuilder pour limiter les requetes.
- **Integrations SMS/paiement** : utiliser les environnements sandbox Kkiapay/Feda en phase 3, stocker les secrets dans Supabase ou `.env`.
- **Support video** : si l'envoi de pieces lourdes pose probleme, convertir les videos en liens heberges (Drive, YouTube prive).

