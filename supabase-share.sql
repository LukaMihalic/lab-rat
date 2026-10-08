-- Lab Rat: share a project read-only with a link (e.g. with your mentor).
-- Run this once in Supabase → SQL Editor → New query → Run. It is safe to run again.
--
-- The owner's app keeps a read-only copy (snapshot) of the shared project here.
-- Anyone with the link can view that copy; nobody can change it. Stop sharing deletes it.

create table if not exists public.project_shares (
  token       text primary key,                       -- the secret part of the link
  owner       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  owner_email text,
  project     text not null,
  snapshot    jsonb,
  updated_at  timestamptz not null default now(),
  created_at  timestamptz not null default now(),
  unique (owner, project)
);

alter table public.project_shares enable row level security;

drop policy if exists "shares: owner reads"   on public.project_shares;
drop policy if exists "shares: owner adds"    on public.project_shares;
drop policy if exists "shares: owner changes" on public.project_shares;
drop policy if exists "shares: owner removes" on public.project_shares;
create policy "shares: owner reads"   on public.project_shares for select using (owner = auth.uid());
create policy "shares: owner adds"    on public.project_shares for insert with check (owner = auth.uid());
create policy "shares: owner changes" on public.project_shares for update using (owner = auth.uid()) with check (owner = auth.uid());
create policy "shares: owner removes" on public.project_shares for delete using (owner = auth.uid());

-- viewers read one shared project by its token, without an account
create or replace function public.get_shared_project(t text) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('project', s.project, 'by', s.owner_email, 'updated', s.updated_at, 'snapshot', s.snapshot)
    from public.project_shares s
   where s.token = t and length(t) >= 20
$$;
revoke all on function public.get_shared_project(text) from public;
grant execute on function public.get_shared_project(text) to anon, authenticated;
