# Module Gestion des animaux (Oct 2025)

Spécification design pour la tâche 010.

## 1. Objectifs
- Permettre une consultation rapide de l ensemble du troupeau avec filtres et recherche.
- Accéder facilement aux fiches détaillées et aux actions clés (ajout d événement, modification, export).
- Gérer les imports/export et actions en lot.

## 2. Structure écran liste
1. **Header**
   - Titre «Animaux» + compteur (ex: 124).
   - Boutons : `Ajouter un animal` (primary), `Importer` (secondary), `Exporter` (ghost).
2. **Barre d outils filtres**
   - Recherche (texte, tag);
   - Filtres rapides (tags : Actif, Gestante, Jeunes, Vendus).
   - Filtre avancé (voir modale) : espèces, statut santé, date entrée.
3. **Tableau / cartes**
   - Desktop : tableau responsive 6 colonnes (ID, Nom, Sexe, Statut, Dernier événement, Actions).
   - Mobile : cartes empilées, résumé + boutons contextuels.
4. **Actions en lot**
   - Checkbox sélection multiple.
   - Barre contextuelle flottante : `Marquer traitement`, `Exporter`, `Supprimer`. Danger -> confirmation.
5. **Pagination / infinite scroll** selon dataset (à définir).

## 3. Fiche détaillée animal
- **Header** : photo (upload), tag, statut (KhodanTag variant), boutons `Ajouter événement`, `Modifier`, `Plus` menu.
- **Tabs** (3-4) :
  - Profil (infos générales, généalogie, poids, documents).
  - Reproduction (timeline reproduction, KPIs).
  - Santé (traitements, vaccins).
  - Production (courbes, quantités).
- **Sidebar** (desktop) : actions rapides (ex: «Planifier palpation», «Créer note»).
- **Section documents** : liste fichiers, upload bouton.

## 4. Formulaires création/modification
- Wizard à 3 étapes : Infos générales, Origine & généalogie, Santé & suivis.
- Champs : ID/tag, date naissance, sexe, provenance, sire/dam, statut santé, notes.
- Upload photo (image picker) + cropper.

## 5. Modales et interactions
- Filtre avancé (modale) : checkboxes, sliders.
- Confirmation suppression (danger button + résumé impacts).
- Import CSV : modale avec template download, upload dropzone, feedback.

## 6. Etat offline
- Banner en haut : «Mode hors ligne : modifications en attente de synchronisation».
- Les actions non disponibles (import, export) grisés.

## 7. Accessibilité
- Tableau accessible (navigable clavier, aria labels sur icônes).
- Contrastes sur statuts (KhodanTag + icônes).
- Alternative text pour photos.

## 8. Composants à implémenter
- `KhodanDataTable` (responsive + sélection multiple).
- `KhodanDetailHeader` (photo + actions).
- `KhodanTimeline` (réutilisable reproduction).
- Form fields : dropdown, date picker, file picker.

## 9. Livrables design
- Maquettes desktop/mobile liste.
- Maquettes fiche détail + formulaires.
- Assets icônes (sexe, statut, santé).
- Documentation flux import/export.

## 10. Next steps
1. Designer : livrer maquettes et assets.
2. PO : valider champs obligatoires.
3. Dev : préparer découpage implémentation (tâche 032 + 033).
