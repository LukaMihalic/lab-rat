-- Lab Rat: run this once in Supabase → SQL Editor → New query → Run.
-- It creates one table that stores every user's experiments, gels, protocols and assays.
-- Row Level Security makes sure each person can only see and change their own rows.

create table if not exists public.docs (
  user_id    uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  kind       text    not null,          -- experiments | gels | protocols | assays
  id         text    not null,
  data       jsonb,
  deleted    boolean not null default false,
  updated_ms bigint  not null,          -- when the item was last edited (device time)
  server_ts  timestamptz not null default now(),  -- when the server received it
  primary key (user_id, kind, id)
);

create index if not exists docs_user_server_ts on public.docs (user_id, server_ts);

create or replace function public.docs_touch() returns trigger
language plpgsql as $$
begin
  new.server_ts := now();
  return new;
end $$;

drop trigger if exists docs_touch on public.docs;
create trigger docs_touch before insert or update on public.docs
for each row execute function public.docs_touch();

alter table public.docs enable row level security;

drop policy if exists "read own"   on public.docs;
drop policy if exists "insert own" on public.docs;
drop policy if exists "update own" on public.docs;
drop policy if exists "delete own" on public.docs;
create policy "read own"   on public.docs for select using (auth.uid() = user_id);
create policy "insert own" on public.docs for insert with check (auth.uid() = user_id);
create policy "update own" on public.docs for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own" on public.docs for delete using (auth.uid() = user_id);

-- Live updates between your phone and laptop
alter publication supabase_realtime add table public.docs;
