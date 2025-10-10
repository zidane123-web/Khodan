# Implementer le module finances et stocks

## Objectif / But
Offrir une gestion financiere integree (factures, paiements, couts) et la gestion des stocks operatoires.

## Etapes concretes
- Creer les dossiers `lib/features/finances` et `lib/features/inventory` avec structure presentation/domain/data.
- Implementer les ecrans listes, fiches et formulaires selon les maquettes.
- Brancher aux repositories financiers et stock (Supabase) avec validations fortes.
- Ajouter les graphiques de tresorerie et couts par animal.
- Mettre en place les exports financiers conformes (CSV, PDF) et les tests.

## Fichiers ou modules concernes
- `lib/features/finances`
- `lib/features/inventory`
- `lib/data/repositories/finance_repository.dart (a creer)`
- `lib/data/repositories/inventory_repository.dart (a creer)`
- `plan/015_DesignerFinancesStocks.md`

## Resultat attendu / Critere de reussite
- Modules finances et stocks operationnels avec liaisons vers animaux et rapports.

## Prerequis eventuels
- 034_ImplGestionEvenements.md

