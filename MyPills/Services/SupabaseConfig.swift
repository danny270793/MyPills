//
//  SupabaseConfig.swift
//  MyPills
//
//  Schema lives in supabase/migrations/ (health_folders, health_pills,
//  health_folder_shares, and their RPCs) — run `supabase db push` to
//  apply it. Folders/pills use a "userId" ownership column and soft
//  delete via "deletedAt" (rows are never hard-deleted; see
//  soft_delete_health_folder / soft_delete_health_pill). Folders can
//  also be shared by email via health_folder_shares — see
//  has_health_folder_access / share_health_folder / unshare_health_folder.
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
    static let folderSharesTable = "health_folder_shares"
}
