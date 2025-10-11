-- 20251011T201500Z__init_core_org_tables.sql
-- Phase M0: base tables for multi-tenant structure (profiles, farms, roles, memberships)

-- Helper function to maintain updated_at timestamps
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
RETURNS TRIGGER AS 
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
 LANGUAGE plpgsql;

-- ROLES TABLE ----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  description TEXT,
  permissions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

DROP TRIGGER IF EXISTS set_roles_updated_at ON public.roles;
CREATE TRIGGER set_roles_updated_at
  BEFORE UPDATE ON public.roles
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "roles are readable by all authenticated users"
  ON public.roles FOR SELECT
  USING (auth.role() = 'authenticated');

-- PROFILES TABLE -------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  locale TEXT DEFAULT 'fr',
  timezone TEXT DEFAULT 'UTC',
  created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can select their profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update their profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- FARMS TABLE ----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.farms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  country TEXT,
  timezone TEXT DEFAULT 'UTC',
  herd_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS farms_owner_profile_idx ON public.farms(owner_profile_id);

DROP TRIGGER IF EXISTS set_farms_updated_at ON public.farms;
CREATE TRIGGER set_farms_updated_at
  BEFORE UPDATE ON public.farms
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "owners can manage their farms"
  ON public.farms FOR ALL
  USING (auth.uid() IN (
    SELECT pr.user_id
    FROM public.profiles pr
    WHERE pr.id = farms.owner_profile_id
  ));

CREATE POLICY "members can read farms"
  ON public.farms FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.farm_members fm
      JOIN public.profiles pr ON pr.id = fm.profile_id
      WHERE fm.farm_id = farms.id AND pr.user_id = auth.uid()
    )
  );

-- FARM MEMBERS TABLE --------------------------------------------
CREATE TABLE IF NOT EXISTS public.farm_members (
  farm_id UUID NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'pending',
  invited_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  invited_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  joined_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
  PRIMARY KEY (farm_id, profile_id)
);

DROP TRIGGER IF EXISTS set_farm_members_updated_at ON public.farm_members;
CREATE TRIGGER set_farm_members_updated_at
  BEFORE UPDATE ON public.farm_members
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_current_timestamp_updated_at();

ALTER TABLE public.farm_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "members can view memberships they belong to"
  ON public.farm_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles pr
      WHERE pr.id = farm_members.profile_id AND pr.user_id = auth.uid()
    )
  );

CREATE POLICY "members can update their membership status"
  ON public.farm_members FOR UPDATE
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles pr
      WHERE pr.id = farm_members.profile_id AND pr.user_id = auth.uid()
    )
  );

CREATE POLICY "farm admins can manage memberships"
  ON public.farm_members FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM public.farm_members fm
      JOIN public.roles r ON r.id = fm.role_id
      JOIN public.profiles pr ON pr.id = fm.profile_id
      WHERE fm.farm_id = farm_members.farm_id
        AND pr.user_id = auth.uid()
        AND r.code IN ('owner', 'admin')
    )
  );

-- Seed default roles if table empty
INSERT INTO public.roles (code, label, description, permissions)
SELECT * FROM (VALUES
  ('owner', 'Propriétaire', 'Accès complet et gestion des membres', '["*:"]'::jsonb),
  ('admin', 'Administrateur', 'Gestion opérationnelle et accès complet aux données', '["read:*", "write:*", "manage:members"]'::jsonb),
  ('manager', 'Manager', 'Gestion quotidienne, modification données', '["read:*", "write:*", "manage:events"]'::jsonb),
  ('technician', 'Technicien', 'Accès aux opérations terrain', '["read:animals", "read:events", "write:events"]'::jsonb),
  ('observer', 'Observateur', 'Lecture seule', '["read:animals", "read:reports"]'::jsonb)
) AS seed(code, label, description, permissions)
WHERE NOT EXISTS (SELECT 1 FROM public.roles);
