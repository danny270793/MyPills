//
//  SupabaseClient.swift
//  MyPills
//
//  A minimal PostgREST client for Supabase, built on URLSession so the
//  app doesn't need the supabase-swift package as a dependency.
//

import Foundation

enum SupabaseError: LocalizedError {
    case invalidResponse
    case requestFailed(status: Int, body: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .requestFailed(let status, let body):
            return "Request failed (\(status)): \(body)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

struct SupabaseClient {
    static let shared = SupabaseClient()

    private let session: URLSession = .shared

    func fetch<T: Decodable>(_ table: String, query: [URLQueryItem]) async throws -> [T] {
        let request = makeRequest(table: table, id: nil, query: query, method: "GET")
        return try await send(request)
    }

    func insert<Payload: Encodable, Response: Decodable>(_ table: String, values: Payload) async throws -> Response {
        var request = makeRequest(table: table, id: nil, query: [], method: "POST")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try Self.encoder.encode(values)
        let results: [Response] = try await send(request)
        guard let first = results.first else { throw SupabaseError.invalidResponse }
        return first
    }

    func update<Payload: Encodable, Response: Decodable>(_ table: String, id: UUID, values: Payload) async throws -> Response {
        var request = makeRequest(table: table, id: id, query: [], method: "PATCH")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try Self.encoder.encode(values)
        let results: [Response] = try await send(request)
        guard let first = results.first else { throw SupabaseError.invalidResponse }
        return first
    }

    func delete(_ table: String, id: UUID) async throws {
        let request = makeRequest(table: table, id: id, query: [], method: "DELETE")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SupabaseError.requestFailed(status: httpResponse.statusCode, body: String(data: data, encoding: .utf8) ?? "")
        }
    }

    private func makeRequest(table: String, id: UUID?, query: [URLQueryItem], method: String) -> URLRequest {
        var components = URLComponents(
            url: SupabaseConfig.url.appendingPathComponent("rest/v1/\(table)"),
            resolvingAgainstBaseURL: false
        )!
        var items = query
        if let id {
            items.append(URLQueryItem(name: "id", value: "eq.\(id.uuidString)"))
        }
        components.queryItems = items.isEmpty ? nil : items

        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        // Authenticate as the signed-in user (not just the anon key) so
        // row-level security policies can key off auth.uid().
        let accessToken = SessionStore.shared.accessToken ?? SupabaseConfig.anonKey
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SupabaseError.requestFailed(status: httpResponse.statusCode, body: String(data: data, encoding: .utf8) ?? "")
        }
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch {
            throw SupabaseError.decodingFailed(error)
        }
    }

    private static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = iso8601WithFractionalSeconds.date(from: string) ?? iso8601.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        return decoder
    }()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(iso8601WithFractionalSeconds.string(from: date))
        }
        return encoder
    }()
}
