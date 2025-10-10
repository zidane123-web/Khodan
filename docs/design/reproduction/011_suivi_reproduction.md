# Suivi reproduction Khodan (Oct 2025)

Spécification design pour la tâche 011.

## 1. Objectifs
- Visualiser rapidement l état des cycles reproduction par femelle.
- Planifier et suivre les tâches clés (palpation, mise bas, sevrage).
- Fournir alertes et rappels proactifs.

## 2. Écran principal
- **Header** : titre «Reproduction», filtres (période, espèce, statut).
- **Tabs** : `Timeline`, `Calendrier`, `Statistiques`.

### Timeline
- Vue verticale liste, groupée par statut (En cours, À vérifier, Clôturé).
- Chaque carte = cycle reproduction (doe + buck + dates clés).
- Indicateur progression (barre 0-100%).
- Boutons : `Marquer palpation`, `Enregistrer mise bas`, `Plus` (autres actions).
- Alertes : `KhodanTag` warning si retard.

### Calendrier
- Vue calendrier mensuel avec événements colorés (palpations, mises bas).
- Mode semaine (mobile) -> agenda.
- Drag and drop (future amélioration) — prévoir visuel.

### Statistiques
- Graphique courbe taux succès, histogramme kits sevrés, distribution intervalles.

## 3. Fiche cycle reproduction
- Accès depuis timeline.
- Sections : Infos cycle (dates, animaux), Tâches prévues/completées, Notes, Historique.
- Actions rapides : `Modifier dates`, `Annuler cycle`, `Notifier équipe`.

## 4. Formulaires / interactions
- **Création cycle** : couplage doe + buck, date accouplement, notes.
- **Palpation** : date, résultat (positif, négatif, inconnu), commentaire.
- **Mise bas** : date, kits vivants/morts, complications.
- **Sevrage** : date, kits sevrés, poids moyen.
- Validation (valeurs ≥ 0, cohérence dates).

## 5. Rappels & notifications
- Configurables via paramètres (tache 014/024/036).
- Par défaut :
  - Palpation +12 jours.
  - Mise bas +31 jours.
  - Sevrage +59 jours.
- Afficher countdown (J-3) dans timeline.

## 6. Accessibilité / offline
- Afficher icône offline si action non synchronisée.
- Couleurs = accompagnées d icônes (check, warning, info).
- Navigation clavier sur timeline (flèches haut/bas).

## 7. Composants nécessaires
- `KhodanTimeline` (liste verticale statuts + dots).
- `KhodanCalendar` (page calendrier interactions).
- `KhodanCycleCard` (résumé cycle).
- `KhodanTaskList` (checklist palpation/mise bas/sevrage).

## 8. Livrables design
- Maquettes desktop/mobile timeline, calendrier.
- Fiche cycle détail.
- Modèles de notifications (UI).

## 9. Actions suivantes
1. Designer : produire maquettes.
2. PO : valider flux dates et règles.
3. Dev : préparer implé (tâches 033 + 034).
