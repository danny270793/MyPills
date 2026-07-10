//
//  RootView.swift
//  MyPills
//

import SwiftUI

struct RootView: View {
    @Environment(AuthStore.self) private var auth

    private var isLoginPresented: Binding<Bool> {
        Binding(
            get: { !auth.isRestoringSession && !auth.isAuthenticated },
            set: { _ in }
        )
    }

    var body: some View {
        Group {
            if auth.isRestoringSession {
                ProgressView()
            } else if auth.isAuthenticated {
                ContentView()
            } else {
                WelcomeView()
            }
        }
        .task { await auth.restoreSession() }
        .sheet(isPresented: isLoginPresented) {
            LoginView()
                .interactiveDismissDisabled()
                #if os(iOS)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                #endif
        }
    }
}

#Preview {
    RootView()
        .environment(AuthStore())
        .environment(AppStore())
}
