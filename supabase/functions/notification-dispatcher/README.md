# Notification Dispatcher

Edge function skeleton that pulls queued notifications from `public.notifications_queue` and logs them.

## Deployment notes
- Configure environment variables `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, and providers credentials (FCM, Sendgrid...).
- Schedule via Supabase cron (e.g. every minute) once providers are plugged in.
- Extend `fetchQueuedNotifications` and `markProcessed` to include push/email dispatch logic.
