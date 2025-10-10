# Composants UI Khodan

Ce document référence les composants Flutter implémentés dans `lib/app/core/widgets` et sert de mémo rapide pour les développeurs et designers.

| Composant | Fichier | Description | Etats couverts |
| --- | --- | --- | --- |
| `KhodanPrimaryButton` | `lib/app/core/widgets/khodan_primary_button.dart` | Bouton principal (FilledButton) avec option icône et largeur totale. | actif, désactivé (via `onPressed` null), danger via `KhodanDangerButton`. |
| `KhodanSecondaryButton` | `lib/app/core/widgets/khodan_primary_button.dart` | Bouton secondaire outline pour actions alternatives. | actif, désactivé. |
| `KhodanGhostButton` | `lib/app/core/widgets/khodan_primary_button.dart` | Bouton ghost pour actions tertiaires. | actif, désactivé. |
| `KhodanDangerButton` | `lib/app/core/widgets/khodan_primary_button.dart` | Bouton d action destructive avec couleur d alerte. | actif, désactivé. |
| `KhodanCard` | `lib/app/core/widgets/khodan_card.dart` | Carte avec en-tête optionnel (leading, trailing), corps et pied de page. | standard, avec footer. |
| `KhodanTag` | `lib/app/core/widgets/khodan_tag.dart` | Etiquette statutaire (info/success/warning/danger) avec icône optionnelle. | info, success, warning, danger. |

Pour toute nouvelle contribution :
1. Documenter ici le composant.
2. Ajouter un exemple d usage dans la page de démonstration (à créer).
3. Couvrir le composant via tests widget/golden selon criticité.
