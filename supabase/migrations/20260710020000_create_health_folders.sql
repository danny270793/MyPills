create table public.health_folders (
  id          uuid primary key default gen_random_uuid(),
  "userId"    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now(),
  "deletedAt" timestamptz
);

create trigger health_folders_set_updated_at
  before update on public.health_folders
  for each row execute function public.set_updated_at();

create index health_folders_user_id_idx on public.health_folders ("userId");
create index health_folders_deleted_at_idx on public.health_folders ("deletedAt");

alter table public.health_folders enable row level security;

create policy "users can select own folders"
  on public.health_folders for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own folders"
  on public.health_folders for insert
  with check (auth.uid() = "userId");

create policy "users can update own folders"
  on public.health_folders for update
  using (auth.uid() = "userId")
  with check (auth.uid() = "userId");
