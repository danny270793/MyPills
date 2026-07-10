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
                URLQueryItem(name: "folderId", value: "eq.\(folderId.uuidString)"),
                URLQueryItem(name: "order", value: "name.asc"),
            ]
        )
    }

    func create(_ draft: PillDraft, folderId: UUID) async throws -> Pill {
        guard let userId = SessionStore.shared.session?.userId else {
            throw SupabaseError.notAuthenticated
        }
        let payload = PillPayload(
            userId: userId,
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
        guard let userId = SessionStore.shared.session?.userId else {
            throw SupabaseError.notAuthenticated
        }
        let payload = PillPayload(
            userId: userId,
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
        let succeeded = try await client.rpc("soft_delete_health_pill", params: ["p_id": id.uuidString])
        guard succeeded else { throw SupabaseError.invalidResponse }
    }
}

private struct PillPayload: Encodable {
    let userId: UUID
    let folderId: UUID
    let name: String
    let details: String
    let photoBase64: String?
    let quantity: Int
    let price: Double
}
