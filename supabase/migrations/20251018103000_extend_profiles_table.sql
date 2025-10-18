-- Extend profiles table with farm metadata and legal preferences (Task 08)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS farm_location TEXT,
  ADD COLUMN IF NOT EXISTS legal_preferences JSONB NOT NULL DEFAULT '{}'::JSONB,
  ADD COLUMN IF NOT EXISTS billing_status TEXT;
