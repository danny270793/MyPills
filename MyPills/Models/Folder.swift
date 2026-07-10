//
//  Folder.swift
//  MyPills
//

import Foundation

struct Folder: Identifiable, Codable, Hashable {
    var id: UUID
    var userId: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}

/// A folder plus the number of pills inside it, as returned by
/// FoldersService.fetchAll() via a PostgREST embedded count.
struct FolderSummary: Identifiable, Decodable, Hashable {
    var id: UUID
    var userId: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var pillCount: Int

    var folder: Folder {
        Folder(id: id, userId: userId, name: name, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }

    private struct PillsAggregate: Decodable, Hashable {
        let count: Int
    }

    private enum CodingKeys: String, CodingKey {
        case id, userId, name, createdAt, updatedAt, deletedAt
        // Embedded resource key matches the pills table name (SupabaseConfig.pillsTable);
        // update this literal if you rename that table.
        case pillsAggregate = "health_pills"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        let aggregates = try container.decodeIfPresent([PillsAggregate].self, forKey: .pillsAggregate) ?? []
        pillCount = aggregates.first?.count ?? 0
    }
}
