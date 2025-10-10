# Backlog priorise et jalonne (Oct 2025)

Ce document traduit les conclusions de l audit initial en epics, user stories et jalons temporels pour mener l application Khodan jusqu a la release production.

## Approche de priorisation
- **P0 (Bloquant)**: fonctionnalites indispensables a la proposition de valeur MVP et a la securite.
- **P1 (Critique)**: fonctionnalites completes pour une beta publique et la satisfaction utilisateur quotidienne.
- **P2 (Confort)**: optimisations, automatisations et contenus differenciants planifies post-lancement.

## Epic backlog

| Epic | Priorite | Description | Stories clefs (extraits) |
| --- | --- | --- | --- |
| Design System & Composants | P0 | Formaliser une identite visuelle coherent et industrialiser les widgets Flutter. | DS-01 Definir palette/typo, DS-02 Documenter composants, DS-03 Storybook interne |
| Onboarding & Activation | P0 | Faciliter la creation de compte, ferme et import initial. | ONB-01 Wizard onboarding, ONB-02 Import CSV animaux, ONB-03 Tutoriel interactif |
| Authentification Avancee | P0 | Secuser l acces et completer les parcours auth. | AUTH-01 Signup email, AUTH-02 Reset password, AUTH-03 MFA OTP |
| Gestion Animaux | P0 | Offrir gestion complete (liste, fiche, actions). | ANM-01 Filtre liste, ANM-02 Fiche multi onglets, ANM-03 Actions batch |
| Reproduction & Evenements | P0 | Suivre cycles et taches critiques. | BRE-01 Timeline reproduction, EVT-01 Hub evenements, EVT-02 Rappels planifies |
| Finances & Stocks | P1 | Suivre ventes, depenses, inventaire et tresorerie. | FIN-01 Saisie vente, FIN-02 Factures PDF, STK-01 Mouvement stock |
| Notifications & Alertes | P1 | Prevenir utilisateurs des evenements critiques. | NOT-01 Service FCM, NOT-02 Centre notifications, NOT-03 Preferences par canal |
| Mode Offline & Sync | P1 | Garantir l usage offline et la resolution de conflits. | OFF-01 Cache drift, OFF-02 Sync incremental, OFF-03 Resol conflits |
| Rapports & Exports | P1 | Fournir KPIs, exports CSV/PDF et dashboards visuels. | RPT-01 Rapports productivite, RPT-02 Export CSV, RPT-03 Charts interactifs |
| Roles & Equipe | P1 | Administrer membres, roles et permissions. | ROL-01 Invitation membre, ROL-02 Role manager, ROL-03 Guard navigation |
| Observabilite & Qualite | P0 | Mettre en place tests, CI/CD, monitoring. | QA-01 Tests unitaire data, QA-02 Tests widget, QA-03 Pipeline CI |
| Internationalisation & Accessibilite | P2 | Preparer i18n et conformité accessibilite. | I18N-01 Ajout ARB FR/EN, A11Y-01 Audit contrastes |
| Marketing & Support | P2 | Fournir assets stores et base de connaissance. | MKT-01 Captures store, SUP-01 FAQ Notion |

## User stories prioritaires (details)

