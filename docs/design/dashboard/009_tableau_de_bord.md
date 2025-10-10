# Tableau de bord Khodan (Oct 2025)

Spécifications design pour la tâche 009.

## 1. Objectifs écran
- Offrir une vision synthétique de l élevage en un coup d œil (indicateurs clés).
- Mettre en avant les actions urgentes (alertes, événements à venir).
- Permettre une navigation rapide vers les modules Animaux, Reproduction, Inventaire, Finances.

## 2. Structure page (desktop)
1. **Header**
   - Titre «Tableau de bord» + `KhodanTag` affichant la ferme sélectionnée.
   - Sélecteur de période (7 jours, 30 jours, 12 semaines) -> menu déroulant.
   - Bouton ghost «Exporter» (futur rapport PDF/CSV).
2. **Section KPI principales (2 lignes, 3 cartes)**
   - KPI 1 : Production (nombre naissances / weaned), variation vs période précédente.
   - KPI 2 : Taux de gestation (pourcentage).
   - KPI 3 : Mortalité / pertes.
   - KPI 4 : Revenus sur période (si module finance activé).
   - KPI 5 : Stock critique (le + proche du seuil).
   - KPI 6 : Alertes sanitaires (nombre).
3. **Graphiques**
   - Zone chart (production hebdo).
   - Bar chart (ventes vs dépenses) -> affichable si module finance.
4. **Section tâches & rappels**
   - Liste d événements à venir (timeline horizontale) avec `KhodanCard`.
   - Bouton primaire «Programmer un événement».
5. **Section insights**
   - Tips générés (ex: «3 femelles en retard de palpation»).
   - Utiliser `KhodanTag` warning/info pour hiérarchiser.

## 3. Layout mobile
- Scroll vertical.
- Empiler les cartes KPI (2 par ligne) -> responsive.
- Graphique convertible en carrousel swipe.
- Tâches affichées dans une liste simple.

## 4. Composants à utiliser / développer
- `KhodanCard`, `KhodanTag`, `KhodanPrimaryButton`.
- Nouveaux composants à prévoir :
  - `KhodanKpiTile` (icône, valeur, delta, label).
  - `KhodanTrendChart` wrapper (s appuie sur fl_chart).
  - `KhodanEventListItem`.

## 5. Données & états
- Supporter placeholders / skeletons (chargement) -> shimmering.
- Etat vide : «Aucune donnée mesurée» + CTA importer.
- Erreur : message + bouton réessayer.

## 6. Accessibilité
- Couleurs des deltas (vert/rouge) accompagnées d icônes et texte.
- Graphiques : légendes textuelles/clés de lecture.
- Navigation via clavier (focus sur CTA et sélecteur période).

## 7. KPI détaillés
- Calculs basés sur période sélectionnée.
- Variation = (valeur période - période précédente) / période précédente.
- Indicateur de tendance : flèche up/down + couleur.

## 8. Livrables design
- Maquettes hi-fi (mobile, desktop).
- Variante mode offline (info banner «Mode hors ligne activé»).
- Document de guidage pour dev (mesures, marges, interactions).

## 9. Next steps
1. Designer finalise maquettes.
2. PO valide KPIs prioritaires.
3. Préparer backlog implé (tâche 031 + 041 pour performance).
