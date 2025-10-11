# Notification service (Oct 2025)

- `lib/data/services/notification_service.dart` encapsule Firebase Messaging : permissions, token, topics.
- Prévoir intégration avec queue Supabase (`notifications_queue`) pour dispatch.
- TODO : brancher affichage local (flutter_local_notifications) et mapping des types (tâches 024/036).
