//
//  Pill.swift
//  MyPills
//

import Foundation
import SwiftData

@Model
final class Pill {
    var name: String
    var details: String
    var photo: Data?
    var quantity: Int
    var price: Double
    var createdAt: Date

    init(
        name: String = "",
        details: String = "",
        photo: Data? = nil,
        quantity: Int = 1,
        price: Double = 0,
        createdAt: Date = .now
    ) {
        self.name = name
        self.details = details
        self.photo = photo
        self.quantity = quantity
        self.price = price
        self.createdAt = createdAt
    }
}
