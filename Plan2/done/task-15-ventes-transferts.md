# Tache 15 - Ventes, transferts et marketplace

## Objectif
Permettre la vente d'un lapin, le transfert vers un autre compte et la preparation d'une petite marketplace interne, tout en reliant les finances.

## Sous-taches
1. Ecrire `docs/transferts-ventes.md` avec trois sections claires: (a) vente locale (prix, contact, preuve), (b) transfert vers un autre utilisateur Khodan, (c) publication marketplace (mini annonce).
2. Cote Supabase, verifier l'existant puis creer les tables ou colonnes manquantes: `rabbit_sales`, `rabbit_transfers`, `marketplace_listings`. Ajouter les contraintes (etat, reference vers `contacts`, date de cloture). Si le CLI supabase echoue, passer par l'editeur SQL puis recopier le script dans une migration.
3. Mettre a jour le code backend (services Dart) pour creer/mettre a jour une vente, declencher l'ecriture dans `financial_transactions` et archiver le lapin vendu.
4. Concevoir les ecrans Flutter:
   - Vue `VentesPage` avec liste, filtres simples (periode, statut) et bouton `Nouvelle vente`.
   - Formulaire `Nouvelle vente` (lapin, prix, contact, mode de paiement, note).
   - Vue `TransfertPage` avec champ email ou numero du destinataire et validation.
   - Vue `MarketplacePage` avec cartes des annonces et bouton `Publier`.
5. Ajouter les notifications: envoyer un email ou SMS (selon ce qui est deja en place) quand une vente est creee ou un transfert est en attente. Documenter la configuration dans le spec.
6. Prevoir des verifications pour debutants (par ex. message "Confirmer la vente" avant validation, tutoriel rapide).
7. Ecrire des tests de service (creation de vente, lien avec finances) et un test widget pour le formulaire.

## Livrables
- `docs/transferts-ventes.md`.
- Migrations Supabase pour ventes/transferts/annonces.
- Ecrans Flutter et tests.

## Notes
- Toujours permettre d'annuler une vente tant que le paiement n'est pas confirme.
- Penser a masquer les annonces expirees automatiquement (tache cron ou fonction planifiee a documenter).
- Pas de warning Flutter en sortie.
