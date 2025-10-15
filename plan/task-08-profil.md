# Gestion du profil elevage

## Objectif
- Remplacer les placeholders `SettingsProfileScreen`, `SettingsContactSupportScreen`, `SettingsAboutScreen` par des ecrans fonctionnels relies au backend.
- Permettre la mise a jour des informations elevage (nom, localisation, coordonnees, preferences legales) et garder un historique minimal.
- Offrir un acces rapide aux informations d'abonnement / facturation si necessaire (placeholder pour futur module).

## Livrables
- Formulaires complets sur les ecrans Settings avec validation, et integration au repository (ex. `ProfilesRepository` a creer).
- Synchronisation des donnees locales (Drift) pour afficher les informations meme offline.
- Tests widget couvrant la sauvegarde d'un profil et la reaffectation des valeurs recues du backend.

## Notes techniques
- Clarifier quelles donnees resident dans Supabase (`profiles` table) vs locales (preferences UI).
- Prevoir la gestion des erreurs (ex. email deja pris) avec retours utilisateur clairs.
- Ajouter une section "A propos" listant version de l'app, commit git, et liens legaux (CGU, politique de confidentialite).
