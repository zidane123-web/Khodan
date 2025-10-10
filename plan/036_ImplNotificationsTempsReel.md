# Implementer les notifications temps reel

## Objectif / But
Brancher le service de notifications aux modules metiers et assurer la reception sur toutes les plateformes.

## Etapes concretes
- Relier les evenements (reproduction, stocks, finances) aux triggers envoyant notifications.
- Implementer le centre de notifications in-app avec historique et filtres.
- Gerer les scenarios offline/online et la relecture des notifications non lues.
- Tester les notifications sur Android, iOS et Web.
- Documenter les procedures d abonnement/desabonnement.

## Fichiers ou modules concernes
- `lib/features/notifications`
- `supabase/functions`
- `plan/024_ImplServiceNotifications.md`

## Resultat attendu / Critere de reussite
- Notifications temps reel fiables et observees sur tous les canaux planifies.

## Prerequis eventuels
- 035_ImplFinancesEtStocks.md

