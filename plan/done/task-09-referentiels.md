# Referentiels especes & inventaire - plan detaille

La mise en place complete du module referentiels couvre trois chantiers consequents. Pour garder un rythme maitrise, on decoupe la tache 09 en sous-taches executees successivement.

## 09A - Gestion especes & modeles d'evenements (termine)
- Transformer SettingsReferentialsScreen en hub fonctionnel : liste des especes (species_config) et CRUD en modal/dialog.
- Gestion des templates d'evenements (event_templates) rattaches au profil courant (liste + creation/edition/suppression).
- Ajout des repositories/cubits necessaires, validations (valeurs positives, nom unique par profil, schema d'evenements non vide).
- Tests unitaires/widget assurant le bon enregistrement local + Supabase et la synchronisation hors-ligne.

## 09B - Inventaire aliments
- Modelisation Dart/Drift des tables food_types et food_stock, repositories synchronises et cubit d'inventaire.
- Interfaces Settings pour gerer types d'aliments et entrees de stock (quantite kg, cout, dates), avec validations (>=0, champs requis).
- Generation d'un resume reutilisable (quantite disponible, cout total, consommation estimee) expose via un provider/cubit.
- Tests couvrant l'inventaire (ajout, mise a jour, calculs de resume, synchro offline).

## 09C - Integration transversale
- Connexion des referentiels aux formulaires consommateurs : AnimalForm, AddEvent, AddBreedingRecord (selection especes, templates, aliments).
- Mise a jour du dashboard pour afficher le resume inventaire et les species avec metriques cles.
- Ajustement des seeds/migrations de test pour inclure exemples d'especes/templates/aliments.
- Tests de bout en bout (widgets/formulaires) garantissant l'utilisation des referentiels et l'absence de regressions.

> Prochaine etape : attaquer la sous-tache **09B** une fois les decisions de priorisation valides.


