//
//  AuthService.swift
//  MyPills
//
//  Talks to Supabase's GoTrue REST API (auth/v1) for email/password
//  sign in, sign up, refresh, and sign out.
//

import Foundation

struct AuthService {
    static let shared = AuthService()

    private let session: URLSession = .shared

    func signIn(email: String, password: String) async throws -> Session {
        let request = try makeTokenRequest(grantType: "password", body: ["email": email, "password": password])
        guard let session = try await send(request) else {
            throw SupabaseError.invalidResponse
        }
        return session
    }

    /// Returns nil when the project requires email confirmation before a
    /// session can be issued.
    func signUp(email: String, password: String) async throws -> Session? {
        var request = makeRequest(path: "signup")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])
        return try await send(request)
    }

    func refresh(refreshToken: String) async throws -> Session {
        let request = try makeTokenRequest(grantType: "refresh_token", body: ["refresh_token": refreshToken])
        guard let session = try await send(request) else {
            throw SupabaseError.invalidResponse
        }
        return session
    }

    func signOut(accessToken: String) async throws {
        var request = makeRequest(path: "logout")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        await DevNetworkDelay.simulate()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw SupabaseError.requestFailed(status: status, body: String(data: data, encoding: .utf8) ?? "")
        }
    }

    func updatePassword(accessToken: String, newPassword: String) async throws {
        var request = makeRequest(path: "user")
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(["password": newPassword])

        await DevNetworkDelay.simulate()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = (try? JSONDecoder().decode(AuthErrorBody.self, from: data))?.message
                ?? String(data: data, encoding: .utf8)
                ?? ""
            throw SupabaseError.requestFailed(status: httpResponse.statusCode, body: body)
        }
    }

    private func makeTokenRequest(grantType: String, body: [String: String]) throws -> URLRequest {
        var request = makeRequest(path: "token", query: [URLQueryItem(name: "grant_type", value: grantType)])
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func makeRequest(path: String, query: [URLQueryItem] = []) -> URLRequest {
        var components = URLComponents(
            url: SupabaseConfig.url.appendingPathComponent("auth/v1/\(path)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = query.isEmpty ? nil : query

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func send(_ request: URLRequest) async throws -> Session? {
        await DevNetworkDelay.simulate()
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = (try? JSONDecoder().decode(AuthErrorBody.self, from: data))?.message
                ?? String(data: data, encoding: .utf8)
                ?? ""
            throw SupabaseError.requestFailed(status: httpResponse.statusCode, body: body)
        }

        let payload = try JSONDecoder().decode(AuthTokenResponse.self, from: data)
        guard let accessToken = payload.accessToken,
              let refreshToken = payload.refreshToken,
              let expiresIn = payload.expiresIn,
              let user = payload.user else {
            // Session not issued yet, e.g. email confirmation is required.
            return nil
        }

        return Session(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(expiresIn)),
            userId: user.id,
            email: user.email
        )
    }
}

private struct AuthTokenResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    let user: AuthUser?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }

    struct AuthUser: Decodable {
        let id: UUID
        let email: String
    }
}

private struct AuthErrorBody: Decodable {
    let msg: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case msg
        case errorDescription = "error_description"
    }

    var message: String? { errorDescription ?? msg }
}
