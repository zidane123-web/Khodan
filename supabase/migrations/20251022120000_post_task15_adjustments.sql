-- Post task 15 adjustments: knowledge base, RLS completion, dashboard snapshot helper
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

------------------------------------------------------------------------
-- Knowledge base table
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.knowledge_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  category TEXT,
  published BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.knowledge_articles IS
  'Global knowledge base articles displayed in the in-app support centre.';

ALTER TABLE public.knowledge_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_articles FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS knowledge_articles_read_authenticated ON public.knowledge_articles;
CREATE POLICY knowledge_articles_read_authenticated
  ON public.knowledge_articles
  FOR SELECT
  USING (
    (published IS TRUE OR auth.role() = 'service_role')
  );

DROP POLICY IF EXISTS knowledge_articles_manage_service_role ON public.knowledge_articles;
CREATE POLICY knowledge_articles_manage_service_role
  ON public.knowledge_articles
  FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

DROP TRIGGER IF EXISTS trg_knowledge_articles_updated_at ON public.knowledge_articles;
CREATE TRIGGER trg_knowledge_articles_updated_at
  BEFORE UPDATE ON public.knowledge_articles
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

------------------------------------------------------------------------
-- Support requests RLS & housekeeping
------------------------------------------------------------------------

ALTER TABLE public.support_requests
  ALTER COLUMN updated_at SET DEFAULT NOW();

ALTER TABLE public.support_requests
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

ALTER TABLE public.support_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_requests FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS support_requests_select_owner ON public.support_requests;
CREATE POLICY support_requests_select_owner
  ON public.support_requests
  FOR SELECT
  USING (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS support_requests_insert_owner ON public.support_requests;
CREATE POLICY support_requests_insert_owner
  ON public.support_requests
  FOR INSERT
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS support_requests_update_service_role ON public.support_requests;
CREATE POLICY support_requests_update_service_role
  ON public.support_requests
  FOR UPDATE
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

DROP POLICY IF EXISTS support_requests_delete_service_role ON public.support_requests;
CREATE POLICY support_requests_delete_service_role
  ON public.support_requests
  FOR DELETE
  USING (auth.role() = 'service_role');

DROP TRIGGER IF EXISTS trg_support_requests_updated_at ON public.support_requests;
CREATE TRIGGER trg_support_requests_updated_at
  BEFORE UPDATE ON public.support_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

------------------------------------------------------------------------
-- Event templates & inventory tables timestamps + RLS review
------------------------------------------------------------------------

ALTER TABLE public.event_templates
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

ALTER TABLE public.food_types
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

ALTER TABLE public.food_stock
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

ALTER TABLE public.event_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_stock ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.event_templates FORCE ROW LEVEL SECURITY;
ALTER TABLE public.food_types FORCE ROW LEVEL SECURITY;
ALTER TABLE public.food_stock FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own event templates" ON public.event_templates;
CREATE POLICY event_templates_owner_all
  ON public.event_templates
  FOR ALL
  USING (user_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (user_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS "Users can manage their own food types" ON public.food_types;
CREATE POLICY food_types_owner_all
  ON public.food_types
  FOR ALL
  USING (user_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (user_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS "Users can manage their own food stock" ON public.food_stock;
CREATE POLICY food_stock_owner_all
  ON public.food_stock
  FOR ALL
  USING (user_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (user_id = auth.uid() OR auth.role() = 'service_role');

DROP TRIGGER IF EXISTS trg_event_templates_updated_at ON public.event_templates;
CREATE TRIGGER trg_event_templates_updated_at
  BEFORE UPDATE ON public.event_templates
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_food_types_updated_at ON public.food_types;
CREATE TRIGGER trg_food_types_updated_at
  BEFORE UPDATE ON public.food_types
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_food_stock_updated_at ON public.food_stock;
CREATE TRIGGER trg_food_stock_updated_at
  BEFORE UPDATE ON public.food_stock
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

------------------------------------------------------------------------
-- Dashboard snapshot RPC (minimal aggregate to unblock the app)
------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.get_dashboard_snapshot(
  p_period_start DATE DEFAULT NULL,
  p_period_end DATE DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO public
AS $$
DECLARE
  v_profile_id UUID := auth.uid();
  v_now DATE := CURRENT_DATE;
  v_start DATE := COALESCE(p_period_start, v_now - INTERVAL '60 days');
  v_end DATE := COALESCE(p_period_end, v_now + INTERVAL '60 days');
  v_total_animals INTEGER;
  v_active_animals INTEGER;
  v_gestation INTEGER;
  v_planned INTEGER;
  v_litters INTEGER;
  v_evaluated INTEGER;
  v_success NUMERIC;
  v_payload JSONB;
BEGIN
  IF v_profile_id IS NULL THEN
    RAISE EXCEPTION 'auth.uid() required to fetch dashboard snapshot';
  END IF;

  SELECT
    COUNT(*)::INTEGER,
    COUNT(*) FILTER (
      WHERE COALESCE(status, '') NOT IN ('inactive', 'sold', 'deceased')
    )::INTEGER
  INTO v_total_animals, v_active_animals
  FROM public.animals a
  WHERE a.profile_id = v_profile_id
    AND a.deleted_at IS NULL;

  SELECT
    COUNT(*)::INTEGER FILTER (
      WHERE br.palpation_positive IS TRUE
        AND (br.kindling_date IS NULL OR br.kindling_date >= v_now)
    ),
    COUNT(*)::INTEGER FILTER (
      WHERE br.mating_date BETWEEN v_start AND v_end
    ),
    COUNT(*)::INTEGER FILTER (
      WHERE br.kindling_date IS NOT NULL
        AND (br.weaning_date IS NULL OR br.weaning_date >= v_now)
    ),
    COUNT(*)::INTEGER FILTER (WHERE br.palpation_positive IS NOT NULL),
    CASE
      WHEN COUNT(*) FILTER (WHERE br.palpation_positive IS NOT NULL) = 0 THEN NULL
      ELSE ROUND(
        COUNT(*) FILTER (WHERE br.palpation_positive IS TRUE)::NUMERIC
        / COUNT(*) FILTER (WHERE br.palpation_positive IS NOT NULL)::NUMERIC,
        4
      )
    END
  INTO v_gestation, v_planned, v_litters, v_evaluated, v_success
  FROM public.breeding_records br
  WHERE br.profile_id = v_profile_id
    AND br.deleted_at IS NULL;

  v_payload := jsonb_build_object(
    'total_animals', COALESCE(v_total_animals, 0),
    'active_animals', COALESCE(v_active_animals, 0),
    'does_in_gestation', COALESCE(v_gestation, 0),
    'planned_breedings', COALESCE(v_planned, 0),
    'active_litters', COALESCE(v_litters, 0),
    'breeding_evaluated_count', COALESCE(v_evaluated, 0),
    'breeding_success_rate', v_success
  );

  RETURN v_payload
    || jsonb_build_object(
      'today_tasks', '[]'::JSONB,
      'upcoming_tasks', '[]'::JSONB,
      'alerts', '[]'::JSONB,
      'health_alerts', '[]'::JSONB,
      'calendar_events', '[]'::JSONB,
      'kpi_filters', '{}'::JSONB,
      'inventory_summary', NULL,
      'performance', jsonb_build_object(
        'total_litters', COALESCE(v_litters, 0),
        'average_kits_born_alive', NULL,
        'average_kits_weaned', NULL,
        'total_kits_weaned', 0,
        'top_doe_label', NULL,
        'top_buck_label', NULL
      ),
      'kpi_rows', '[]'::JSONB
    );
END;
$$;
