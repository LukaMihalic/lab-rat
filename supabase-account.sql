-- Lab Rat: lets a person delete their own account and everything that belongs to it.
-- Run this once in Supabase → SQL Editor → New query → Run. It is safe to run again.
--
-- What "Delete my account" removes:
--   • all of their experiments, recipes, notes, images (table docs)
--   • their membership in shared labs; a lab they created passes to the next member,
--     or is removed (with its storage list) if nobody else is in it
--   • their email on shared storage items (replaced with "deleted user")
--   • the login itself (auth.users)

create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
declare
  me    uuid := auth.uid();
  mail  text;
begin
  if me is null then raise exception 'Not signed in'; end if;
  select email into mail from auth.users where id = me;

  -- labs this person created: hand over to the longest-standing other member, otherwise remove
  update public.labs l
     set created_by = (select m.user_id from public.lab_members m
                        where m.lab_code = l.code and m.user_id <> me
                        order by m.joined_at limit 1)
   where l.created_by = me
     and exists (select 1 from public.lab_members m where m.lab_code = l.code and m.user_id <> me);
  delete from public.labs where created_by = me;
  delete from public.lab_members where user_id = me;

  -- shared storage items keep existing for the lab, without this person's email
  if mail is not null and length(mail) > 3 then
    update public.inventory
       set updated_email = case when updated_email = mail then null else updated_email end,
           data = replace(data::text, mail, 'deleted user')::jsonb
     where updated_email = mail or data::text like '%' || mail || '%';
  end if;

  delete from public.docs where user_id = me;
  delete from auth.users where id = me;
end $$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
