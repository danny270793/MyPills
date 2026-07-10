-- Extend read access to shared folders/pills. Folder rename/delete
-- stays owner-only (see health_folders' update policy, unchanged);
-- pill CRUD is allowed for anyone with folder access, not just the
-- folder owner or the pill's own creator.

drop policy if exists "users can select own folders" on public.health_folders;

create policy "users can select accessible folders"
  on public.health_folders for select
  using (public.has_health_folder_access(id));

drop policy if exists "users can select own pills" on public.health_pills;
drop policy if exists "users can insert own pills" on public.health_pills;
drop policy if exists "users can update own pills" on public.health_pills;

create policy "users can select accessible pills"
  on public.health_pills for select
  using (public.has_health_folder_access("folderId") and "deletedAt" is null);

create policy "users can insert pills into accessible folders"
  on public.health_pills for insert
  with check (public.has_health_folder_access("folderId") and "userId" = auth.uid());

create policy "users can update pills in accessible folders"
  on public.health_pills for update
  using (public.has_health_folder_access("folderId"))
  with check (public.has_health_folder_access("folderId"));
