-- Quiet Desk username accounts
-- Run this in Supabase SQL Editor before switching the frontend to backend accounts.
-- Username-only access is intentionally lightweight and does not verify identity.

begin;

create extension if not exists pgcrypto;

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  username text not null,
  username_key text generated always as (lower(trim(username))) stored,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  onboarding_complete boolean not null default false
);

create unique index if not exists accounts_username_key_idx
  on public.accounts (username_key);

alter table public.call_scripts
  add column if not exists account_id uuid references public.accounts(id) on delete cascade;

-- If account_id already existed before this migration, normalize its foreign
-- key so deleting an account also removes only that account's call scripts.
alter table public.call_scripts
  drop constraint if exists call_scripts_account_id_fkey;

alter table public.call_scripts
  add constraint call_scripts_account_id_fkey
  foreign key (account_id) references public.accounts(id) on delete cascade;

create index if not exists call_scripts_account_id_idx
  on public.call_scripts (account_id);

-- Preserve the existing local workspace by creating the owner's account and
-- assigning all currently shared scripts to it.
insert into public.accounts (username, onboarding_complete)
values ('Guian', true)
on conflict (username_key) do update
set last_seen_at = now(),
    onboarding_complete = true;

update public.call_scripts
set account_id = (
  select id
  from public.accounts
  where username_key = 'guian'
)
where account_id is null;

create or replace function public.delete_expired_incomplete_accounts()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  deleted_count integer;
begin
  delete from public.accounts
  where onboarding_complete = false
    and created_at < now() - interval '3 hours';

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

-- The frontend needs to use account_id filters after this migration.
-- Enable row-level security only after the frontend has been switched to
-- backend account queries and the policies have been reviewed.

commit;

-- Optional Supabase project scheduler setup:
-- 1. Enable the pg_cron extension in Database > Extensions.
-- 2. Run this once to clean incomplete accounts every 15 minutes:
--
-- select cron.schedule(
--   'delete-expired-incomplete-quiet-desk-accounts',
--   '*/15 * * * *',
--   $$select public.delete_expired_incomplete_accounts();$$
-- );
