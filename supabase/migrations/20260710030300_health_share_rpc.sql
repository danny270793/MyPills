-- share_health_folder upserts (undoing a prior unshare if re-sharing
-- with the same email); both RPCs verify the caller owns the folder
-- before touching health_folder_shares, since only the owner may
-- manage sharing.

create or replace function public.share_health_folder(p_folder_id uuid, p_email text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_is_owner boolean;
begin
  select exists (
    select 1 from public.health_folders
    where id = p_folder_id and "userId" = auth.uid() and "deletedAt" is null
  ) into v_is_owner;

  if not v_is_owner then
    return false;
  end if;

  insert into public.health_folder_shares ("folderId", "sharedByUserId", email)
  values (p_folder_id, auth.uid(), lower(trim(p_email)))
  on conflict ("folderId", email)
  do update set "deletedAt" = null, "createdAt" = now();

  return true;
end;
$$;

create or replace function public.unshare_health_folder(p_folder_id uuid, p_email text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
  v_is_owner boolean;
begin
  select exists (
    select 1 from public.health_folders
    where id = p_folder_id and "userId" = auth.uid() and "deletedAt" is null
  ) into v_is_owner;

  if not v_is_owner then
    return false;
  end if;

  update public.health_folder_shares
  set "deletedAt" = now()
  where "folderId" = p_folder_id
    and lower(email) = lower(trim(p_email))
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

revoke all on function public.share_health_folder(uuid, text) from public;
grant execute on function public.share_health_folder(uuid, text) to authenticated;

revoke all on function public.unshare_health_folder(uuid, text) from public;
grant execute on function public.unshare_health_folder(uuid, text) to authenticated;
