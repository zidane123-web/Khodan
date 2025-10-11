# Sync Coordinator (Oct 2025)

- `lib/data/services/sync_coordinator.dart` : service regroupant abonnements realtime Supabase.
- Diffuse `RealtimeMessage` via StreamController broadcast.
- TODO : ajouter persistance locale (Drift) et file d attente pour mode offline (tâche 023).
- Prévoir tests d intégration avec canal Supabase mocké.
