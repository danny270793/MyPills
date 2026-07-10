//
//  Pill.swift
//  MyPills
//

import Foundation

struct Pill: Identifiable, Codable, Hashable {
    var id: UUID
    var userId: UUID
    var folderId: UUID
    var name: String
    var details: String
    var photoBase64: String?
    var quantity: Int
    var price: Double
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var photo: Data? {
        photoBase64.flatMap { Data(base64Encoded: $0) }
    }
}

/// The editable fields of a Pill, used when creating or updating one.
struct PillDraft {
    var name: String
    var details: String
    var photo: Data?
    var quantity: Int
    var price: Double
}
