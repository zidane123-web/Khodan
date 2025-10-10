# Design system Khodan (Oct 2025)

Document de reference pour la base visuelle et l industrialisation UI de l application Khodan.

## 1. Identite visuelle
- **Palette primaire**
  - `Khodan Blue`: #1B4D8C (Primary)
  - `Pasture Green`: #47A36D (Success)
  - `Sunrise Amber`: #FFB347 (Warning)
  - `Clay Red`: #D96B5F (Danger)
  - Gris neutres: `#101828`, `#475467`, `#667085`, `#98A2B3`, `#D0D5DD`, `#F2F4F7`
- **Typographie**
  - Titres: `Poppins` (Semibold/Bold)
  - Corps: `Inter` (Regular/Medium)
  - Tailles par defaut (mobile) : H1 32, H2 28, H3 24, H4 20, H5 18, H6 16, Body 16, Small 14.
- **Iconographie**
  - Pack Material Symbols arrondis.
  - Icônes personnalisées (animaux, reproduction, finances) à produire en SVG.

## 2. Grille et espacements
- Grille mobile : 4 colonnes, marge 16 px, gouttière 16 px.
- Grille tablette : 8 colonnes, marge 24 px, gouttière 24 px.
- Grille desktop : 12 colonnes, marge 32 px, gouttière 24 px.
- Echelle d’espacement basée sur multiples de 4 : 4, 8, 12, 16, 20, 24, 32, 40, 48.
- Rayons de bordure : 4 (inputs), 8 (cards), 16 (modales).

## 3. Styles UI basiques
- **Boutons**
  - Primary (rempli) : fond `Khodan Blue`, texte blanc, hover `#163E70`.
  - Secondary (outline) : bord `Khodan Blue`, texte `#1B4D8C`, hover fond `#E7F0FB`.
  - Tertiary (ghost) : texte `#1B4D8C`, hover `#E7F0FB`.
  - Danger : fond `Clay Red`, hover `#B15449`.
- **Inputs**
  - Bord par défaut `#D0D5DD`, focus `#1B4D8C`, erreur `#D96B5F`.
  - Etiquettes flottantes, messages aide 12 px.
- **Cards**
  - Fond blanc, ombre douce `0 10 30 rgba(16,24,40,0.08)`.
  - Header optionnel (icône + titre).
- **Listes**
  - List tiles 64 px, leading icône/avatar, trailing actions.
- **Feedback**
  - Snackbars : fond `#101828`, texte blanc.
  - Alertes (success/warning/error/info) déclinées dans la palette.

## 4. Composition components Flutter
- `KhodanPrimaryButton`, `KhodanSecondaryButton`, `KhodanIconButton`.
- `KhodanCard` (header, body, footer slots).
- `KhodanTag` (statut, niveau, accent).
- `KhodanEmptyState` (illustration + CTA).
- `KhodanFormField` (text + mask + validation).
- `KhodanSummaryTile` (pour KPIs dashboard).
- `KhodanSegmentControl` (2-4 options rapides).
- `KhodanStepIndicator` (wizard onboarding).
- Prévoir `KhodanDataTable` responsive (desktop).

Ces composants doivent résider dans `lib/app/core/widgets` avec histoire (preview) et tests golden (tâches 006 & 039).

## 5. Etats & systeme de thèmes Flutter
- Utiliser `ThemeData` personnalisé via `buildKhodanTheme()` (existant).
- Etendre `ColorScheme` : `primary`, `secondary`, `tertiary`, `surfaceTint`, `error`, `success`, `warning`, `info`.
- Définir `TextTheme` complet (headline, title, body, label) selon typographie.
- Ajouter extension `KhodanSpacing` & `KhodanRadius` pour cohérence.
- Prévoir mode sombre (future release) avec inversion palette neutre + touches accent.

## 6. Accessibilite & i18n
- Contraste minimal 4.5 pour textes > 16 px ; test palette.
- Taille interactive minimale 44 px.
- Support `TextScaleFactor` jusqu’à 1.3 sans cassure.
- Préparation pour localisation (pas de texte en dur dans design). Voir tache 042 pour implementation.

## 7. Livrables design (Figma ou autre)
- Page `Khodan Design System` contenant :
  - Styles couleur + typographie.
  - Bibliothèque de composants (atoms, molecules, organisms).
  - Layout patterns (formulaire, page liste, page detail, modales).
  - Variants (hover, désactivé, focus) et tokens.
- Lib Figma partagée avec versioning (ex: FigJam/Notion documentation).
- Checklist d adoption : tout nouvel écran doit se référer à cette bibliothèque.

## 8. Gouvernance
- Nommer un ou deux mainteneurs design system (designer + dev UI).
- Process de contribution :
  1. Proposer composant dans Figma.
  2. Valider via revue design + revue dev.
  3. Implémenter composant Flutter + tests golden.
  4. Documenter usage dans `docs/design/components.md`.
- Releases versionnées (ex: `DS v0.1`, `DS v0.2`).

## 9. Actions immediates (tache 005/006)
- DS-01 : Finaliser palette/typo et mettre à jour `theme.dart` selon tokens.
- DS-02 : Inventorier composants existants -> plan de refactor `lib/app/core/widgets`.
- DS-03 : Créer space `docs/design/components.md` pour documenter.
- DS-04 : Mettre en place storybook Flutter (option: `dashbook` ou simple route `DesignShowcasePage`).

## 10. References croisees
- `lib/app/config/theme.dart` à faire évoluer selon ce document (tache future).
- `plan/006_IndustrialiserComposantsCommuns.md` pour production composants.
- Intégrer ce doc à la doc projet (tache 046).
