//
//  SupabaseConfig.swift
//  MyPills
//
//  Expected schema (run in the Supabase SQL editor):
//
//  create table if not exists public.folders (
//    id uuid primary key default gen_random_uuid(),
//    name text not null,
//    created_at timestamptz not null default now()
//  );
//
//  create table if not exists public.pills (
//    id uuid primary key default gen_random_uuid(),
//    folder_id uuid not null references public.folders(id) on delete cascade,
//    name text not null,
//    details text not null default '',
//    photo_base64 text,
//    quantity integer not null default 1,
//    price double precision not null default 0,
//    created_at timestamptz not null default now()
//  );
//
//  alter table public.folders enable row level security;
//  alter table public.pills enable row level security;
//
//  -- Permissive demo policies so the anon key can read/write. Replace
//  -- with policies scoped to an authenticated user before shipping.
//  create policy "anon full access" on public.folders for all using (true) with check (true);
//  create policy "anon full access" on public.pills for all using (true) with check (true);
//

import Foundation

enum SupabaseConfig {
    /// Your Supabase project URL, e.g. https://xyzcompany.supabase.co
    static let url = URL(string: "https://YOUR_PROJECT.supabase.co")!

    /// Project Settings -> API -> anon/public key.
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"

    /// Table names, in case they differ from the schema above.
    static let foldersTable = "folders"
    static let pillsTable = "pills"
}
