-- Security, policies, triggers and dashboard RPC surface
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

-- -------------------------------------------------------------------
-- Enable and enforce RLS on tenant-scoped tables
-- -------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

ALTER TABLE public.species_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.species_config FORCE ROW LEVEL SECURITY;

ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animals FORCE ROW LEVEL SECURITY;

ALTER TABLE public.breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breeding_records FORCE ROW LEVEL SECURITY;

ALTER TABLE public.breeding_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breeding_metrics FORCE ROW LEVEL SECURITY;

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events FORCE ROW LEVEL SECURITY;

ALTER TABLE public.animal_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.animal_events FORCE ROW LEVEL SECURITY;

ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue FORCE ROW LEVEL SECURITY;

-- -------------------------------------------------------------------
-- Row Level Security Policies
-- -------------------------------------------------------------------

DROP POLICY IF EXISTS profiles_select_self ON public.profiles;
CREATE POLICY profiles_select_self
  ON public.profiles
  FOR SELECT
  USING (id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS profiles_insert_self ON public.profiles;
CREATE POLICY profiles_insert_self
  ON public.profiles
  FOR INSERT
  WITH CHECK (id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS profiles_update_self ON public.profiles;
CREATE POLICY profiles_update_self
  ON public.profiles
  FOR UPDATE
  USING (id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS profiles_delete_self ON public.profiles;
CREATE POLICY profiles_delete_self
  ON public.profiles
  FOR DELETE
  USING (id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS species_config_owner_policy ON public.species_config;
CREATE POLICY species_config_owner_policy
  ON public.species_config
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS animals_owner_policy ON public.animals;
CREATE POLICY animals_owner_policy
  ON public.animals
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS breeding_records_owner_policy ON public.breeding_records;
CREATE POLICY breeding_records_owner_policy
  ON public.breeding_records
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS breeding_metrics_owner_policy ON public.breeding_metrics;
CREATE POLICY breeding_metrics_owner_policy
  ON public.breeding_metrics
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS events_owner_policy ON public.events;
CREATE POLICY events_owner_policy
  ON public.events
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS animal_events_owner_policy ON public.animal_events;
CREATE POLICY animal_events_owner_policy
  ON public.animal_events
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM public.events e
      WHERE e.id = animal_events.event_id
        AND (e.profile_id = auth.uid() OR auth.role() = 'service_role')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.events e
      WHERE e.id = animal_events.event_id
        AND (e.profile_id = auth.uid() OR auth.role() = 'service_role')
    )
  );

DROP POLICY IF EXISTS sync_queue_owner_policy ON public.sync_queue;
CREATE POLICY sync_queue_owner_policy
  ON public.sync_queue
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

-- -------------------------------------------------------------------
-- Timestamp maintenance trigger
-- -------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.tg_maintain_timestamps()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF ROW(NEW.*) IS DISTINCT FROM ROW(OLD.*) THEN
      NEW.updated_at = NOW();
    ELSE
      RETURN OLD;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.tg_maintain_timestamps() IS
  'Keeps the updated_at column in sync while ignoring no-op updates.';

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_species_config_updated_at ON public.species_config;
CREATE TRIGGER trg_species_config_updated_at
  BEFORE UPDATE ON public.species_config
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_animals_updated_at ON public.animals;
CREATE TRIGGER trg_animals_updated_at
  BEFORE UPDATE ON public.animals
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_breeding_records_updated_at ON public.breeding_records;
CREATE TRIGGER trg_breeding_records_updated_at
  BEFORE UPDATE ON public.breeding_records
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_breeding_metrics_updated_at ON public.breeding_metrics;
CREATE TRIGGER trg_breeding_metrics_updated_at
  BEFORE UPDATE ON public.breeding_metrics
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_events_updated_at ON public.events;
CREATE TRIGGER trg_events_updated_at
  BEFORE UPDATE ON public.events
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_animal_events_updated_at ON public.animal_events;
CREATE TRIGGER trg_animal_events_updated_at
  BEFORE UPDATE ON public.animal_events
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_sync_queue_updated_at ON public.sync_queue;
CREATE TRIGGER trg_sync_queue_updated_at
  BEFORE UPDATE ON public.sync_queue
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

-- -------------------------------------------------------------------
-- Aggregated dashboard view
-- -------------------------------------------------------------------

CREATE OR REPLACE VIEW public.dashboard_kpis AS
SELECT
  bm.profile_id,
  bm.species_id,
  sc.species_name,
  bm.period_start,
  bm.period_end,
  bm.total_litters,
  bm.average_kits_born_alive,
  bm.average_kits_weaned,
  bm.total_kits_weaned,
  COALESCE(doe.name, doe.tag_id) AS top_doe_label,
  COALESCE(buck.name, buck.tag_id) AS top_buck_label
FROM public.breeding_metrics bm
LEFT JOIN public.species_config sc ON sc.id = bm.species_id
LEFT JOIN public.animals doe ON doe.id = bm.top_doe_id AND (doe.deleted_at IS NULL)
LEFT JOIN public.animals buck ON buck.id = bm.top_buck_id AND (buck.deleted_at IS NULL)
WHERE bm.deleted_at IS NULL
  AND (sc.deleted_at IS NULL OR sc.id IS NULL);

COMMENT ON VIEW public.dashboard_kpis IS
  'Aggregated KPIs joining breeding metrics with species and champion animals for dashboard consumption.';

GRANT SELECT ON public.dashboard_kpis TO authenticated, service_role;

-- -------------------------------------------------------------------
-- RPC helpers
-- -------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.upsert_breeding_metrics(
  p_profile_id uuid,
  p_species_id bigint,
  p_period_start date,
  p_period_end date,
  p_total_litters integer DEFAULT 0,
  p_average_kits_born_alive numeric(6, 3) DEFAULT NULL,
  p_average_kits_weaned numeric(6, 3) DEFAULT NULL,
  p_total_kits_weaned integer DEFAULT 0,
  p_top_doe_id uuid DEFAULT NULL,
  p_top_buck_id uuid DEFAULT NULL
)
RETURNS public.breeding_metrics
LANGUAGE plpgsql
SET search_path TO public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_result public.breeding_metrics%ROWTYPE;
BEGIN
  IF auth.role() <> 'service_role' THEN
    IF v_uid IS NULL THEN
      RAISE EXCEPTION 'auth.uid() required to upsert metrics';
    END IF;
    IF v_uid <> p_profile_id THEN
      RAISE EXCEPTION 'Access denied for profile %', p_profile_id;
    END IF;
  END IF;

  INSERT INTO public.breeding_metrics (
    profile_id,
    species_id,
    period_start,
    period_end,
    total_litters,
    average_kits_born_alive,
    average_kits_weaned,
    total_kits_weaned,
    top_doe_id,
    top_buck_id,
    deleted_at
  )
  VALUES (
    p_profile_id,
    p_species_id,
    p_period_start,
    p_period_end,
    COALESCE(p_total_litters, 0),
    p_average_kits_born_alive,
    p_average_kits_weaned,
    COALESCE(p_total_kits_weaned, 0),
    p_top_doe_id,
    p_top_buck_id,
    NULL
  )
  ON CONFLICT (profile_id, species_id, period_start, period_end)
  DO UPDATE
    SET total_litters = EXCLUDED.total_litters,
        average_kits_born_alive = EXCLUDED.average_kits_born_alive,
        average_kits_weaned = EXCLUDED.average_kits_weaned,
        total_kits_weaned = EXCLUDED.total_kits_weaned,
        top_doe_id = EXCLUDED.top_doe_id,
        top_buck_id = EXCLUDED.top_buck_id,
        deleted_at = NULL
  RETURNING * INTO v_result;

  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.upsert_breeding_metrics(uuid, bigint, date, date, integer, numeric, numeric, integer, uuid, uuid) IS
  'Insert or refresh aggregated breeding metrics for a profile while enforcing tenant boundaries.';

GRANT EXECUTE ON FUNCTION public.upsert_breeding_metrics(
  uuid,
  bigint,
  date,
  date,
  integer,
  numeric,
  numeric,
  integer,
  uuid,
  uuid
) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.sync_payload(
  p_profile_id uuid,
  p_operations jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SET search_path TO public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_inserted_id uuid;
BEGIN
  IF p_operations IS NULL OR jsonb_typeof(p_operations) <> 'array' THEN
    RAISE EXCEPTION 'Expected a JSON array of operations';
  END IF;

  IF auth.role() <> 'service_role' THEN
    IF v_uid IS NULL THEN
      RAISE EXCEPTION 'auth.uid() required to enqueue sync payload';
    END IF;
    IF v_uid <> p_profile_id THEN
      RAISE EXCEPTION 'Access denied for profile %', p_profile_id;
    END IF;
  END IF;

  INSERT INTO public.sync_queue (
    profile_id,
    entity,
    operation,
    payload,
    status,
    scheduled_at
  )
  VALUES (
    p_profile_id,
    'bulk',
    'sync',
    p_operations,
    'pending',
    NOW()
  )
  RETURNING id INTO v_inserted_id;

  RETURN v_inserted_id;
END;
$$;

COMMENT ON FUNCTION public.sync_payload(uuid, jsonb) IS
  'Queues a batch of offline mutations for later processing.';

GRANT EXECUTE ON FUNCTION public.sync_payload(uuid, jsonb) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.get_dashboard_kpis(
  p_since date DEFAULT NULL,
  p_species_ids bigint[] DEFAULT NULL,
  p_limit integer DEFAULT 12
)
RETURNS TABLE (
  profile_id uuid,
  species_id bigint,
  species_name text,
  period_start date,
  period_end date,
  total_litters integer,
  average_kits_born_alive numeric(6, 3),
  average_kits_weaned numeric(6, 3),
  total_kits_weaned integer,
  top_doe_label text,
  top_buck_label text
)
LANGUAGE sql
SECURITY INVOKER
SET search_path TO public
AS $$
  SELECT
    k.profile_id,
    k.species_id,
    k.species_name,
    k.period_start,
    k.period_end,
    k.total_litters,
    k.average_kits_born_alive,
    k.average_kits_weaned,
    k.total_kits_weaned,
    k.top_doe_label,
    k.top_buck_label
  FROM public.dashboard_kpis k
  WHERE k.profile_id = auth.uid()
    AND (p_since IS NULL OR k.period_end >= p_since)
    AND (p_species_ids IS NULL OR k.species_id = ANY(p_species_ids))
  ORDER BY k.period_end DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 12), 1), 52);
$$;

COMMENT ON FUNCTION public.get_dashboard_kpis(date, bigint[], integer) IS
  'Returns dashboard KPIs filtered by species and period for the connected profile.';

GRANT EXECUTE ON FUNCTION public.get_dashboard_kpis(date, bigint[], integer)
  TO authenticated, service_role;
