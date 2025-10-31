# Tache 18 - Donnees de test et controle qualite

## Objectif
Preparer des donnees de demonstration et une check-list de tests pour assurer la stabilite avant la mise en ligne.

## Sous-taches
1. Rediger `docs/qa-checklist.md` avec trois parties: (a) tests automatiques (commandes `flutter test`, `dart test`, etc.), (b) scenarios manuels par module (tableau de bord, eleveurs, portees, finances, ventes), (c) validation finale Supabase.
2. Creer un script SQL `supabase/seeds/demo_data.sql` qui insere des eleveurs, portees, transactions et annonces fictives. Ajouter des instructions dans le fichier pour expliquer comment l'executer via l'editeur SQL si le CLI est bloque.
3. Ajouter dans Flutter un mode "Demo" qui charge les donnees seeds quand on est sur un environnement de test (variable `.env`).
4. Mettre a jour la documentation `README.md` ou un nouveau fichier `docs/setup-demo.md` pour expliquer pas a pas comment (a) vider la base de test, (b) appliquer les migrations, (c) charger les seeds, (d) lancer l'application.
5. Ecrire une procedure pour verifier les notifications (envoyer un message test, voir qu'il arrive).
6. Valider que tous les tests automatiques passent (CI locale ou commande). Noter les commandes exactes a lancer dans le doc.

## Livrables
- `docs/qa-checklist.md` et `docs/setup-demo.md` (ou mise a jour du README).
- Script `supabase/seeds/demo_data.sql`.
- Mode demo dans Flutter.
- Captures d'ecran ou note confirmant l'execution des tests.

## Notes
- Toujours avertir avant d'executer le script seeds sur une base de production (afficher un gros message dans le doc).
- Garder un langage accessible ("Clique sur...", "Ouvre...").
- S'assurer qu'aucun avertissement n'apparait apres avoir active le mode demo.
