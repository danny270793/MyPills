-- Central "does the current user have access to this folder" check:
-- true if they own it, or it's been shared with their JWT email.
-- SECURITY DEFINER so it can read health_folder_shares regardless of
-- that table's own RLS (which only exposes rows to the folder owner).

create or replace function public.has_health_folder_access(p_folder_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.health_folders f
    where f.id = p_folder_id
      and f."deletedAt" is null
      and (
        f."userId" = auth.uid()
        or exists (
          select 1
          from public.health_folder_shares s
          where s."folderId" = f.id
            and s."deletedAt" is null
            and lower(s.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
        )
      )
  );
$$;

revoke all on function public.has_health_folder_access(uuid) from public;
grant execute on function public.has_health_folder_access(uuid) to authenticated;
