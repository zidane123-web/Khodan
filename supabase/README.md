# Supabase Security & Dashboard RPC Guide

This document summaries the RLS policies, automation helpers, and RPC entry points introduced in the security migration (`20251015113000_security_rls.sql`).

## Row Level Security
- Tables guarded: `profiles`, `species_config`, `animals`, `breeding_records`, `breeding_metrics`, `events`, `animal_events`, `sync_queue`.
- Every policy enforces `profile_id = auth.uid()` (or `id = auth.uid()` for `profiles`). The Supabase `service_role` keeps unrestricted access for backend jobs.
- `animal_events` policies traverse the parent `events` row to guarantee ownership inheritance.
- Timestamp triggers (`tg_maintain_timestamps`) keep `updated_at` fresh and silently skip no-op updates to remain offline-sync friendly.

### Manual verification
Run the following sequence against your project to validate the policies (replace `<project-ref>` with your Supabase ref):
```bash
supabase db reset --project-ref <project-ref>
supabase db remote commit --project-ref <project-ref>
```
Then, using two different authenticated users, ensure:
1. User A can create animals and events, and User B cannot read or mutate them.
2. Service-role scripts (Edge Functions or cron jobs) can still upsert `breeding_metrics`.

## Dashboard data access
Two helpers power the Flutter `DashboardCubit` with a single RPC call:

- **View** `public.dashboard_kpis`  
  Aggregates `breeding_metrics` with species names and champion animals. RLS on the base tables continues to apply.

- **Function** `public.get_dashboard_kpis`  
  Filters the view by `auth.uid()` and optional parameters:
  ```dart
  final response = await supabase.rpc(
    'get_dashboard_kpis',
    params: <String, dynamic>{
      'p_since': DateTime.utc(2025, 1, 1).toIso8601String(),
      'p_species_ids': <int>[1], // optional
      'p_limit': 6,              // optional (defaults to 12, capped at 52)
    },
  );
  ```
  The RPC returns a list of maps containing the columns exposed by the view (`species_name`, `total_litters`, `top_doe_label`, etc.).

## Metrics & sync helper RPCs
- `public.upsert_breeding_metrics`  
  Wraps an `INSERT ... ON CONFLICT` to keep `breeding_metrics` in sync with analytics jobs. Passing `null` for `top_doe_id` or `top_buck_id` clears previous champions. Soft-deleted rows are automatically revived.

- `public.sync_payload`  
  Accepts a JSON array of offline operations and stores it in `sync_queue` with the status `pending`, ready for an Edge Function worker to replay: 
  ```dart
  await supabase.rpc(
    'sync_payload',
    params: <String, dynamic>{
      'p_profile_id': supabase.auth.currentUser!.id,
      'p_operations': jsonEncode(operations), // operations is a List<Map<String, dynamic>>
    },
  );
  ```

Both RPCs enforce `auth.uid()` checks (unless called with the `service_role` key) and return the affected record (`upsert_breeding_metrics`) or queue identifier (`sync_payload`).

## Knowledge base & support checks
- `knowledge_articles` stores the articles displayed in the in-app knowledge base.  
  Run `SELECT id, title, published FROM public.knowledge_articles LIMIT 5;` to ensure the table is reachable in read-only mode for authenticated clients.
- `support_requests`, `event_templates`, `food_types`, and `food_stock` enforce `FORCE ROW LEVEL SECURITY` with `updated_at` triggers so that only the owner (or the service role) can mutate the data.  
  Validate with `supabase db remote commit --dry-run` or manual role switching (`SET ROLE authenticated;` followed by `SET ROLE service_role;`).

## Synchronization log
- 2025-10-21 (project `rmtkvalfhbhhqczwvtoz` - dev): attempts blocked because the Supabase CLI is not linked to the project. A valid `SUPABASE_ACCESS_TOKEN` or database password is required to run `npx supabase login`, `npx supabase link -project-ref rmtkvalfhbhhqczwvtoz`, and `npx supabase db push`.
- 2025-10-29 : migrations appliquées manuellement via Supabase SQL Editor (Tâche 16)
