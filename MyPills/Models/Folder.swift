//
//  Folder.swift
//  MyPills
//

import Foundation
import SwiftData

@Model
final class Folder {
    var name: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Pill.folder)
    var pills: [Pill] = []

    init(name: String = "", createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}
