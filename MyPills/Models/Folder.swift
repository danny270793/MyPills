//
//  Folder.swift
//  MyPills
//

import Foundation

struct Folder: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }
}

/// A folder plus the number of pills inside it, as returned by
/// FoldersService.fetchAll() via a PostgREST embedded count.
struct FolderSummary: Identifiable, Decodable, Hashable {
    var id: UUID
    var name: String
    var createdAt: Date
    var pillCount: Int

    var folder: Folder {
        Folder(id: id, name: name, createdAt: createdAt)
    }

    private struct PillsAggregate: Decodable, Hashable {
        let count: Int
    }

    private enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case pills
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        let aggregates = try container.decodeIfPresent([PillsAggregate].self, forKey: .pills) ?? []
        pillCount = aggregates.first?.count ?? 0
    }
}
