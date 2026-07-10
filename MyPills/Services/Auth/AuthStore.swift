//
//  AuthStore.swift
//  MyPills
//
//  UI-facing auth state. Views read isAuthenticated/isRestoringSession
//  reactively and call signIn/signUp/signOut instead of touching
//  AuthService or SessionStore directly.
//

import Foundation
import Observation

@Observable
final class AuthStore {
    private(set) var isAuthenticated = false
    private(set) var isRestoringSession = true
    private(set) var currentEmail: String?
    private(set) var currentUserId: UUID?
    var isLoading = false
    var errorMessage: String?
    var infoMessage: String?

    private let auth = AuthService.shared
    private let sessionStore = SessionStore.shared

    func restoreSession() async {
        defer { isRestoringSession = false }
        guard let session = sessionStore.session else { return }

        if session.expiresAt > Date() {
            isAuthenticated = true
            currentEmail = session.email
            currentUserId = session.userId
            return
        }

        do {
            let refreshed = try await auth.refresh(refreshToken: session.refreshToken)
            sessionStore.save(refreshed)
            isAuthenticated = true
            currentEmail = refreshed.email
            currentUserId = refreshed.userId
        } catch {
            sessionStore.clear()
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        defer { isLoading = false }

        do {
            let session = try await auth.signIn(email: email, password: password)
            sessionStore.save(session)
            currentEmail = session.email
            currentUserId = session.userId
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        defer { isLoading = false }

        do {
            if let session = try await auth.signUp(email: email, password: password) {
                sessionStore.save(session)
                currentEmail = session.email
                currentUserId = session.userId
                isAuthenticated = true
            } else {
                infoMessage = "Check your email to confirm your account, then sign in."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        if let token = sessionStore.accessToken {
            try? await auth.signOut(accessToken: token)
        }
        sessionStore.clear()
        isAuthenticated = false
        currentEmail = nil
        currentUserId = nil
    }

    @discardableResult
    func changePassword(newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        defer { isLoading = false }

        guard let token = sessionStore.accessToken else {
            errorMessage = "You need to be signed in to do that."
            return false
        }

        do {
            try await auth.updatePassword(accessToken: token, newPassword: newPassword)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
