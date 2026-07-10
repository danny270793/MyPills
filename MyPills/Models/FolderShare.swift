//
//  FolderShare.swift
//  MyPills
//

import Foundation

struct FolderShare: Identifiable, Decodable, Hashable {
    var id: UUID
    var folderId: UUID
    var sharedByUserId: UUID
    var email: String
    var createdAt: Date
}
