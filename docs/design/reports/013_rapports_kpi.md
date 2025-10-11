# Rapports et KPIs (Oct 2025)

Spécification design pour la tâche 013.

## 1. Objectifs
- Fournir une vue analytique et exportable des données élevage (productivité, finances, santé).
- Permettre filtrage avancé par période, espèce, ferme, catégorie.
- Générer exports PDF/CSV conformes et partageables.

## 2. Structure écran principal
- **Header** : titre «Rapports», filtre période (DateRangePicker), filtres secondaires (ferme, espèce, type rapport), bouton `Exporter` (menu: PDF, CSV).
- **Navigation rapports** : tabs ou side nav (Production, Reproduction, Finances, Santé, Stocks).
- **Résultats** :
  - Section KPI (cartes synthèse).
  - Section graphiques (courbes, barres, camemberts).
  - Tableau détaillé (données par animal / période).
- **Panneau latéral** (option) : ajustements filtres, colonnes.

## 3. Rapports prioritaires (MVP)
1. **Productivité** :
   - KPI : taux réussite reproduction, kits sevrés/femelle, mortalité.
   - Graphique : courbe kits nés par semaine.
   - Tableau : liste cycles avec stats.
2. **Finances** :
   - KPI : revenus, dépenses, marge.
   - Graphique : bar chart revenus vs dépenses.
   - Tableau : transactions (filtres catégorie, compte).
3. **Santé** :
   - KPI : traitements réalisés, taux respect vaccins.
   - Graphique : heatmap événements santé.
   - Tableau : historique traitements.

## 4. Exports
- UI `Exporter` -> modale sélection format, plage, colonnes.
- Option planification (envoyer par email chaque semaine) -> future.
- Indiquer taille estimée + progression.

## 5. Accessibilité & UX
- Legendes explicites pour graphes.
- Contrastes pour couleurs (utiliser palette DS).
- Navigation clavier sur tableau.
- Tooltips sur points data.

## 6. Composants à implémenter
- `KhodanReportFilterDrawer`.
- `KhodanKpiTile` (réutilisable dashboard).
- `KhodanChartWrapper` (intégration fl_chart).
- `KhodanDataTable` extension (colonnes dynamiques).
- `ExportConfirmationDialog`.

## 7. Livrables design
- Maquettes desktop (focus). Mobile -> simplifier : afficher graphiques + résumé, export par email.
- Mockups PDF résultat (extrait).
- Guides style pour graphiques (axes, couleurs, typographies).

## 8. Actions suivantes
1. Designer: produire maquettes par rapport.
2. PO: valider KPIs calculés.
3. Dev: préparer implémentation (tâche 033-035-039-040-041 selon modules).
