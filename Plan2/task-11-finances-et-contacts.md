# Tâche 11 - Module finances et carnet de contacts

## Objectif
Mettre à disposition un ledger financier simple et un carnet d’adresses lié aux transactions et transferts.

## Sous-tâches
1. Décrire dans `docs/finances-spec.md` les catégories par défaut (alimentation, soins, ventes, transports, etc.) et les champs de transaction.
2. Vérifier ou créer les tables Supabase : `financial_transactions`, `contacts`, `transaction_categories`. Rédiger les migrations correspondantes.
3. Implémenter les écrans :
   - Liste des transactions avec filtres (période, catégorie, éleveur).
   - Formulaire d’ajout/modification avec pièce jointe (photo du reçu).
   - Liste des contacts et formulaire d’édition.
4. Ajouter l’import/export CSV (utiliser `dart:io` et `csv`), avec un guide simple dans le spec.
5. Créer un test widget ou un test de service pour vérifier l’ajout d’une transaction et la liaison au contact.

## Livrables
- `docs/finances-spec.md`.
- Migrations Supabase et code Flutter pour finances + contacts.

## Notes
- Toujours afficher les montants en FCFA par défaut, avec possibilité de changer la devise (prévoir un champ).
- Corriger tout avertissement Flutter avant de fermer la tâche.
