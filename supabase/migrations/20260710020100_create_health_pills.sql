create table public.health_pills (
  id            uuid primary key default gen_random_uuid(),
  "userId"      uuid not null references auth.users(id) on delete cascade,
  "folderId"    uuid not null references public.health_folders(id) on delete cascade,
  name          text not null,
  details       text not null default '',
  "photoBase64" text,
  quantity      integer not null default 1,
  price         double precision not null default 0,
  "createdAt"   timestamptz not null default now(),
  "updatedAt"   timestamptz not null default now(),
  "deletedAt"   timestamptz
);

create trigger health_pills_set_updated_at
  before update on public.health_pills
  for each row execute function public.set_updated_at();

create index health_pills_user_id_idx on public.health_pills ("userId");
create index health_pills_folder_id_idx on public.health_pills ("folderId");
create index health_pills_deleted_at_idx on public.health_pills ("deletedAt");

alter table public.health_pills enable row level security;

create policy "users can select own pills"
  on public.health_pills for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own pills"
  on public.health_pills for insert
  with check (auth.uid() = "userId");

create policy "users can update own pills"
  on public.health_pills for update
  using (auth.uid() = "userId")
  with check (auth.uid() = "userId");
