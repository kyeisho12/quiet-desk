-- Per-account alarm history for the Quiet Desk clock.
begin;

create table if not exists public.clock_alarms (
  id text primary key default gen_random_uuid()::text,
  account_id uuid not null references public.accounts(id) on delete cascade,
  time text not null,
  reminder text not null default '',
  sound boolean not null default true,
  zone text not null default 'local',
  zone_label text not null default 'This computer',
  created_at timestamptz not null default now()
);

create index if not exists clock_alarms_account_id_idx
  on public.clock_alarms(account_id);

commit;
