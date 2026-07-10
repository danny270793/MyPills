-- Lets a folder owner grant other users (by email) access to a folder
-- and its pills. Matching is done against the invitee's own email
-- claim at query time (see has_health_folder_access), so sharing
-- works even before the invitee has an account.

create table public.health_folder_shares (
  id               uuid primary key default gen_random_uuid(),
  "folderId"       uuid not null references public.health_folders(id) on delete cascade,
  "sharedByUserId" uuid not null references auth.users(id) on delete cascade,
  email            text not null,
  "createdAt"      timestamptz not null default now(),
  "deletedAt"      timestamptz,
  unique ("folderId", email)
);

create index health_folder_shares_folder_id_idx on public.health_folder_shares ("folderId");
create index health_folder_shares_email_idx on public.health_folder_shares (lower(email));
create index health_folder_shares_deleted_at_idx on public.health_folder_shares ("deletedAt");

alter table public.health_folder_shares enable row level security;

create policy "folder owner can view shares"
  on public.health_folder_shares for select
  using (
    exists (
      select 1 from public.health_folders f
      where f.id = "folderId" and f."userId" = auth.uid()
    )
  );

create policy "folder owner can create shares"
  on public.health_folder_shares for insert
  with check (
    "sharedByUserId" = auth.uid()
    and exists (
      select 1 from public.health_folders f
      where f.id = "folderId" and f."userId" = auth.uid()
    )
  );

create policy "folder owner can update shares"
  on public.health_folder_shares for update
  using (
    exists (
      select 1 from public.health_folders f
      where f.id = "folderId" and f."userId" = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.health_folders f
      where f.id = "folderId" and f."userId" = auth.uid()
    )
  );
