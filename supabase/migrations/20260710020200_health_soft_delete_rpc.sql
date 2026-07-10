-- Soft-delete via SECURITY DEFINER so it succeeds even when UPDATE RLS policies
-- (e.g. WITH CHECK on deletedAt) block direct client updates.
--
-- Deleting a folder must also soft-delete the pills inside it: a plain
-- "on delete cascade" FK only fires on a hard DELETE, not on this UPDATE,
-- so the cascade is done explicitly here.

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
      and "userId" = auth.uid()
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
begin
  update public.health_pills
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

revoke all on function public.soft_delete_health_folder(uuid) from public;
grant execute on function public.soft_delete_health_folder(uuid) to authenticated;

revoke all on function public.soft_delete_health_pill(uuid) from public;
grant execute on function public.soft_delete_health_pill(uuid) to authenticated;
