-- Subscription plans, user subscriptions and farm members
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

-------------------------------------------------------------------------------
-- subscription_plans
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  description TEXT,
  monthly_price_cents INTEGER NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'XOF',
  max_breeders INTEGER,
  max_members INTEGER,
  storage_limit_mb INTEGER,
  modules TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.subscription_plans IS 'Catalog of Khodan subscription plans and their limits.';

CREATE INDEX IF NOT EXISTS subscription_plans_active_idx
  ON public.subscription_plans (is_active, sort_order);

INSERT INTO public.subscription_plans AS plans (
  code,
  label,
  description,
  monthly_price_cents,
  currency,
  max_breeders,
  max_members,
  storage_limit_mb,
  modules,
  sort_order,
  metadata
)
VALUES
  (
    'free',
    'Gratuit',
    'Pour démarrer seul avec 5 éleveurs et le planning léger.',
    0,
    'XOF',
    5,
    1,
    100,
    ARRAY['dashboard', 'animals', 'planning-lite'],
    1,
    '{"support":"email","color":"#70b77e"}'::JSONB
  ),
  (
    'standard',
    'Standard',
    'Gestion quotidienne avec portées, rapports essentiels et 3 membres.',
    9900,
    'XOF',
    50,
    3,
    2048,
    ARRAY['dashboard', 'animals', 'litters', 'planning'],
    2,
    '{"support":"email","color":"#009688"}'::JSONB
  ),
  (
    'pro',
    'Pro',
    'Fermes multi-sites avec santé, stocks et marketplace locale.',
    19900,
    'XOF',
    250,
    10,
    10240,
    ARRAY['dashboard', 'animals', 'litters', 'planning', 'health', 'sales'],
    3,
    '{"support":"priority","color":"#006064"}'::JSONB
  ),
  (
    'enterprise',
    'Entreprise',
    'Coopératives et intégrateurs avec personnalisation et support dédié.',
    0,
    'XOF',
    500,
    NULL,
    51200,
    ARRAY['dashboard', 'animals', 'litters', 'planning', 'health', 'sales', 'api'],
    4,
    '{"support":"dedicated","color":"#263238"}'::JSONB
  )
ON CONFLICT (code)
DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  monthly_price_cents = EXCLUDED.monthly_price_cents,
  max_breeders = EXCLUDED.max_breeders,
  max_members = EXCLUDED.max_members,
  storage_limit_mb = EXCLUDED.storage_limit_mb,
  modules = EXCLUDED.modules,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

-------------------------------------------------------------------------------
-- user_subscriptions
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
  status TEXT NOT NULL DEFAULT 'trialing'
    CHECK (
      status IN (
        'trialing',
        'active',
        'past_due',
        'grace',
        'cancelled',
        'expired',
        'pending_manual_payment',
        'pending_stripe'
      )
    ),
  start_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_at TIMESTAMPTZ,
  renewal_at TIMESTAMPTZ,
  invoice_url TEXT,
  manual_payment_reference TEXT,
  payment_channel TEXT,
  quota_breeders_used INTEGER NOT NULL DEFAULT 0,
  quota_members_used INTEGER NOT NULL DEFAULT 0,
  quota_storage_used_mb INTEGER NOT NULL DEFAULT 0,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.user_subscriptions IS 'Links profiles to subscription plans and tracks quota usage.';

CREATE INDEX IF NOT EXISTS user_subscriptions_profile_idx
  ON public.user_subscriptions (profile_id);

CREATE INDEX IF NOT EXISTS user_subscriptions_status_idx
  ON public.user_subscriptions (status);

CREATE INDEX IF NOT EXISTS user_subscriptions_plan_idx
  ON public.user_subscriptions (plan_id);

CREATE UNIQUE INDEX IF NOT EXISTS user_subscriptions_active_unique
  ON public.user_subscriptions (profile_id)
  WHERE status IN ('trialing', 'active', 'past_due', 'pending_manual_payment', 'pending_stripe', 'grace');

-------------------------------------------------------------------------------
-- farm_members (team seats per farm/profile)
-------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.farm_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES public.subscription_plans(id),
  subscription_id UUID REFERENCES public.user_subscriptions(id) ON DELETE SET NULL,
  member_profile_id UUID REFERENCES public.profiles(id),
  email TEXT NOT NULL,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'viewer'
    CHECK (role IN ('owner', 'manager', 'technician', 'viewer')),
  status TEXT NOT NULL DEFAULT 'invited'
    CHECK (status IN ('invited', 'active', 'suspended', 'removed')),
  invited_by UUID REFERENCES public.profiles(id),
  invited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  start_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  notes TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.farm_members IS 'Members invited to collaborate on a farm, limited by the subscription plan.';

CREATE INDEX IF NOT EXISTS farm_members_profile_idx
  ON public.farm_members (profile_id, status);

CREATE INDEX IF NOT EXISTS farm_members_member_idx
  ON public.farm_members (member_profile_id)
  WHERE member_profile_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS farm_members_subscription_idx
  ON public.farm_members (subscription_id)
  WHERE subscription_id IS NOT NULL;

-------------------------------------------------------------------------------
-- Row Level Security
-------------------------------------------------------------------------------

ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.farm_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farm_members FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS subscription_plans_read_all ON public.subscription_plans;
CREATE POLICY subscription_plans_read_all
  ON public.subscription_plans
  FOR SELECT
  USING (TRUE);

DROP POLICY IF EXISTS subscription_plans_service_write ON public.subscription_plans;
CREATE POLICY subscription_plans_service_write
  ON public.subscription_plans
  FOR ALL
  TO service_role
  USING (TRUE)
  WITH CHECK (TRUE);

DROP POLICY IF EXISTS user_subscriptions_owner_all ON public.user_subscriptions;
CREATE POLICY user_subscriptions_owner_all
  ON public.user_subscriptions
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

DROP POLICY IF EXISTS farm_members_owner_all ON public.farm_members;
CREATE POLICY farm_members_owner_all
  ON public.farm_members
  FOR ALL
  USING (profile_id = auth.uid() OR auth.role() = 'service_role')
  WITH CHECK (profile_id = auth.uid() OR auth.role() = 'service_role');

-------------------------------------------------------------------------------
-- Triggers maintain updated_at
-------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_subscription_plans_timestamps
  ON public.subscription_plans;
CREATE TRIGGER trg_subscription_plans_timestamps
  BEFORE UPDATE ON public.subscription_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_user_subscriptions_timestamps
  ON public.user_subscriptions;
CREATE TRIGGER trg_user_subscriptions_timestamps
  BEFORE UPDATE ON public.user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();

DROP TRIGGER IF EXISTS trg_farm_members_timestamps
  ON public.farm_members;
CREATE TRIGGER trg_farm_members_timestamps
  BEFORE UPDATE ON public.farm_members
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_maintain_timestamps();
