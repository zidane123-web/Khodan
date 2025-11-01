# Tache 12 - Module rapports et statistiques

## Objectif
Assembler les ecrans de rapports pour suivre reproduction, croissance et finances comme dans Everbreed, avec des textes simples en francais.

## Sous-taches
1. Rediger dans `docs/rapports-spec.md` une fiche claire (sections: reproduction, croissance, finances) avec la liste des indicateurs, la formule a appliquer et un exemple chiffre par section.
2. Verifier les tables Supabase existantes, puis creer les vues ou fonctions necessaires (par ex. `view_reports_reproduction`, `fn_finance_resume`). Si le CLI bloque, utiliser l'editeur SQL Supabase et ensuite copier la requete dans un fichier `supabase/migrations/<date>_reports.sql` pour garder une trace.
3. Mettre a jour le backend Flutter/Dart pour lire ces vues (service ou repository) avec un code simple et des commentaires courts quand c'est utile.
4. Construire l'ecran Flutter `ReportsPage` avec trois onglets (ou segments) et des cartes qui affichent les chiffres, un petit graphique (barres ou lignes) et un bouton `Exporter CSV`.
5. Ajouter un export CSV/Excel cote Flutter (utiliser la librairie deja presente si disponible, sinon `csv`) et documenter le processus dans le spec.
6. Ecrire au moins un test de service pour chaque indicateur cle (verifie les calculs) et un test widget qui s'assure que les onglets changent bien les donnees.

## Livrables
- `docs/rapports-spec.md`.
- Migrations Supabase (ou scripts SQL plus migration) et code Flutter pour les rapports.
- Tests automatiques passes.

## Notes
- Utiliser des phrases courtes dans l'application pour aider les debutants.
- Pas d'avertissement Flutter ou TypeScript quand la tache est terminee.
- Bien rappeler dans le spec comment saisir les scripts dans l'editeur SQL si la connexion locale echoue.
