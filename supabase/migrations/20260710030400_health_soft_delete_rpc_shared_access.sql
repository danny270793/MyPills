-- Pills can now be deleted by any collaborator with folder access, not
-- just the pill's own creator. Folder deletion also no longer limits
-- its pill cascade to pills the folder owner personally created --
-- collaborators may have added pills the owner doesn't "own" but
-- should still be removed when the folder is.

create or replace function public.soft_delete_health_folder(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.health_folders
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;

  if n > 0 then
    update public.health_pills
    set "deletedAt" = now()
    where "folderId" = p_id
      and "deletedAt" is null;
  end if;

  return n > 0;
end;
$$;

create or replace function public.soft_delete_health_pill(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
  v_folder_id uuid;
begin
  select "folderId" into v_folder_id
  from public.health_pills
  where id = p_id and "deletedAt" is null;

  if v_folder_id is null or not public.has_health_folder_access(v_folder_id) then
    return false;
  end if;

  update public.health_pills
  set "deletedAt" = now()
  where id = p_id
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;
