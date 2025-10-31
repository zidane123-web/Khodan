# Tache 16 - Mon compte et abonnements

## Objectif
Structurer la gestion des plans Khodan (gratuit, standard, pro, entreprise) et les ecrans pour que l'utilisateur suive son offre et ses factures.

## Sous-taches
1. Rediger `docs/abonnements.md` avec: (a) description simple de chaque plan (limite d'eleveurs, modules inclus), (b) processus pour passer a un plan superieur, (c) type de paiement prevu (manuel, mobile money, Stripe plus tard).
2. Controler Supabase: ajouter les tables `subscription_plans`, `user_subscriptions`, `farm_members` si elles n'existent pas. Prevoir des champs pour la date de debut, date de fin, statut, lien vers facture. Si le CLI echoue, ecrire le script dans l'editeur SQL puis copier le texte dans une migration.
3. Mettre en place des politiques RLS pour proteger ces tables (lecture seulement par le proprietaire ou le service_role).
4. Adapter le code Flutter pour lire le plan courant et bloquer les fonctions depassees (ex: un plan gratuit ne peut pas creer plus de 5 eleveurs). Documenter dans le spec comment afficher un message clair.
5. Creer l'ecran `MonComptePage` avec trois onglets: `Mes infos`, `Abonnement`, `Factures`. Ajouter des boutons simples: `Changer de plan`, `Telecharger facture`, `Ajouter un membre`.
6. Prevoir un flux de paiement manuel: generer une reference, afficher les instructions (par ex. "payer par mobile money"), et mettre a jour l'abonnement quand le paiement est confirme (peut se faire via une page admin ou un cron, a documenter).
7. Ecrire des tests (service pour verifier le calcul des limites, widget pour l'affichage du bandeau d'alerte quand le quota est depasse).

## Livrables
- `docs/abonnements.md`.
- Tables Supabase + RLS + migrations.
- Ecran `MonComptePage` et tests.

## Notes
- Garder un ton rassurant sur les ecrans (phrase courte, par exemple "Vous etes sur le plan Standard").
- Ajouter une TODO claire si une integration paiement doit etre traitee plus tard.
- Aucun warning Flutter ou lint dans les migrations SQL.
