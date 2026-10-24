-- Quiet Desk shared conference chat access
-- Run after supabase_chat_migration.sql.
-- This remains permissive because the prototype has no authenticated identity.

begin;

grant select, insert, update, delete on public.chat_messages to anon;
grant usage, select on sequence public.chat_messages_id_seq to anon;
grant select, insert, update, delete on public.chat_reads to anon;
grant select, insert, update, delete on storage.objects to anon;

drop policy if exists "username prototype can read chat messages" on public.chat_messages;
create policy "username prototype can read chat messages"
  on public.chat_messages for select
  to anon
  using (true);

drop policy if exists "username prototype can create chat messages" on public.chat_messages;
create policy "username prototype can create chat messages"
  on public.chat_messages for insert
  to anon
  with check (
    account_id is not null
    and length(trim(author_username)) >= 2
    and (length(trim(body)) > 0 or image_url is not null)
  );

drop policy if exists "username prototype can update chat messages" on public.chat_messages;
create policy "username prototype can update chat messages"
  on public.chat_messages for update
  to anon
  using (true)
  with check (
    account_id is not null
    and length(trim(author_username)) >= 2
    and (length(trim(body)) > 0 or image_url is not null)
  );

drop policy if exists "username prototype can delete chat messages" on public.chat_messages;
create policy "username prototype can delete chat messages"
  on public.chat_messages for delete
  to anon
  using (true);

drop policy if exists "username prototype can read chat reads" on public.chat_reads;
create policy "username prototype can read chat reads"
  on public.chat_reads for select
  to anon
  using (true);

drop policy if exists "username prototype can create chat reads" on public.chat_reads;
create policy "username prototype can create chat reads"
  on public.chat_reads for insert
  to anon
  with check (account_id is not null and peer_account_id is not null and account_id <> peer_account_id);

drop policy if exists "username prototype can update chat reads" on public.chat_reads;
create policy "username prototype can update chat reads"
  on public.chat_reads for update
  to anon
  using (true)
  with check (account_id is not null and peer_account_id is not null and account_id <> peer_account_id);

drop policy if exists "username prototype can delete chat reads" on public.chat_reads;
create policy "username prototype can delete chat reads"
  on public.chat_reads for delete
  to anon
  using (true);

drop policy if exists "username prototype can read chat images" on storage.objects;
create policy "username prototype can read chat images"
  on storage.objects for select
  to anon
  using (bucket_id = 'chat-images');

drop policy if exists "username prototype can upload chat images" on storage.objects;
create policy "username prototype can upload chat images"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'chat-images');

drop policy if exists "username prototype can update chat images" on storage.objects;
create policy "username prototype can update chat images"
  on storage.objects for update
  to anon
  using (bucket_id = 'chat-images')
  with check (bucket_id = 'chat-images');

drop policy if exists "username prototype can delete chat images" on storage.objects;
create policy "username prototype can delete chat images"
  on storage.objects for delete
  to anon
  using (bucket_id = 'chat-images');

commit;
