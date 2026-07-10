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
//  -- The app now signs users in (see AuthStore/LoginView) and sends
//  -- their access token on every request, so policies can require
//  -- auth.role() = 'authenticated' instead of leaving the anon key
//  -- wide open. This still shares one pool of folders/pills across
//  -- every signed-in user:
//  create policy "authenticated full access" on public.folders
//    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
//  create policy "authenticated full access" on public.pills
//    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
//
//  -- For real per-user data isolation instead, add a user_id column to
//  -- both tables (uuid references auth.users(id) default auth.uid())
//  -- and scope policies to `user_id = auth.uid()`.
//

import Foundation

enum SupabaseConfig {
    /// Your Supabase project URL, e.g. https://xyzcompany.supabase.co
    static let url = URL(string: "https://fjlxyavrbpfwmckwfelc.supabase.co")!

    /// Project Settings -> API -> anon/public key.
    static let anonKey = "sb_publishable_mvkjiWstk1rKs-BZ0jIldg_jNwt3Lpy"

    /// Table names, in case they differ from the schema above.
    static let foldersTable = "health_folders"
    static let pillsTable = "health_pills"
}
