# Notifications - Implementation Plan

Last updated: 2025-11-01 (Plan2 tache 09).

## Goals
- Provide reliable mobile reminders (Android / iOS) for template driven tasks and scheduled events.
- Prepare the extension to external channels (email, SMS) with a modular design.
- Document current limits and the manual configuration still required.

## Architecture
- **Flutter service `LocalNotificationService`**
  - Built on top of `flutter_local_notifications` and `timezone` for accurate scheduling.
  - Initialisation at app start: request iOS permissions, configure Android channel `planning_reminders` (importance high).
  - Public API:
    - `Future<void> scheduleTaskReminder({required String taskId, required DateTime triggerAt, required String title, String? body, List<NotificationHook> hooks})`
    - `Future<void> cancelTaskReminder(String taskId)`
    - `Future<void> rescheduleForTemplateUpdate(...)` (called when a template step changes).
  - Generates a deterministic integer key from `taskId` so reminders can be cancelled or rescheduled easily.
- **External hooks (`NotificationHook`)**
  - Abstract interface exposing `Future<void> dispatch(NotificationPayload payload)`.
  - Provided implementations:
    - `EmailNotificationHook` (stub) : insert a pending row in Supabase table `notifications_outbox` for an Edge Function.
    - `SmsNotificationHook` (stub) : same mechanism, future SMS gateway (Kkiapay/Feda).
  - Hooks are registered through `NotificationServiceRegistry` so the app can disable channels that are not configured.
- **Supabase persistence**
  - Table `notification_preferences` stores enabled channels per profile / user.
  - Table `notifications_outbox` keeps pending external reminders processed by a worker or Edge Function.
  - Local reminders do not depend on connectivity; when offline the app recomputes the schedule once tasks are created.
- **Planning integration**
  - When a template is applied, `TaskTemplateService` reads each step `notificationOffsets` and calls `LocalNotificationService.scheduleTaskReminder`.
  - Re-scheduled tasks update their reminder and mark the offline queue item as `pendingSync`.
  - Management screens expose toggles per task to enable or disable reminders.

## Limits and manual work
- Email and SMS sending are **not** implemented. Operators must:
  1. Deploy a Supabase Edge Function (not delivered here) that consumes `notifications_outbox`.
  2. Configure secrets such as `SENDGRID_API_KEY`, `TWILIO_API_KEY`, or local gateways.
- Users must open the mobile app at least once after installation to register channels. On web/desktop the service remains disabled because there is no native API.
- Time zones rely on the `timezone` package. Ensure `AppEnv` calls `initializeTimeZones()` before scheduling reminders.
- iOS requires explicit permission. If the user declines, reminders are ignored and the UI surfaces a banner "Notifications disabled".
- Database migrations only create the structure. Apply them through the Supabase SQL Editor (see `docs/supabase-execution-guide.md`) while the CLI stays unstable on Windows.

## Next steps
1. Implement an Edge Function `dispatch_notification` to send emails/SMS and update `notifications_outbox.status` (`sent` / `failed`).
2. Add a "Notification preferences" screen so each team member can select channels and quiet hours.
3. Centralise logs in a dashboard (audit of reminders sent, Twilio/SendGrid failures).
4. Add push notifications (Firebase Cloud Messaging) once the mobile apps ship.
