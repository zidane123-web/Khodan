# Module finances & stocks (Oct 2025)

Spécification design pour la tâche 015.

## 1. Objectifs
- Suivre ventes, achats, dépenses et inventaire (aliments, consommables).
- Visualiser trésorerie, analyser marges et générer documents (factures, reçus).
- Gérer les mouvements de stock et alertes seuils.

## 2. Navigation module
- Tabs ou side nav : `Tableau de bord`, `Transactions`, `Factures`, `Stocks`, `Suppliers` (future).

### Tableau de bord finances
- KPI : Revenus période, Dépenses, Marge nette, Factures en retard.
- Graphiques : courbe cashflow, bar chart revenus vs dépenses par catégorie.
- Alertes : `KhodanTag` warning (factures impayées, stocks bas).

### Transactions
- Table (Desktop) : Date, Type (vente/achat/dépense), Catégorie, Montant, Animal lié, Notes.
- Filtres : période, type, catégorie, ferme, statut.
- Actions : `Ajouter transaction` (form modal), import CSV.
- Batch actions : marquer payé/non payé.

### Factures
- Cards/list view : client, montant, statut (Envoyée, Payée, En retard).
- Détails facture : preview PDF, lignes (description, quantité, prix, taxes).
- Actions : `Envoyer`, `Télécharger PDF`, `Marquer payée`.

### Stocks
- Liste items (Nom, Catégorie, Quantité, Unité, Seuil, Dernier mouvement).
- Boutons : `Ajouter item`, `Mouvement stock` (entrée/sortie/ajustement).
- Graphique mini (sparkline) variation stock.
- Section alertes (items sous seuil).

## 3. Formulaires clés
- **Transaction** : type, montant, devise, catégorie, animal lié (autocomplete), date, note, pièces jointes.
- **Facture** : client, numéro auto, lignes (description, quantité, prix, TVA), total, conditions paiement.
- **Stock mouvement** : type (in/out/adjust), quantité, raison, lien événement, coût (si entrée).

## 4. Exports & intégrations
- Export CSV (transactions, stocks) -> modale.
- Génération PDF (facture) -> preview.
- Prévoir connecteur futur (API compta) -> placeholder.

## 5. Accessibilité
- Indiquer symboles monétaires, format chiffres.
- Couleurs pour gains/pertes + icônes.
- Tableaux navigables clavier.

## 6. Composants à implémenter
- `KhodanMoneyCard` (affiche valeur + variation).
- `KhodanTransactionTable`.
- `KhodanInvoicePreview` (widget).
- `KhodanStockCard` (quantité + seuil).
- `KhodanMovementDialog`.

## 7. Livrables design
- Maquettes desktop (mobile -> simplifier).
- Template facture (PDF) -> aligné branding.
- Icônes catégorie (vente, achat, dépense, stock).
- Document flux import/export.

## 8. Actions suivantes
1. Designer : produire maquettes + template.
2. PO : valider catégories transaction/stock.
3. Dev : préparer implémentations (tâches 035 + 036 + 020).
