# Referentiels especes et gestion d'inventaire

## Objectif
- Donner vie a `SettingsReferentialsScreen` en permettant de CRUD les species config (gestation, sevrage, schema evenements) et de gerer les modeles d'evenement (`event_templates`).
- Integrer les tables `food_types` et `food_stock` ajoutees par la migration actuelle pour suivre le stock d'aliments.
- Synchroniser ces referentiels avec les ecrans qui les consomment (AnimalForm, AddEvent, AddBreedingRecord).

## Livrables
- Nouveaux Cubits/Repositories (ex. `SpeciesCubit`, `InventoryCubit`) et widgets de liste/edition.
- Validation des formulaires (valeurs positives, champs obligatoires) et affichage des erreurs backend.
- Tests widget/unitaires verifiant la bonne propagation des mises a jour vers les ecrans de creation d'animaux/evenements.

## Notes techniques
- Anticiper la multi-espece: les species doivent etre filtrees par profil et selectionnables dans les formulaires.
- Pour l'inventaire, fournir un resume (quantite restante, cout, consommation estimee) reutilisable dans le dashboard.
- Mettre a jour les seeds/migrations pour disposer d'exemples pertinents lors des tests.
