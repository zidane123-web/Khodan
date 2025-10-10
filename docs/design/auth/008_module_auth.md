# Module d authentification Khodan (Oct 2025)

Ce document reference les écrans, contenus et interactions du module d authentification pour la tâche 008.

## 1. Objectifs
- Assurer une expérience sécurisée et fluide pour l inscription, connexion et récupération de compte.
- Préparer l intégration MFA OTP et les futures options SSO.
- Couvrir les états d erreurs fréquents (identifiants invalides, compte inactif, réseau indisponible).

## 2. Parcours utilisateur

1. **Écran Splash (exist.)**
   - Détecte session supabase. Sinon redirige `/auth/login`.

2. **Login**
   - Champs email, mot de passe.
   - Bouton primaire «Se connecter», lien «Mot de passe oublié?», CTA «Créer un compte» (-> onboarding step).
   - Option alternative (SSO boutons) désactivée pour l instant mais visible (grisée) + tooltip «Bientôt disponible».

3. **Inscription**
   - Form: prénom, nom (optionnel), email, mot de passe, confirmation.
   - Checkbox acceptation CGU/Politique.
   - Message sécurité : «Mot de passe ≥ 8 caractères, 1 majuscule, 1 chiffre».
   - CTA secondaire retour login.

4. **Vérification email**
   - Texte confirmant l envoi d un email.
   - Bouton «Ouvrir mon courrier» (mailto), bouton ghost «Renvoyer email».
   - Option contact support.

5. **Reset mot de passe (request)**
   - Champ email, CTA principal «Envoyer lien de réinitialisation».
   - Confirmation inline.

6. **Reset mot de passe (confirm)**
   - Champs nouveau mdp + confirmation.
   - Validation règles mot de passe.

7. **MFA OTP (Phase suivante)**
   - Écran code 6 digits, possibilité renvoi.
   - Option «Sécuriser plus tard» si politique le permet (stockage device).

## 3. Composants design
- `KhodanCard` pour encapsuler formulaires.
- `KhodanPrimaryButton`, `KhodanSecondaryButton`, `KhodanGhostButton`.
- `KhodanTag` variant warning pour messages caution.
- Champ `KhodanFormField` (à développer) avec icône suffixe pour afficher mdp.

## 4. Contenus & micro-copy
- Texte login : «Content de vous revoir!»
- Texte signup : «Créez votre compte pour gérer votre élevage.»
- Erreurs :
  - `invalid_credentials`: «Email ou mot de passe incorrect.»
  - `user_not_confirmed`: «Validez votre email pour accéder à Khodan.»
  - `rate_limited`: «Trop de tentatives. Patientez quelques instants.»
- Tooltip SSO : «Connexion Google/Microsoft disponible prochainement.»

## 5. Accessibilité
- Alternatives visuelles pour erreurs (icône + texte rouge).
- Navigation clavier complète, `autofillHints` actifs.
- Support mode sombre (future tache 042) : concevoir variations.

## 6. Sécurité
- Ne jamais stocker mot de passe localement.
- Utiliser `SupabaseAuth` + `flutter_bloc` pour gestion états.
- Prévoir Hook `onAuthStateChange` (déjà dans router) -> redirection.
- Logging minimal, pas de détails sensibles dans logs.

## 7. Livrables design
- Maquettes Desktop + Mobile des écrans listés.
- États : loading, error, disabled.
- Illustrations décoratives (facultatif) -> cohérence DS.
- Icône pour masquer/afficher mdp.

## 8. Stories techniques associées
- AUTH-01, AUTH-02 (signup/reset) P0.
- AUTH-03 (MFA) P1.
- QA : tests widget pour formulaires, tests integration pour authentification.

## 9. Prochaines étapes
1. Designer produit les maquettes et variantes.
2. PO valide micro-copies et règles mot de passe.
3. Dev préparer backlog `029_ImplAuthentificationComplete` avec découpage (UI + Backend + Tests).
