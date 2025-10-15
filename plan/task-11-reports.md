# Rapports et exports professionnels

## Objectif
- Alimenter `ReportsScreen` et `ProductivityReportScreen` avec des donnees verifiees venant du backend (breeding records, events, inventaire).
- Offrir des exports PDF/CSV partageables (via `printing` et `share_plus`) avec un rendu soigne (logos, mise en forme lisible).
- Introduire des filtres supplémentaires (periode libre, filtre par lot, filtrage geographique) conformes aux besoins metiers.

## Livrables
- Services aggregeant les donnees (coté Flutter ou via RPC) et actualisant les graphiques `fl_chart`.
- Generation PDF reworkee: gabarit reutilisable, tests visuels (captures) et export CSV (utiliser `ListToCsvConverter` ou similaire).
- Documentation utilisateur courte (dans l'app ou README) expliquant comment generer et partager les rapports.

## Notes techniques
- Attention aux locales: formatage dates/nombres doit utiliser `intl` et les locales chargees.
- Gerer les cas de donnees partielles (ex. absence de poids ou weaning) sans crasher les graphiques.
- Prevoir une strategie de cache pour ne pas recalculer integralement les metriques a chaque navigation.
