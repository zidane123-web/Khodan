import { serve } from 'https://deno.land/std@0.203.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('EDGE_SUPABASE_URL') ?? '';
const anonKey = Deno.env.get('EDGE_SUPABASE_ANON_KEY') ?? '';
const serviceRoleKey = Deno.env.get('EDGE_SUPABASE_SERVICE_ROLE_KEY') ?? '';

if (!supabaseUrl || !anonKey || !serviceRoleKey) {
  throw new Error(
    'Missing required env vars (EDGE_SUPABASE_URL, EDGE_SUPABASE_ANON_KEY, EDGE_SUPABASE_SERVICE_ROLE_KEY)',
  );
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response('Missing Authorization header', { status: 401 });
  }

  let payload: {
    profileId?: string;
    breederId?: string;
    storagePath?: string;
    expiresIn?: number;
  };

  try {
    payload = await req.json();
  } catch (_) {
    return new Response('Invalid JSON payload', { status: 400 });
  }

  const profileId = payload.profileId?.trim();
  const breederId = payload.breederId?.trim();
  const storagePath = payload.storagePath?.trim();
  const requestedExpiration = Number(payload.expiresIn ?? 60 * 60 * 24);

  if (!profileId || !breederId || !storagePath) {
    return new Response('profileId, breederId and storagePath are required', {
      status: 400,
    });
  }

  if (!storagePath.startsWith(`pedigrees/${profileId}`)) {
    return new Response('storagePath must target the current profile', {
      status: 400,
    });
  }

  const expiresInSeconds = Math.min(
    Math.max(Number.isFinite(requestedExpiration) ? requestedExpiration : 60 * 60 * 24, 60),
    60 * 60 * 24 * 7,
  );

  const supabaseClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userError } = await supabaseClient.auth.getUser();
  if (userError || !userData?.user) {
    return new Response('Invalid or expired token', { status: 401 });
  }

  if (userData.user.id !== profileId) {
    return new Response('Forbidden', { status: 403 });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey);
  const { data, error } = await adminClient.storage
    .from('pedigrees')
    .createSignedUrl(storagePath, expiresInSeconds);

  if (error || !data?.signedUrl) {
    return new Response(error?.message ?? 'Unable to create signed URL', {
      status: 500,
    });
  }

  const responseBody = {
    shareUrl: data.signedUrl,
    storagePath,
    expiresInSeconds,
    expiresAt: new Date(Date.now() + expiresInSeconds * 1000).toISOString(),
    breederId,
  };

  return new Response(JSON.stringify(responseBody), {
    headers: { 'Content-Type': 'application/json' },
  });
});
