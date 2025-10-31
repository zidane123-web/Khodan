# Navigation Khodan

## Synthèse
- Référence principale : analyse Everbreed (`Khodan.docx` + captures) observée le 30/10/2025.
- Objectif : offrir une expérience cohérente bureau/mobile, inspirée d'Everbreed mais adaptée au contexte Khodan (élevages africains, terminologie française).
- Architecture Flutter : `go_router` avec `StatefulShellRoute` et shell responsive `KhodanShell`.

## Écrans cibles (ordre latéral / barre inférieure)
- **Tableau de bord** : indicateurs du cheptel, actions rapides, alertes (Roadmap Phase 1).
- **Éleveurs** (`animals`) : liste filtrable, fiches détaillées, import CSV.
- **Portées & cages** (`events` aujourd'hui, module dédié Phase 1) : gestion des portées, cages, rappels.
- **Planning** : agenda + liste des tâches (Everbreed Schedule).
- **Rapports** : exports et statistiques (already `reports`).
- **Notifications** (future badge) : suivi des alertes critiques.
- **Paramètres** : profil, personnalisation, référentiels, support.
- **Centre d'aide** (Everbreed Knowledge Base) : accessible depuis Paramètres ou futur onglet dédié.
- **Administration** (option premium ultérieure) : gestion d'équipe, permissions.

Modules marqués comme « futur » restent en placeholder lisible jusqu'à implémentation.

## Disposition responsive
- **Breakpoint recommandé** : `>= 1024 px` → mode bureau ; `< 1024 px` → mode compact.
- **Bureau / Web** :
  - `NavigationRail` latérale fixe avec destinations principales (icônes + labels).
  - Header supérieur optionnel pour titre de page + actions contextuelles (déconnexion, recherche).
  - Contenu dans `Expanded` + `SafeArea`, largeur max 1360 px pour confort.
- **Mobile / Tablette compacte** :
  - `NavigationBar` inférieure avec 4 destinations principales.
  - Onglet « Plus » qui ouvre une `ModalBottomSheet` listant les modules secondaires.
  - `FloatingActionButton` contextuel (ex. `Ajouter une tâche` sur Planning, `Nouvelle portée`).
- **Tablette paysage (≥ 840 px et < 1024 px)** : `NavigationRail` compact + FAB latéral.

## Routes, labels et icônes

| Route GoRouter | Label (fr)             | Icône Material                    | Apparition |
| -------------- | ---------------------- | --------------------------------- | ---------- |
| `/dashboard`   | Tableau de bord        | `Icons.dashboard`                 | Rail + Bar |
| `/animals`     | Éleveurs               | `Icons.pets`                      | Rail + Bar |
| `/events`      | Portées & cages        | `Icons.volunteer_activism`        | Rail + Bar |
| `/planning`    | Planning               | `Icons.event_note`                | Plus / Rail |
| `/reports`     | Rapports               | `Icons.bar_chart`                 | Rail + Bar |
| `/notifications` | Notifications        | `Icons.notifications`             | Modal Plus |
| `/settings`    | Paramètres             | `Icons.settings`                  | Rail + Bar |
| `/settings/referentials` | Référentiels | `Icons.category`                  | Sous-menu  |
| `/settings/personalization` | Personnalisation | `Icons.palette`            | Sous-menu  |
| `/settings/profile` | Profil             | `Icons.person`                    | Sous-menu  |
| `/settings/support/knowledge` | Centre d'aide | `Icons.help`               | Sous-menu  |
| `/settings/support/contact` | Support     | `Icons.support_agent`             | Sous-menu  |
| `/settings/support/logs` | Journaux      | `Icons.history`                   | Sous-menu  |
| `/settings/support/about` | À propos     | `Icons.info`                      | Sous-menu  |

Remarques :
- `/events` héberge aujourd'hui `EventsHubScreen`; il affichera un placeholder « Portées & cages » tant que le module dédié n'est pas finalisé.
- Une route `/planning` est planifiée : placeholder initial jusqu'à implémentation du module Planning.
- Les routes futures (`/notifications`, `/admin`) seront préparées mais masquées tant qu'aucune fonctionnalité n'est disponible.

## Interaction mobile
- `NavigationBar` affiche : Tableau de bord, Éleveurs, Portées & cages, Rapports, Paramètres.
- Bouton FAB central (mobile) : action par défaut contextualisée (ex. `Nouvel évènement`).
- Menu « Plus » (icône `Icons.more_horiz`) dans la barre inférieure pour accéder à Planning, Notifications et Centre d'aide.

## Placeholders attendus
- `DashboardScreen` reste la vue actuelle, à rafraîchir plus tard.
- Nouvelles pages placeholder (`PlanningScreen`, `NotificationsScreen`, etc.) utilisent `Scaffold` + icône + texte d'attente (« Écran en préparation »).
- Les placeholders doivent être accessibles via tests et ne pas générer d'avertissements analytiques.

## Commandes utilisées
- `flutter pub get`
- `flutter gen-l10n`
- `flutter analyze`
- `flutter emulators` / `flutter emulators --launch Medium_Phone_API_36.0`
- `flutter devices`
- `flutter run -d mznrrgee6ls4sgtc --no-resident` (émulateur Android : OK, build + sync terminés)
- `flutter run -d chrome --no-resident` (échoue : dépendances `drift/sqlite3` importent `dart:ffi` non supporté sur web)

Document mis à jour le 31/10/2025.
