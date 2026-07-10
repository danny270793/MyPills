//
//  ProfileView.swift
//  MyPills
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthStore.self) private var auth
    @State private var showingSignOutConfirm = false
    @State private var showingChangePassword = false

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Email", value: auth.currentEmail ?? "—")
                Button {
                    showingChangePassword = true
                } label: {
                    Label("Change Password", systemImage: "lock.rotation")
                }
            }

            Section {
                Button(role: .destructive) {
                    showingSignOutConfirm = true
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .confirmationDialog(
            "Sign out of My Pills?",
            isPresented: $showingSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task { await auth.signOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthStore())
    }
}
