-- Lab Rat: shared lab storage (where each chemical is kept).
-- Run this once in Supabase → SQL Editor → New query → Run. It is safe to run again.
-- Everyone who knows a lab's code can join that lab; members of a lab can read and edit its list.
-- Your own experiments, gels and notes (the "docs" table) stay private as before.

create table if not exists public.labs (
  code       text primary key,                       -- e.g. ABCD-1234, shared with colleagues
  name       text not null,
  created_by uuid not null default auth.uid() references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.lab_members (
  lab_code  text not null references public.labs(code) on delete cascade,
  user_id   uuid not null default auth.uid() references auth.users(id) on delete cascade,
  email     text,
  joined_at timestamptz not null default now(),
  primary key (lab_code, user_id)
);

create table if not exists public.inventory (
  lab_code      text   not null references public.labs(code) on delete cascade,
  id            text   not null,
  data          jsonb,
  deleted       boolean not null default false,
  updated_ms    bigint not null,
  updated_by    uuid   default auth.uid(),
  updated_email text,
  server_ts     timestamptz not null default now(),
  primary key (lab_code, id)
);

-- membership check used by the policies (security definer avoids policy recursion)
create or replace function public.is_lab_member(c text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.lab_members m where m.lab_code = c and m.user_id = auth.uid())
$$;

create or replace function public.inventory_touch() returns trigger
language plpgsql as $$
begin
  new.server_ts := now();
  new.updated_by := auth.uid();
  return new;
end $$;
drop trigger if exists inventory_touch on public.inventory;
create trigger inventory_touch before insert or update on public.inventory
for each row execute function public.inventory_touch();

alter table public.labs        enable row level security;
alter table public.lab_members enable row level security;
alter table public.inventory   enable row level security;

drop policy if exists "labs: members read"   on public.labs;
drop policy if exists "labs: create"         on public.labs;
drop policy if exists "labs: members rename" on public.labs;
create policy "labs: members read"   on public.labs for select using (public.is_lab_member(code) or created_by = auth.uid());
create policy "labs: create"         on public.labs for insert with check (auth.uid() is not null and created_by = auth.uid());
create policy "labs: members rename" on public.labs for update using (public.is_lab_member(code)) with check (public.is_lab_member(code));

drop policy if exists "members: see lab"  on public.lab_members;
drop policy if exists "members: join"     on public.lab_members;
drop policy if exists "members: leave"    on public.lab_members;
create policy "members: see lab" on public.lab_members for select using (public.is_lab_member(lab_code));
create policy "members: join"    on public.lab_members for insert with check (user_id = auth.uid());
create policy "members: leave"   on public.lab_members for delete using (user_id = auth.uid());

drop policy if exists "inventory: read"   on public.inventory;
drop policy if exists "inventory: add"    on public.inventory;
drop policy if exists "inventory: change" on public.inventory;
create policy "inventory: read"   on public.inventory for select using (public.is_lab_member(lab_code));
create policy "inventory: add"    on public.inventory for insert with check (public.is_lab_member(lab_code));
create policy "inventory: change" on public.inventory for update using (public.is_lab_member(lab_code)) with check (public.is_lab_member(lab_code));

-- live updates when a colleague changes something
do $$ begin
  alter publication supabase_realtime add table public.inventory;
exception when duplicate_object then null; end $$;
