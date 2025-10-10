# Audit produit et technique initial (Oct 2025)

## Methodologie
- Lecture des sources principales (`lib/`, `pubspec.yaml`, `analysis_options.yaml`) et du routeur `lib/app/config/router.dart`.
- Inspection des ressources Supabase (`supabase/migrations`, fichier `info`) pour comprendre l etat du backend.
- Inventaire rapide des modules Flutter existants et verifications ponctuelles des ecrans/logiciels (`features/animals`, `features/events`, `features/dashboard`, `features/auth`).
- Verification de la presence de tests, outils de CI et documentation active.

## Synthese executive
- L application dispose d un socle Flutter structurant (GoRouter, Bloc, modularisation par features) couvrant authentification basique, animaux, evenements, rapports et parametres.
- Aucun test automatise n est present (`test/` absent) et aucun pipeline CI/CD n est configure, rendant la qualite non garantie.
- Le backend Supabase ne contient qu une migration partielle (inventaire, event templates) et expose l anon key directement dans le repo via le fichier `info`, ce qui constitue un risque de securite.
- De nombreux modules strategiques sont encore a l etat d intentions (finances, stocks avances, notifications temps reel, offline concretes, onboarding) et aucun design system formel n est livre.

## Couverture fonctionnelle actuelle (UI/UX)
- **Authentification**: `AuthCubit`, ecrans `SplashScreen` et `LoginScreen` integres au router; flux limite a login email/password, sans MFA ni reset complet.
- **Dashboard**: ecran `DashboardScreen` existant; widgets KPI partiellement implements, logique oriente demo (necessite validation metier).
- **Animaux**: module riche (`AnimalListScreen`, `AnimalDetailScreen`, `forms/`), repositories et modeles (`animal.dart`, `breeding_record.dart`) deja present.
- **Evenements & reproduction**: hub `EventsHubScreen`, formulaires de breeding (`breeding_record_form.dart`, `batch_event_form_dialog.dart`) et cubit associe.
- **Rapports**: ecran `ReportsScreen` avec widgets (ex. `productivity_report_screen.dart`) mais sans integration data temps reel.
- **Parametres**: ecran `SettingsScreen`, cubit `OfflineCubit` rudimentaire, pas de veritable gestion offline.
- **Services communs**: theming (`app/config/theme.dart`), navigation shell, widgets de base (`khodan_primary_button`).

## Lacunes fonctionnelles majeures
- Onboarding utilisateur, creation de ferme, import de donnees inexistants.
- Modules finances, stocks avances, facturation, tresorerie non implementes malgre dependances declarees (drift, fl_chart, pdf...).
- Centre de notifications et alertes critiques absent (aucun service FCM ni ecran dedie).
- Mode offline reel non realise: presence de dependances (drift, connectivity_plus) mais aucun schema/DAO.
- Gestion d equipe, roles, permissions juste amorcee (pas de repository profiles, pas de guard router).
- Reporting avance (exports PDF/CSV, filtres complexes) non present.

## Qualite du code et architecture
- Architecture featurisee avec pattern Bloc/Cubit, mais absence de separation claire domaine/data; logique metier reste dans Cubits ou UI.
- Pas de gestion multi-environnements: `AppConstants` depend de `--dart-define`, mais aucun outillage `.env` ou script.
- Lints par defaut `flutter_lints`; aucune regle additionnelle (immuabilite, pedantic) pour renforcer la qualite.
- Plusieurs fichiers volumineux (>20k lignes pour certains formulaires) suggerent besoin de refactorisation/modularisation.
- Encodage accentue degrade (caracteres remplaces) dans migrations et certains labels UI -> pipeline i18n absent.

## Backend & donnees (Supabase)
- Une seule migration `add_features_tables` definissant des tables `event_templates`, `food_types`, `food_stock` et une colonne `health_status`.
- RLS active uniquement sur les nouvelles tables; les tables principales (animals, breeding_records) ne sont pas presentes dans les migrations -> schema incomplet / non versionne.
- Aucune function, trigger ou RLS avance pour restreindre l acces multi-fermes.
- Le fichier `info` expose l URL et l anon key Supabase, sans rotation ni secret management -> risque compromission environnement.

## Securite & conformite
- Supabase anon key committe, potentiellement re-utilisable; absence de mention RGPD/CGU.
- Pas de gestions de secrets pour builds CI/CD, ni de chiffrement local pour mode offline.
- Navigation n implemente pas de guard par role; tout utilisateur authentifie accede a tous les modules.

## Qualite, tests et outillage
- Dossier `test/` absent -> couverture 0 %, pas de golden tests, pas d integration.
- Aucun script de verification (Makefile, melos) ni pipeline CI/CD.
- Documentation limitee (`README.md` minimal, aucune doc fonctionnelle/tech).

## Risques prioritaires
1. **Absence de tests et CI** -> forte probabilite de regression lors des prochains ajouts.
2. **Secrets exposes / RLS incomplet** -> risque securite majeur et fuite donnees clients.
3. **Fonctionnalites metier critiques manquantes** (finances, notifications, onboarding) bloquent valeur produit.
4. **Schema Supabase non versionne completement** -> difficultes de deploiement coordonne et incoherences entre environnements.
5. **Dette UX/UI**: pas de design system, incoherences potentielles et accessibilite non adresse.

## Recommandations immediates
- Lancer la tache `002_DefinirBacklogPriorise` pour transformer cet audit en backlog priorise et jalonne.
- Mettre en place rapidement une strategie de gestion des secrets (remplacer le partage dans `info`, introduire `.env` chiffrable).
- Demarrer l ecriture de tests sur les modules existants, en commencant par les repositories critiques (auth, animals).
- Versionner le schema Supabase complet en regenrant les migrations depuis l instance actuelle.
- Formaliser le design system et planifier la reduction des gros widgets en composants reutilisables.
