# Parcours Onboarding Khodan (Oct 2025)

Ce document spécifie le parcours onboarding à produire (maquettes + annotations) pour répondre à la tâche 007.

## 1. Objectifs parcours
- Permettre à un nouvel utilisateur de configurer son compte et sa ferme en moins de 10 minutes.
- Collecter les informations indispensables pour personnaliser l expérience (type d élevage, taille du troupeau, objectifs).
- Faire découvrir les fonctionnalités clés (dashboard, reproduction, inventaire) via un tutoriel léger.
- Offrir un import initial des données (CSV animaux, PDF rapports).

## 2. Profil utilisateur ciblé
- Eleveurs lapins/petits ruminants, souvent mobile-first, connectivité variable.
- Plusieurs profils possibles : propriétaire, manager, technicien terrain.
- Niveau digital : intermédiaire (utilise smartphone, mais temps limité).

## 3. Flow global (écrans)
1. **Welcome / Intro**
   - Branding + bénéfices.
   - CTA «Commencer» et option «Se connecter» (redirige vers login).
2. **Création compte**
   - E-mail + mot de passe + acceptation CGU.
   - Option SSO (future phase) prévue dans UI.
3. **Vérification e-mail**
   - Écran d instructions + bouton «Ouvrir e-mail».
4. **Setup Ferme** (wizard multi-step)
   - Step 1 : Informations ferme (nom, localisation, devise, timezone).
   - Step 2 : Type d élevage (lapin, caprin, bovin futur) + objectifs (production, reproduction, traçabilité).
   - Step 3 : Taille troupeau & structures (nombre de femelles/mâles, parcs, cages).
   - Step 4 : Équipe (ajout optionnel membres + rôles).
5. **Import Données**
   - Proposition d importer CSV animaux / Excel reproduction / Fichiers existants.
   - Lien vers modèles (download).
   - Possibilité «Passer pour l instant».
6. **Tutoriel interactif**
   - 3-4 écrans swipables présentant dashboard, gestion animaux, rapports, mode offline.
   - CTA final «Accéder à l application» -> redirige vers Dashboard avec tips contextuels.

## 4. Détails design par étape
### Welcome
- Illustration hero (format vectoriel).
- Bouton primaire «Créer mon compte», bouton ghost «J ai déjà un compte».
- Indicateur progression (1/6) en bas pour set expectations.

### Création compte
- Formulaire vertical, validation inline, bouton «Continuer» inactif tant que champs incomplets.
- Lien CGU + Politique confidentialité.
- Message d erreur contextualisé (ex: mail déjà utilisé).

### Setup wizard
- Barre de progression horizontale (KhodanStepIndicator).
- Step navigation possible (précédent/suivant) pour révision.
- Step 2 : cartes sélection avec pictogrammes espèces.
- Step 4 : champ email + dropdown rôles (Admin, Technicien, Observateur).

### Import données
- Section cartes : «Importer CSV», «Importer via API (bientôt)», «Saisie manuelle».
- Statut upload (spinner, success state).
- Aide : lien vers doc import.

### Tutoriel
- Carrousel auto (3 secondes) mais contrôlable manuellement.
- Indicateurs (dots), bouton passer en haut à droite.

## 5. Assets et livrables
- Maquettes Figma haute fidélité (desktop + mobile).
- Illustrations : 1 hero + 3 pictos (élevage, données, collaboration).
- Modèle CSV (Google Sheet) à lier dans doc import.
- Texte marketing validé par PO.

## 6. Composants à utiliser
- Boutons `KhodanPrimaryButton`, `KhodanSecondaryButton`, `KhodanGhostButton`.
- `KhodanStepIndicator` (à développer, story dans backlog).
- `KhodanCard` pour options import.
- `KhodanTag` version info pour highlight tips.

## 7. Accessibilité
- Contrastes 4.5 minimum, taille de police >=16.
- Navigation clavier (web) et focus visible.
- Localisation : prévoir textes internationalisables (FR/EN).

## 8. Notes implementation dev
- Activer wizard via GoRouter (pré-auth) -> route `/onboarding`.
- Stocker progression dans supabase profile (champ `onboarding_completed`).
- Import CSV : upload -> storage supabase + table staging.

## 9. Actions immédiates
1. Designer: produire les maquettes pour chaque écran + interactions.
2. Rédiger contenus (microcopy) et valider avec product.
3. Créer template CSV + documentation import.
4. Synchroniser avec dev pour planifier taches `028_ImplFluxOnboarding`.
