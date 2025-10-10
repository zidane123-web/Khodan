# Implementer le service de notifications

## Objectif / But
Construire la couche de service envoyant et recevant les notifications push et in-app.

## Etapes concretes
- Configurer Firebase Cloud Messaging et lier les tokens utilisateurs dans Supabase.
- Coder un service Dart encapsulant l initialisation FCM, la gestion des permissions et des topics.
- Relier les triggers Supabase ou edge functions a l envoi de notifications.
- Implementer la persistence locale des notifications pour le centre in-app.
- Tester l envoi sur Android, iOS et Web (si supporte).

## Fichiers ou modules concernes
- `lib/data/services/notification_service.dart (a creer)`
- `lib/features/notifications`
- `supabase/functions`

## Resultat attendu / Critere de reussite
- Service de notifications multi-plateforme operationnel et documente.

## Prerequis eventuels
- 023_ConfigurerServicesSync.md

