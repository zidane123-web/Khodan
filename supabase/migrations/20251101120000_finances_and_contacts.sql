-- Finance ledger and contacts tables
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

------------------------------------------------------------------------
-- Contacts
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'other' CHECK (
    type IN ('breeder', 'supplier', 'client', 'staff', 'other')
  ),
  email TEXT,
  phone TEXT,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT contacts_display_name_unique
    UNIQUE (profile_id, display_name)
);

COMMENT ON TABLE public.contacts IS
  'Address book for suppliers, clients, breeders and staff linked to financial transactions.';

CREATE INDEX IF NOT EXISTS contacts_profile_type_idx
  ON public.contacts (profile_id, type);

CREATE INDEX IF NOT EXISTS contacts_profile_name_idx
  ON public.contacts (profile_id, lower(display_name));

------------------------------------------------------------------------
-- Transaction categories
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.transaction_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  label TEXT NOT NULL,
  default_flow TEXT NOT NULL CHECK (
    default_flow IN ('income', 'expense', 'neutral')
  ),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  is_custom BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT transaction_categories_code_uniq
    UNIQUE (profile_id, code)
);

COMMENT ON TABLE public.transaction_categories IS
  'Default and custom finance categories used to group income and expenses.';

CREATE INDEX IF NOT EXISTS transaction_categories_profile_idx
  ON public.transaction_categories (profile_id, is_active);

------------------------------------------------------------------------
-- Financial transactions
------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.financial_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.transaction_categories(id) ON DELETE SET NULL,
  contact_id UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  notes TEXT,
  flow TEXT NOT NULL CHECK (
    flow IN ('income', 'expense', 'neutral')
  ),
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  currency TEXT NOT NULL DEFAULT 'XOF',
  occured_on DATE NOT NULL,
  payment_method TEXT,
  attachment_url TEXT,
  attachment_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.financial_transactions IS
  'Ledger entries recording money movement with optional contact and attachment.';

CREATE INDEX IF NOT EXISTS financial_transactions_profile_date_idx
  ON public.financial_transactions (profile_id, occured_on DESC);

CREATE INDEX IF NOT EXISTS financial_transactions_category_idx
  ON public.financial_transactions (profile_id, category_id);

CREATE INDEX IF NOT EXISTS financial_transactions_contact_idx
  ON public.financial_transactions (profile_id, contact_id);

------------------------------------------------------------------------
-- Row level security
------------------------------------------------------------------------

ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.contacts FORCE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_categories FORCE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transactions FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS contacts_owner_all ON public.contacts;
CREATE POLICY contacts_owner_all
  ON public.contacts
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS transaction_categories_select ON public.transaction_categories;
CREATE POLICY transaction_categories_select
  ON public.transaction_categories
  FOR SELECT
  USING (
    auth.role() = 'service_role'
    OR profile_id = auth.uid()
    OR profile_id IS NULL
  );

DROP POLICY IF EXISTS transaction_categories_manage ON public.transaction_categories;
CREATE POLICY transaction_categories_manage
  ON public.transaction_categories
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (
    profile_id = auth.uid() OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS financial_transactions_owner_all ON public.financial_transactions;
CREATE POLICY financial_transactions_owner_all
  ON public.financial_transactions
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

------------------------------------------------------------------------
-- Timestamps trigger
------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_contacts_timestamps ON public.contacts;
CREATE TRIGGER trg_contacts_timestamps
  BEFORE UPDATE ON public.contacts
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_transaction_categories_timestamps ON public.transaction_categories;
CREATE TRIGGER trg_transaction_categories_timestamps
  BEFORE UPDATE ON public.transaction_categories
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_financial_transactions_timestamps ON public.financial_transactions;
CREATE TRIGGER trg_financial_transactions_timestamps
  BEFORE UPDATE ON public.financial_transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

------------------------------------------------------------------------
-- Grants
------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.contacts TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.transaction_categories TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.financial_transactions TO authenticated;

GRANT ALL PRIVILEGES
  ON public.contacts TO service_role;
GRANT ALL PRIVILEGES
  ON public.transaction_categories TO service_role;
GRANT ALL PRIVILEGES
  ON public.financial_transactions TO service_role;

