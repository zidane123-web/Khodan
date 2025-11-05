-- Migration: cage_card_templates (task 14)
-- Creates per-user card templates aligned with Everbreed-inspired settings.

create table if not exists public.cage_card_templates (
    id uuid primary key default gen_random_uuid(),
    profile_id uuid not null references public.profiles(id) on delete cascade,
    label text not null,
    format text not null check (format in ('A4', 'A5', 'LABEL')),
    enabled_fields jsonb not null default '{}'::jsonb,
    accent_color text not null default '#2F855A',
    include_sensitive boolean not null default false,
    storage_path text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    unique (profile_id, label)
);

comment on table public.cage_card_templates is 'Stores cage card template preferences per breeder profile.';

alter table public.cage_card_templates enable row level security;

drop trigger if exists tg_cage_card_templates_timestamps on public.cage_card_templates;
create trigger tg_cage_card_templates_timestamps
    before update on public.cage_card_templates
    for each row execute function public.tg_maintain_timestamps();

create policy "Cage card templates are visible to their owner"
    on public.cage_card_templates
    for select
    using (auth.uid() = profile_id);

create policy "Users can insert their own cage card templates"
    on public.cage_card_templates
    for insert
    with check (auth.uid() = profile_id);

create policy "Users can update their own cage card templates"
    on public.cage_card_templates
    for update
    using (auth.uid() = profile_id)
    with check (auth.uid() = profile_id);

create policy "Users can delete their own cage card templates"
    on public.cage_card_templates
    for delete
    using (auth.uid() = profile_id);

grant select, insert, update, delete
    on public.cage_card_templates
    to authenticated;

grant all privileges
    on public.cage_card_templates
    to service_role;
