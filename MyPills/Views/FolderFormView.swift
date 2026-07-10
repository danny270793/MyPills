//
//  FolderFormView.swift
//  MyPills
//

import SwiftUI
import SwiftData

struct FolderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Folder being edited, or nil when creating a new one.
    var folder: Folder?

    @State private var name: String = ""

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
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExistingFolder)
        }
    }

    private func loadExistingFolder() {
        guard let folder else { return }
        name = folder.name
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let folder {
            folder.name = trimmedName
        } else {
            modelContext.insert(Folder(name: trimmedName))
        }

        dismiss()
    }
}
