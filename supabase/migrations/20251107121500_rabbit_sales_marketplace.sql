-- Rabbit sales, transfers and marketplace listings
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

-------------------------------------------------------------------------------
-- Helper: archive timestamp when status reaches a terminal state
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.tg_archive_on_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  should_archive BOOLEAN := FALSE;
  idx INTEGER;
BEGIN
  IF TG_NARGS = 0 THEN
    RETURN NEW;
  END IF;

  FOR idx IN 0 .. TG_NARGS - 1 LOOP
    IF TG_ARGV[idx] = NEW.status THEN
      should_archive := TRUE;
      EXIT;
    END IF;
  END LOOP;

  IF should_archive AND NEW.archived_at IS NULL THEN
    NEW.archived_at = NOW();
  END IF;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.tg_archive_on_status_change() IS
  'Auto-fill archived_at when the status matches any trigger argument.';

-------------------------------------------------------------------------------
-- rabbit_sales
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rabbit_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
  financial_transaction_id UUID
    REFERENCES public.financial_transactions(id) ON DELETE SET NULL,
  sale_type TEXT NOT NULL DEFAULT 'local'
    CHECK (sale_type IN ('local', 'marketplace')),
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'pending', 'completed', 'cancelled')),
  price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
  currency TEXT NOT NULL DEFAULT 'XOF',
  payment_method TEXT,
  proof_url TEXT,
  proof_name TEXT,
  expected_close_date DATE,
  closed_at TIMESTAMPTZ,
  notes TEXT,
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.rabbit_sales IS
  'Local rabbit sales linked to contacts, animals and ledger transactions.';

CREATE INDEX IF NOT EXISTS rabbit_sales_profile_status_idx
  ON public.rabbit_sales (profile_id, status)
  WHERE archived_at IS NULL;

CREATE INDEX IF NOT EXISTS rabbit_sales_animal_idx
  ON public.rabbit_sales (animal_id);

CREATE UNIQUE INDEX IF NOT EXISTS rabbit_sales_open_animal_unique
  ON public.rabbit_sales (animal_id)
  WHERE archived_at IS NULL AND status IN ('draft', 'pending');

-------------------------------------------------------------------------------
-- rabbit_transfers
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.rabbit_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipient_profile_id UUID NOT NULL
    REFERENCES public.profiles(id) ON DELETE CASCADE,
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  contact_id UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
  financial_transaction_id UUID
    REFERENCES public.financial_transactions(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (
      status IN ('pending', 'accepted', 'rejected', 'cancelled', 'completed')
    ),
  transfer_fee NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (transfer_fee >= 0),
  expires_at TIMESTAMPTZ,
  processed_at TIMESTAMPTZ,
  notes TEXT,
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.rabbit_transfers IS
  'Tracks transfers between Khodan accounts plus optional logistics fees.';

CREATE INDEX IF NOT EXISTS rabbit_transfers_profiles_idx
  ON public.rabbit_transfers (profile_id, recipient_profile_id);

CREATE INDEX IF NOT EXISTS rabbit_transfers_status_idx
  ON public.rabbit_transfers (status)
  WHERE archived_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS rabbit_transfers_active_animal_unique
  ON public.rabbit_transfers (animal_id)
  WHERE archived_at IS NULL AND status IN ('pending', 'accepted');

-------------------------------------------------------------------------------
-- marketplace_listings
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.marketplace_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  animal_id UUID REFERENCES public.animals(id) ON DELETE SET NULL,
  contact_id UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
  fee_transaction_id UUID
    REFERENCES public.financial_transactions(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  price NUMERIC(12, 2) CHECK (price IS NULL OR price >= 0),
  currency TEXT NOT NULL DEFAULT 'XOF',
  is_negotiable BOOLEAN NOT NULL DEFAULT FALSE,
  media_urls TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  tags TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (
      status IN ('draft', 'published', 'paused', 'expired', 'sold', 'withdrawn')
    ),
  visibility TEXT NOT NULL DEFAULT 'public'
    CHECK (visibility IN ('public', 'private')),
  published_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.marketplace_listings IS
  'Lightweight listings exposed on the Khodan mini-marketplace.';

CREATE INDEX IF NOT EXISTS marketplace_listings_profile_idx
  ON public.marketplace_listings (profile_id, status)
  WHERE archived_at IS NULL;

CREATE INDEX IF NOT EXISTS marketplace_listings_expires_idx
  ON public.marketplace_listings (expires_at)
  WHERE status = 'published';

-------------------------------------------------------------------------------
-- Row Level Security & policies
-------------------------------------------------------------------------------

ALTER TABLE public.rabbit_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rabbit_sales FORCE ROW LEVEL SECURITY;

ALTER TABLE public.rabbit_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rabbit_transfers FORCE ROW LEVEL SECURITY;

ALTER TABLE public.marketplace_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketplace_listings FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rabbit_sales_owner_all ON public.rabbit_sales;
CREATE POLICY rabbit_sales_owner_all
  ON public.rabbit_sales
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS rabbit_transfers_owner_all ON public.rabbit_transfers;
CREATE POLICY rabbit_transfers_owner_all
  ON public.rabbit_transfers
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS rabbit_transfers_recipient_rw ON public.rabbit_transfers;
CREATE POLICY rabbit_transfers_recipient_rw
  ON public.rabbit_transfers
  FOR SELECT, UPDATE
  USING (recipient_profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (recipient_profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS marketplace_listings_owner_all
  ON public.marketplace_listings;
CREATE POLICY marketplace_listings_owner_all
  ON public.marketplace_listings
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

-------------------------------------------------------------------------------
-- Housekeeping triggers
-------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_rabbit_sales_timestamps ON public.rabbit_sales;
CREATE TRIGGER trg_rabbit_sales_timestamps
  BEFORE UPDATE ON public.rabbit_sales
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_rabbit_sales_archive ON public.rabbit_sales;
CREATE TRIGGER trg_rabbit_sales_archive
  BEFORE UPDATE ON public.rabbit_sales
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_archive_on_status_change('completed', 'cancelled');

DROP TRIGGER IF EXISTS trg_rabbit_transfers_timestamps
  ON public.rabbit_transfers;
CREATE TRIGGER trg_rabbit_transfers_timestamps
  BEFORE UPDATE ON public.rabbit_transfers
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_rabbit_transfers_archive
  ON public.rabbit_transfers;
CREATE TRIGGER trg_rabbit_transfers_archive
  BEFORE UPDATE ON public.rabbit_transfers
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_archive_on_status_change(
    'completed',
    'cancelled',
    'rejected'
  );

DROP TRIGGER IF EXISTS trg_marketplace_listings_timestamps
  ON public.marketplace_listings;
CREATE TRIGGER trg_marketplace_listings_timestamps
  BEFORE UPDATE ON public.marketplace_listings
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_marketplace_listings_archive
  ON public.marketplace_listings;
CREATE TRIGGER trg_marketplace_listings_archive
  BEFORE UPDATE ON public.marketplace_listings
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_archive_on_status_change(
    'expired',
    'sold',
    'withdrawn'
  );
