create table if not exists public.payroll_entries (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  month text not null check (month ~ '^\d{4}-\d{2}$'),
  kind text not null check (kind in ('work', 'shoot', 'camera')),
  amount numeric(12,2) not null check (amount >= 0),
  entry_time timestamptz not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.payroll_deletions (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  deleted_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.payroll_entries enable row level security;
alter table public.payroll_deletions enable row level security;
grant select, insert, update, delete on public.payroll_entries to authenticated;
grant select, insert, update, delete on public.payroll_deletions to authenticated;

drop policy if exists "Users manage own payroll entries" on public.payroll_entries;
create policy "Users manage own payroll entries" on public.payroll_entries
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users manage own payroll deletions" on public.payroll_deletions;
create policy "Users manage own payroll deletions" on public.payroll_deletions
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
