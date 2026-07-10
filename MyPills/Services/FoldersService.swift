//
//  FoldersService.swift
//  MyPills
//

import Foundation

struct FoldersService {
    static let shared = FoldersService()

    private let client = SupabaseClient.shared

    func fetchAll() async throws -> [FolderSummary] {
        try await client.fetch(
            SupabaseConfig.foldersTable,
            query: [
                URLQueryItem(name: "select", value: "*,\(SupabaseConfig.pillsTable)(count)"),
                URLQueryItem(name: "order", value: "name.asc"),
            ]
        )
    }

    func create(name: String) async throws -> Folder {
        guard let userId = SessionStore.shared.session?.userId else {
            throw SupabaseError.notAuthenticated
        }
        return try await client.insert(SupabaseConfig.foldersTable, values: NewFolder(userId: userId, name: name))
    }

    func rename(id: UUID, name: String) async throws -> Folder {
        try await client.update(SupabaseConfig.foldersTable, id: id, values: RenameFolder(name: name))
    }

    func delete(id: UUID) async throws {
        let succeeded = try await client.rpc("soft_delete_health_folder", params: ["p_id": id.uuidString])
        guard succeeded else { throw SupabaseError.invalidResponse }
    }

    func shares(folderId: UUID) async throws -> [FolderShare] {
        try await client.fetch(
            SupabaseConfig.folderSharesTable,
            query: [
                URLQueryItem(name: "folderId", value: "eq.\(folderId.uuidString)"),
                URLQueryItem(name: "deletedAt", value: "is.null"),
                URLQueryItem(name: "order", value: "createdAt.asc"),
            ]
        )
    }

    func share(folderId: UUID, email: String) async throws {
        let succeeded = try await client.rpc(
            "share_health_folder",
            params: ["p_folder_id": folderId.uuidString, "p_email": email]
        )
        guard succeeded else { throw SupabaseError.invalidResponse }
    }

    func unshare(folderId: UUID, email: String) async throws {
        let succeeded = try await client.rpc(
            "unshare_health_folder",
            params: ["p_folder_id": folderId.uuidString, "p_email": email]
        )
        guard succeeded else { throw SupabaseError.invalidResponse }
    }
}

private struct NewFolder: Encodable {
    let userId: UUID
    let name: String
}

private struct RenameFolder: Encodable {
    let name: String
}
