# Task 22 - Nettoyer l'encodage et les chaines (UTF-8)

## Objectif
- Supprimer les caracteres corrompus (`�`, `Ǹ`, etc.) visibles dans l'application et les fichiers de config.
- S'assurer que tous les fichiers Dart/YAML/Markdown utilisent UTF-8 sans BOM.
- Harmoniser les traductions ARB et regenerer les localisations propres.

## Livrables
- Commit nettoyant `pubspec.yaml`, fichiers l10n, textes statiques et README.
- Regeneration `flutter gen-l10n` verifiee (sans warning).
- Checklist documentee pour prevenir les regressions d'encodage.

## Etapes
1. Identifier les fichiers touches (ex: `pubspec.yaml`, contenu plan/done, README, ARB).
2. Reenregistrer en UTF-8 via l'IDE ou `iconv`, puis corriger les chaines degradees manuellement.
3. Regenerer les localisations (`flutter gen-l10n`) et executer `flutter analyze` pour valider.
4. Verifier dans l'app (debug) que les ecrans affichent bien les accents/lettres specifiques.
5. Ajouter une note dans `CONTRIBUTING` ou `README` pour rappeler la configuration d'encodage.

## Dependances
- Aucun pre-requis technique hormis un `flutter pub get` a jour.
- Idealement realiser avant les validations UI finales (Tasks 20 et 21).

