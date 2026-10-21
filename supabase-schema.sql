-- 薪序跨设备同步。请在 Supabase SQL Editor 中以项目管理员身份执行一次。
-- 客户端只使用 publishable/anon key；绝不要把 service_role/secret key 放进网页。

create table if not exists public.payroll_app_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  key_versions jsonb not null default '{}'::jsonb,
  photo_versions jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.payroll_app_state enable row level security;
grant select, insert, update, delete on public.payroll_app_state to authenticated;

drop policy if exists "Users manage own payroll app state" on public.payroll_app_state;
create policy "Users manage own payroll app state" on public.payroll_app_state
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('salary-private', 'salary-private', false, 20971520, array['image/*'])
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Users read own salary photos" on storage.objects;
create policy "Users read own salary photos" on storage.objects
  for select to authenticated
  using (bucket_id = 'salary-private' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "Users upload own salary photos" on storage.objects;
create policy "Users upload own salary photos" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'salary-private' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "Users update own salary photos" on storage.objects;
create policy "Users update own salary photos" on storage.objects
  for update to authenticated
  using (bucket_id = 'salary-private' and (storage.foldername(name))[1] = (select auth.uid()::text))
  with check (bucket_id = 'salary-private' and (storage.foldername(name))[1] = (select auth.uid()::text));

drop policy if exists "Users delete own salary photos" on storage.objects;
create policy "Users delete own salary photos" on storage.objects
  for delete to authenticated
  using (bucket_id = 'salary-private' and (storage.foldername(name))[1] = (select auth.uid()::text));

