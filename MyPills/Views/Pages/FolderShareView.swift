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
            Group {
                if !store.hasLoadedShares(for: folder.id) {
                    ProgressView()
                } else {
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
                                    Text(share.email)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                Task { await store.unshareFolder(id: folder.id, email: share.email) }
                                            } label: {
                                                Label("Remove", systemImage: "person.crop.circle.badge.minus")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .formStyle(.grouped)
                }
            }
            .navigationTitle("Share Folder")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .refreshable { await store.loadShares(folderId: folder.id) }
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

#Preview {
    FolderShareView(folder: Folder(
        id: UUID(),
        userId: UUID(),
        name: "Daily Vitamins",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil
    ))
    .environment(AppStore())
}
