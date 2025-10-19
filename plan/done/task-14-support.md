# Support, diagnostics et base de connaissances

## Objectif
- Remplacer les placeholders `SettingsKnowledgeBaseScreen`, `SettingsContactSupportScreen`, `SettingsLogsScreen` par des sections utiles aux eleveurs.
- Offrir un acces offline a une base de connaissances (articles markdown stockes dans Supabase Storage ou table dediee).
- Donner la possibilite d'exporter les journaux (sync history, erreurs API, diagnostics appareil) pour transmission au support.

## Livrables
- Implementation d'une liste d'articles (avec recherche) et d'un viewer Markdown (utiliser `flutter_markdown`).
- Formulaire de contact support envoyant soit un email pre-rempli, soit un ticket dans une table Supabase `support_requests`.
- Module de collecte des logs (agrégation des entrees `SyncHistoryCubit`, traces errors) avec export fichier ou partage.

## Notes techniques
- Prevoir un fallback offline pour la base de connaissances (mise en cache locale).
- Sanitiser les contenus Markdown et gerer les liens/media externes avec prudence.
- Ajouter des toggles dans Settings pour activer un mode debug (collecte logs detaillee).
