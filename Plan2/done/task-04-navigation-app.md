# Tâche 04 - Repenser la navigation Flutter (desktop & mobile)

## Objectif
Mettre en place une structure de navigation inspirée d’Everbreed (barre latérale sur grand écran, barre inférieure ou menu sur mobile) sans casser l’application existante.

## Sous-tâches
1. Analyser `lib/app/config/router.dart` et les widgets de navigation actuels pour comprendre l’existant.
2. Créer un document `docs/navigation-khodan.md` décrivant :
   - Les écrans cibles.
   - La disposition souhaitée (barre latérale sur tablette/web, barre inférieure + bouton flottant sur mobile).
   - Les routes et noms d’icônes/textes en français.
3. Mettre à jour progressivement les widgets de navigation :
   - Introduire un composant commun (ex. `KhodanShell`) qui gère les deux modes (responsive).
   - Veiller à ce que chaque route affiche un écran placeholder lisible lorsqu’il n’est pas encore implémenté.
4. Tester dans l’émulateur et dans la version web (`flutter run -d chrome`) pour vérifier l’absence d’avertissements/erreurs.
5. Documenter dans le fichier la combinaison de touches / commandes pour lancer ces tests afin que la prochaine tâche puisse s’appuyer dessus.

## Livrables
- Documentation `docs/navigation-khodan.md`.
- Code Flutter mis à jour avec la navigation responsive (avec placeholders).

## Notes
- Toujours utiliser des textes français dans l’UI.
- En cas d’avertissement ou d’erreur de compilation, les corriger avant de finaliser la tâche.
