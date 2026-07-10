//
//  ProfileView.swift
//  MyPills
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthStore.self) private var auth
    @State private var showingSignOutConfirm = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(auth.currentEmail ?? "Unknown")
                            .font(.headline)
                        Text("Signed in")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Account") {
                LabeledContent("Email", value: auth.currentEmail ?? "—")
                if let userId = auth.currentUserId {
                    LabeledContent("User ID", value: userId.uuidString)
                        .textSelection(.enabled)
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
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(AuthStore())
    }
}
