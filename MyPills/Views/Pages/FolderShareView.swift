//
//  FolderShareView.swift
//  MyPills
//

import SwiftUI

struct FolderShareView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let folder: Folder

    @State private var email = ""
    @State private var isSharing = false

    private var shares: [FolderShare] {
        store.shares(for: folder.id)
    }

    private var isValidEmail: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Share with") {
                    HStack {
                        TextField("Email address", text: $email)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            #endif
                            .autocorrectionDisabled()

                        Button {
                            Task { await share() }
                        } label: {
                            if isSharing {
                                ProgressView()
                            } else {
                                Text("Share")
                            }
                        }
                        .disabled(!isValidEmail || isSharing)
                    }
                }

                Section("People with access") {
                    if shares.isEmpty {
                        Text("Only you can see this folder.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(shares) { share in
                            HStack {
                                Text(share.email)
                                Spacer()
                                Button(role: .destructive) {
                                    Task { await store.unshareFolder(id: folder.id, email: share.email) }
                                } label: {
                                    Image(systemName: "person.crop.circle.badge.minus")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Share Folder")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await store.loadShares(folderId: folder.id) }
        }
    }

    private func share() async {
        isSharing = true
        defer { isSharing = false }
        await store.shareFolder(id: folder.id, email: email.trimmingCharacters(in: .whitespacesAndNewlines))
        email = ""
    }
}