### MVP (Priorite P0)
- **DS-01**: En tant que designer, je definis un theme global pour garantir une experience coherent entre ecrans. *Accepte si palette, typo et composants de base sont documentes.*
- **ONB-01**: En tant que nouvel eleveur, je complete un wizard pour configurer ma ferme et mes preferences. *Accepte si wizard multi etapes fonctionne sur mobile/web.*
- **AUTH-01**: En tant qu utilisateur, je cree un compte avec email/mot de passe et recois un email de verification. *Accepte si validation champs + retours erreurs.*
- **AUTH-02**: En tant qu utilisateur, je reinitialise mon mot de passe via email securise. *Accepte si token expirable et feedback clair.*
- **ANM-01**: En tant qu eleveur, je filtre la liste d animaux par statut, sexe et tag. *Accepte si filtres persistants et pagination.*
- **ANM-02**: En tant qu eleveur, j accede a la fiche detaillee d un animal avec historique reproduction et sante. *Accepte si sections datas temps reel.*
- **BRE-01**: En tant que responsable reproduction, je visualise une timeline des evenements passes/futurs. *Accepte si calcul automatique dates gestation.*
- **EVT-01**: En tant qu equipe terrain, je cree et assigne des evenements avec rappels. *Accepte si push notification planifiee et mise a jour offline.*
- **QA-01**: En tant que dev, je lance `flutter test` et obtains >=80% couverture data/domaine. *Accepte si pipeline local succeed.*
- **QA-03**: En tant que dev, je push et CI execute l analyse, tests et build smoke. *Accepte si pipeline GitHub Actions status OK.*
- **SEC-01** (derive audit): En tant qu admin, je proteges secrets Supabase via env et policies RLS minimales. *Accepte si `.env` remplace `info` et policies basiques en place.*

### Beta publique (Priorite P1)
- **FIN-01**: En tant que comptable, j enregistre une vente et associe l animal concerne. *Accepte si validation double entree.*
- **FIN-02**: En tant que gestionnaire, je genere un PDF facture partageable. *Accepte si template PDF conforme.*
- **STK-01**: En tant que responsable stock, je saisis consommation aliments et suis alertes sur seuil. *Accepte si notifications declenchees.*
- **NOT-01**: En tant qu utilisateur, je recois une notification push quand un rappel d evenement approche. *Accepte si test FCM reussi.*
- **OFF-01**: En tant que terrain, je consulte mes donnees animaux offline. *Accepte si lecture en mode avion.*
- **ROL-01**: En tant qu admin, j invite un membre et lui attribue un role. *Accepte si email invitation et enforcement RLS.*
- **RPT-01**: En tant que dirigeant, je consulte le rapport productivite par periode. *Accepte si filtres et export CSV actifs.*

### Post-release (Priorite P2)
- **I18N-01**: En tant qu utilisateur anglophone, je vois l application en EN. *Accepte si toggle langue et ARB complet.*
- **A11Y-01**: En tant qu utilisateur malvoyant, j utilise lecteur ecran. *Accepte si labels semantics et contrastes valides.*
- **MKT-01**: En tant que marketing, je dispose des assets store conformes. *Accepte si kit complet image/video.*

## Jalons proposes

| Jalons | Horizon | Contenu cle | Critere de sortie |
| --- | --- | --- | --- |
| **MVP Interne** | Semaine 0-8 | Epics Design System, Auth basique, Animaux, Reproduction de base, Tests/CI, Policies RLS minimales | 100% stories P0 livrees, couverture tests >=80%, secrets securises |
| **Beta Publique** | Semaine 9-16 | Finances & Stocks, Notifications, Offline, Rapports V1, Roles, Import initial | Feedback utilisateurs terrain positifs, KPI retention >70%, documentation support dispo |
| **Release Production** | Semaine 17-22 | Optimisations performance, Accessibilite, Internationalisation, Automatisation CI/CD, Marketing assets | App publishee stores, pipeline deploy prod automatique, monitoring (Sentry, analytics) actif |

## Dependencies et jalons techniques
- **Schema Supabase complet** a finaliser avant jalon MVP -> taches `017` a `019`.
- **Services notifications** necessaires avant Beta -> taches `024` a `036`.
- **CI/CD** doit proteger tous merges -> taches `038` a `043`.

## Actions immediates
1. Creer les epics et stories ci dessus dans l outil de gestion (Jira/Linear) avec etiquettes P0/P1/P2.
2. Assigner proprietaires pour epics P0 (design lead, lead dev backend, lead mobile) et fixer estimations initiales.
3. Synchroniser ce backlog lors du kick-off prochain sprint pour validation et ajustements capacitaires.
