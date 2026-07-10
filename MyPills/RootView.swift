//
//  RootView.swift
//  MyPills
//

import SwiftUI

struct RootView: View {
    @Environment(AuthStore.self) private var auth

    var body: some View {
        Group {
            if auth.isRestoringSession {
                ProgressView()
            } else if auth.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        }
        .task { await auth.restoreSession() }
    }
}

#Preview {
    RootView()
        .environment(AuthStore())
        .environment(AppStore())
}
