-- 20251011T203000Z__rls_core_policies.sql
-- Strengthen RLS policies across core tables for multi-tenant isolation

-- Ensure helper function exists
CREATE OR REPLACE FUNCTION public.current_profile_id()
RETURNS UUID AS 
  SELECT id FROM public.profiles WHERE user_id = auth.uid();
 LANGUAGE sql STABLE;

-- Roles table policies already defined

-- Profiles table: ensure inserts pass user ownership
CREATE POLICY "users can insert their profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Farms table: allow inserts only for authenticated profiles
CREATE POLICY "profiles can create farms"
  ON public.farms FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles pr
      WHERE pr.id = owner_profile_id AND pr.user_id = auth.uid()
    )
  );

-- Farm members: insert restricted to farm admins/owners
CREATE POLICY "farm admins can invite members"
  ON public.farm_members FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.farm_members fm
      JOIN public.roles r ON r.id = fm.role_id
      JOIN public.profiles pr ON pr.id = fm.profile_id
      WHERE fm.farm_id = farm_members.farm_id
        AND pr.user_id = auth.uid()
        AND r.code IN ('owner', 'admin')
    )
  );

-- Additional security for updates: status transitions handled only by admins
CREATE POLICY "farm admins can update memberships"
  ON public.farm_members FOR UPDATE
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

-- Additional helpers for future tables
CREATE OR REPLACE FUNCTION public.profile_farm_ids()
RETURNS TABLE(farm_id UUID) AS 
  SELECT fm.farm_id
  FROM public.farm_members fm
  JOIN public.profiles pr ON pr.id = fm.profile_id
  WHERE pr.user_id = auth.uid() AND fm.status = 'active';
 LANGUAGE sql STABLE;

-- Revoke default grants on tables to avoid bypassing RLS
REVOKE ALL ON public.roles FROM PUBLIC;
REVOKE ALL ON public.profiles FROM PUBLIC;
REVOKE ALL ON public.farms FROM PUBLIC;
REVOKE ALL ON public.farm_members FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.roles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.farms TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.farm_members TO authenticated;
