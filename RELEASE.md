# Guide de release

Ce projet suit un cycle de release simple qui garantit la qualité de l’application Flutter et la cohérence des livrables.

## Préparation
- Mettre à jour `pubspec.yaml` (`version:`) selon le SemVer (MAJOR.MINOR.PATCH).
- Vérifier que les traductions sont à jour (`lib/l10n/*.arb`) et exécuter `flutter gen-l10n`.
- Lancer le script de contrôle qualité :  
  - macOS/Linux : `tool/check_quality.sh`  
  - Windows : `pwsh tool/check_quality.ps1`
- S’assurer que les branches Git sont synchronisées (merge/rebase) et que le changelog est actualisé.

## Construction des artefacts
- Android : `flutter build apk --release` puis, si nécessaire, `flutter build appbundle --release`.
- iOS : `flutter build ipa --release` (depuis macOS avec Xcode configuré).
- Web (optionnel) : `flutter build web`.
- Vérifier les exports diagnostics/logs sur les plateformes cibles.

## Distribution
- Android : publier l’APK/AAB sur Google Play Console ou Firebase App Distribution.
- iOS : distribuer via TestFlight/App Store Connect.
- Web : déployer sur l’hébergement choisi (Firebase Hosting, S3, etc.).

## Post-release
- Taguer la release (`git tag vX.Y.Z`) et pousser le tag.
- Archiver les artefacts si requis et informer les utilisateurs internes.
- Planifier la prochaine itération (tickets, feedback, dettes techniques).
