//
//  PillsService.swift
//  MyPills
//

import Foundation

struct PillsService {
    static let shared = PillsService()

    private let client = SupabaseClient.shared

    func fetchAll(folderId: UUID) async throws -> [Pill] {
        try await client.fetch(
            SupabaseConfig.pillsTable,
            query: [
                URLQueryItem(name: "folder_id", value: "eq.\(folderId.uuidString)"),
                URLQueryItem(name: "order", value: "name.asc"),
            ]
        )
    }

    func create(_ draft: PillDraft, folderId: UUID) async throws -> Pill {
        let payload = PillPayload(
            folderId: folderId,
            name: draft.name,
            details: draft.details,
            photoBase64: draft.photo?.base64EncodedString(),
            quantity: draft.quantity,
            price: draft.price
        )
        return try await client.insert(SupabaseConfig.pillsTable, values: payload)
    }

    func update(id: UUID, draft: PillDraft, folderId: UUID) async throws -> Pill {
        let payload = PillPayload(
            folderId: folderId,
            name: draft.name,
            details: draft.details,
            photoBase64: draft.photo?.base64EncodedString(),
            quantity: draft.quantity,
            price: draft.price
        )
        return try await client.update(SupabaseConfig.pillsTable, id: id, values: payload)
    }

    func delete(id: UUID) async throws {
        try await client.delete(SupabaseConfig.pillsTable, id: id)
    }
}

private struct PillPayload: Encodable {
    let folderId: UUID
    let name: String
    let details: String
    let photoBase64: String?
    let quantity: Int
    let price: Double

    enum CodingKeys: String, CodingKey {
        case folderId = "folder_id"
        case name, details
        case photoBase64 = "photo_base64"
        case quantity, price
    }
}
