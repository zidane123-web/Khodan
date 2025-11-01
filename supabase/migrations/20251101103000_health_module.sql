-- Health module tables (ailments, records, treatments)
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

------------------------------------------------------------------------
-- Ailments library
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.ailments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT,
  species_id BIGINT REFERENCES public.species_config(id) ON DELETE SET NULL,
  symptoms JSONB NOT NULL DEFAULT '[]'::JSONB,
  common_causes TEXT,
  recommended_treatments JSONB NOT NULL DEFAULT '[]'::JSONB,
  preventive_actions TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  CONSTRAINT ailments_slug_unique
    UNIQUE (profile_id, slug)
    DEFERRABLE INITIALLY IMMEDIATE,
  CONSTRAINT ailments_name_unique
    UNIQUE (profile_id, name)
);

COMMENT ON TABLE public.ailments IS
  'Library of health issues with symptoms and recommended treatments.';

CREATE INDEX IF NOT EXISTS ailments_profile_idx
  ON public.ailments (profile_id, archived_at)
  WHERE archived_at IS NULL;

CREATE INDEX IF NOT EXISTS ailments_species_idx
  ON public.ailments (species_id);

------------------------------------------------------------------------
-- Health records per animal
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.health_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  ailment_id UUID REFERENCES public.ailments(id) ON DELETE SET NULL,
  custom_diagnosis TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (
    status IN ('draft', 'active', 'resolved', 'archived')
  ),
  severity TEXT NOT NULL CHECK (
    severity IN ('low', 'moderate', 'high', 'critical')
  ),
  symptoms JSONB NOT NULL DEFAULT '[]'::JSONB,
  notes TEXT,
  onset_date DATE NOT NULL,
  resolved_at TIMESTAMPTZ,
  next_check_at TIMESTAMPTZ,
  offline_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT health_records_diagnosis_chk
    CHECK (
      ailment_id IS NOT NULL
      OR (
        custom_diagnosis IS NOT NULL
        AND length(trim(custom_diagnosis)) > 0
      )
    )
);

COMMENT ON TABLE public.health_records IS
  'Animal health records capturing diagnosis, symptoms, and follow-up.';

CREATE INDEX IF NOT EXISTS health_records_animal_idx
  ON public.health_records (profile_id, animal_id, status);

CREATE INDEX IF NOT EXISTS health_records_onset_idx
  ON public.health_records (profile_id, onset_date DESC);

CREATE UNIQUE INDEX IF NOT EXISTS health_records_offline_ref_uniq
  ON public.health_records (profile_id, offline_reference)
  WHERE offline_reference IS NOT NULL;

------------------------------------------------------------------------
-- Health treatments timeline
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.health_treatments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  record_id UUID NOT NULL REFERENCES public.health_records(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  treatment_type TEXT NOT NULL CHECK (
    treatment_type IN ('medication', 'procedure', 'care', 'diet_adjustment')
  ),
  dosage TEXT,
  frequency TEXT,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  task_id UUID REFERENCES public.events(id) ON DELETE SET NULL,
  reminder_minutes INTEGER[] NOT NULL DEFAULT ARRAY[]::INTEGER[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT health_treatments_duration_chk
    CHECK (end_at IS NULL OR end_at >= start_at),
  CONSTRAINT health_treatments_reminder_range_chk
    CHECK (
      reminder_minutes IS NULL
      OR COALESCE((
        SELECT bool_and(value BETWEEN -4320 AND 4320)
        FROM unnest(reminder_minutes) AS value
      ), TRUE)
    )
);

COMMENT ON TABLE public.health_treatments IS
  'Treatments linked to health records, with reminders and planning integration.';

CREATE INDEX IF NOT EXISTS health_treatments_record_idx
  ON public.health_treatments (record_id, start_at);

CREATE INDEX IF NOT EXISTS health_treatments_profile_idx
  ON public.health_treatments (profile_id, start_at);

CREATE UNIQUE INDEX IF NOT EXISTS health_treatments_task_unique
  ON public.health_treatments (task_id)
  WHERE task_id IS NOT NULL;

------------------------------------------------------------------------
-- Row level security & triggers
------------------------------------------------------------------------

ALTER TABLE public.ailments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_treatments ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.ailments FORCE ROW LEVEL SECURITY;
ALTER TABLE public.health_records FORCE ROW LEVEL SECURITY;
ALTER TABLE public.health_treatments FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ailments_owner_all ON public.ailments;
CREATE POLICY ailments_owner_all
  ON public.ailments
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS health_records_owner_all ON public.health_records;
CREATE POLICY health_records_owner_all
  ON public.health_records
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS health_treatments_owner_all ON public.health_treatments;
CREATE POLICY health_treatments_owner_all
  ON public.health_treatments
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP TRIGGER IF EXISTS trg_ailments_timestamps ON public.ailments;
CREATE TRIGGER trg_ailments_timestamps
  BEFORE UPDATE ON public.ailments
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_health_records_timestamps ON public.health_records;
CREATE TRIGGER trg_health_records_timestamps
  BEFORE UPDATE ON public.health_records
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_health_treatments_timestamps ON public.health_treatments;
CREATE TRIGGER trg_health_treatments_timestamps
  BEFORE UPDATE ON public.health_treatments
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();
