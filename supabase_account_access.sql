-- Quiet Desk username-only prototype access
-- Run after supabase_account_migration.sql.
-- This is intentionally permissive because the prototype has no authenticated
-- identity; anyone who knows a username can act as that username.

begin;

grant usage on schema public to anon;
grant select, insert, update on public.accounts to anon;
grant select, insert, update, delete on public.call_scripts to anon;

alter table public.accounts enable row level security;
alter table public.call_scripts enable row level security;

drop policy if exists "username prototype can read accounts" on public.accounts;
create policy "username prototype can read accounts"
  on public.accounts for select
  to anon
  using (true);

drop policy if exists "username prototype can create accounts" on public.accounts;
create policy "username prototype can create accounts"
  on public.accounts for insert
  to anon
  with check (length(trim(username)) >= 2);

drop policy if exists "username prototype can update accounts" on public.accounts;
create policy "username prototype can update accounts"
  on public.accounts for update
  to anon
  using (true)
  with check (length(trim(username)) >= 2);

drop policy if exists "username prototype can read call scripts" on public.call_scripts;
create policy "username prototype can read call scripts"
  on public.call_scripts for select
  to anon
  using (true);

drop policy if exists "username prototype can create call scripts" on public.call_scripts;
create policy "username prototype can create call scripts"
  on public.call_scripts for insert
  to anon
  with check (account_id is not null);

drop policy if exists "username prototype can update call scripts" on public.call_scripts;
create policy "username prototype can update call scripts"
  on public.call_scripts for update
  to anon
  using (true)
  with check (account_id is not null);

drop policy if exists "username prototype can delete call scripts" on public.call_scripts;
create policy "username prototype can delete call scripts"
  on public.call_scripts for delete
  to anon
  using (true);

commit;
