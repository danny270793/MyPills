//
//  FolderFormView.swift
//  MyPills
//

import SwiftUI

struct FolderFormView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    /// Folder being edited, or nil when creating a new one.
    var folder: Folder?

    @State private var name: String = ""
    @State private var isSaving = false

    private var isEditing: Bool { folder != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Folder" : "New Folder")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .onAppear(perform: loadExistingFolder)
            .disabled(isSaving)
        }
    }

    private func loadExistingFolder() {
        guard let folder else { return }
        name = folder.name
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let folder {
            await store.renameFolder(id: folder.id, name: trimmedName)
        } else {
            await store.createFolder(name: trimmedName)
        }

        dismiss()
    }
}

#Preview("New Folder") {
    FolderFormView(folder: nil)
        .environment(AppStore())
}

#Preview("Edit Folder") {
    FolderFormView(folder: Folder(
        id: UUID(),
        userId: UUID(),
        name: "Daily Vitamins",
        createdAt: .now,
        updatedAt: .now,
        deletedAt: nil
    ))
    .environment(AppStore())
}
