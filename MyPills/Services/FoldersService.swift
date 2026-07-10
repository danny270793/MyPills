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
        try await client.insert(SupabaseConfig.foldersTable, values: NewFolder(name: name))
    }

    func rename(id: UUID, name: String) async throws -> Folder {
        try await client.update(SupabaseConfig.foldersTable, id: id, values: RenameFolder(name: name))
    }

    func delete(id: UUID) async throws {
        try await client.delete(SupabaseConfig.foldersTable, id: id)
    }
}

private struct NewFolder: Encodable {
    let name: String
}

private struct RenameFolder: Encodable {
    let name: String
}
