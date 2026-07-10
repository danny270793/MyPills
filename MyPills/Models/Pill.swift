//
//  Pill.swift
//  MyPills
//

import Foundation
import SwiftData

@Model
final class Pill {
    // Every stored property needs a default value (or must be Optional) for
    // SwiftData's CloudKit schema validation to accept the model.
    var name: String = ""
    var details: String = ""
    var photo: Data?
    var quantity: Int = 1
    var price: Double = 0
    var createdAt: Date = Date.now
    var folder: Folder?

    init(
        name: String = "",
        details: String = "",
        photo: Data? = nil,
        quantity: Int = 1,
        price: Double = 0,
        createdAt: Date = .now,
        folder: Folder? = nil
    ) {
        self.name = name
        self.details = details
        self.photo = photo
        self.quantity = quantity
        self.price = price
        self.createdAt = createdAt
        self.folder = folder
    }
}
