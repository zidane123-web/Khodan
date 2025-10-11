// supabase/functions/notification-dispatcher/index.ts
// Edge function skeleton to dispatch queued notifications through FCM/email.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

interface NotificationPayload {
  id: number;
  profile_id: string;
  type: string;
  title: string;
  body: string;
  metadata: Record<string, unknown>;
}

async function fetchQueuedNotifications(): Promise<NotificationPayload[]> {
  const response = await fetch(Deno.env.get("SUPABASE_URL") + "/rest/v1/notifications_queue?processed_at=is.null", {
    headers: {
      apikey: Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
  });
  if (!response.ok) {
    console.error("Unable to fetch notification queue", await response.text());
    return [];
  }
  return await response.json();
}

async function markProcessed(id: number) {
  await fetch(`${Deno.env.get("SUPABASE_URL")}/rest/v1/rpc/mark_notification_processed`, {
    method: "POST",
    headers: {
      apikey: Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ _id: id }),
  });
}

serve(async () => {
  const notifications = await fetchQueuedNotifications();

  for (const notification of notifications) {
    // TODO: plug actual push/email providers (FCM, Sendgrid...)
    console.log(`Dispatching notification ${notification.id}`, notification);
    await markProcessed(notification.id);
  }

  return new Response(JSON.stringify({ processed: notifications.length }), {
    headers: { "Content-Type": "application/json" },
  });
});
