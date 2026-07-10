//
//  SessionStore.swift
//  MyPills
//
//  Holds the current Supabase session in memory and persists it to the
//  Keychain. SupabaseClient reads accessToken from here to authenticate
//  PostgREST requests as the signed-in user.
//

import Foundation

final class SessionStore: @unchecked Sendable {
    static let shared = SessionStore()

    private(set) var session: Session?

    private init() {
        session = Self.loadFromKeychain()
    }

    var accessToken: String? {
        session?.accessToken
    }

    func save(_ session: Session) {
        self.session = session
        if let data = try? JSONEncoder().encode(session) {
            KeychainStore.save(data)
        }
    }

    func clear() {
        session = nil
        KeychainStore.delete()
    }

    private static func loadFromKeychain() -> Session? {
        guard let data = KeychainStore.load() else { return nil }
        return try? JSONDecoder().decode(Session.self, from: data)
    }
}
