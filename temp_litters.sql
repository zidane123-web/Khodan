-- Create litter status enum
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'litter_status'
  ) THEN
    CREATE TYPE public.litter_status AS ENUM (
      'GESTATING',
      'PALPATION_DUE',
      'WEANING',
      'HARVEST_READY',
      'ARCHIVED'
    );
  END IF;
END $$;

-- Main litters table
CREATE TABLE IF NOT EXISTS public.litters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  code text NOT NULL,
  doe_tag text NOT NULL,
  buck_tag text NOT NULL,
  breeding_date timestamptz NOT NULL,
  kindling_date timestamptz NOT NULL,
  born_alive integer NOT NULL CHECK (born_alive >= 0),
  born_dead integer NOT NULL DEFAULT 0 CHECK (born_dead >= 0),
  expected_weaned integer NOT NULL DEFAULT 0 CHECK (expected_weaned >= 0),
  cage text NOT NULL,
  enclosure text,
  status public.litter_status NOT NULL DEFAULT 'GESTATING',
  task_template_name text,
  notes text,
  next_reminder timestamptz,
  has_pending_sync boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS litters_profile_idx ON public.litters(profile_id);
CREATE INDEX IF NOT EXISTS litters_status_idx ON public.litters(status);
CREATE INDEX IF NOT EXISTS litters_breeding_date_idx ON public.litters(breeding_date);

CREATE OR REPLACE FUNCTION public.trg_touch_litters()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_litters_updated_at ON public.litters;
CREATE TRIGGER trg_litters_updated_at
BEFORE UPDATE ON public.litters
FOR EACH ROW
EXECUTE FUNCTION public.trg_touch_litters();

-- Litter kits table
CREATE TABLE IF NOT EXISTS public.litter_kits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  litter_id uuid NOT NULL REFERENCES public.litters(id) ON DELETE CASCADE,
  tag text NOT NULL,
  sex text NOT NULL DEFAULT '',
  birth_weight_grams numeric,
  weaning_weight_grams numeric,
  pre_slaughter_weight_grams numeric,
  carcass_weight_kg numeric,
  market_value numeric,
  destination text,
  has_pending_sync boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),
  updated_at timestamptz NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS litter_kits_litter_idx ON public.litter_kits(litter_id);

CREATE OR REPLACE FUNCTION public.trg_touch_litter_kits()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_litter_kits_updated_at ON public.litter_kits;
CREATE TRIGGER trg_litter_kits_updated_at
BEFORE UPDATE ON public.litter_kits
FOR EACH ROW
EXECUTE FUNCTION public.trg_touch_litter_kits();

-- Enable Row Level Security and simple ownership policy
ALTER TABLE public.litters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.litter_kits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS litters_owner_policy ON public.litters;
CREATE POLICY litters_owner_policy
ON public.litters
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

DROP POLICY IF EXISTS litter_kits_owner_policy ON public.litter_kits;
CREATE POLICY litter_kits_owner_policy
ON public.litter_kits
USING (
  EXISTS (
    SELECT 1
    FROM public.litters l
    WHERE l.id = litter_id
      AND l.profile_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.litters l
    WHERE l.id = litter_id
      AND l.profile_id = auth.uid()
  )
);
