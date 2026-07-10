//
//  Session.swift
//  MyPills
//

import Foundation

struct Session: Codable {
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date
    var userId: UUID
    var email: String
}
