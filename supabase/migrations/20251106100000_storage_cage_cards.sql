-- Storage bucket for cage card exports (Plan2 - tache 14 support)
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'cage_cards',
    'cage_cards',
    FALSE,
    10485760, -- 10 MB
    ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE
SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Policies
DROP POLICY IF EXISTS "cage_cards owners can read" ON storage.objects;
CREATE POLICY "cage_cards owners can read"
    ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'cage_cards'
        AND split_part(name, '/', 1) = auth.uid()::text
    );

DROP POLICY IF EXISTS "cage_cards owners can insert" ON storage.objects;
CREATE POLICY "cage_cards owners can insert"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'cage_cards'
        AND split_part(name, '/', 1) = auth.uid()::text
    );

DROP POLICY IF EXISTS "cage_cards owners can update" ON storage.objects;
CREATE POLICY "cage_cards owners can update"
    ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'cage_cards'
        AND split_part(name, '/', 1) = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'cage_cards'
        AND split_part(name, '/', 1) = auth.uid()::text
    );

DROP POLICY IF EXISTS "cage_cards owners can delete" ON storage.objects;
CREATE POLICY "cage_cards owners can delete"
    ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'cage_cards'
        AND split_part(name, '/', 1) = auth.uid()::text
    );

-- Allow service role full access
GRANT ALL ON storage.objects TO service_role;
