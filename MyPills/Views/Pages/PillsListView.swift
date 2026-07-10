//
//  PillsListView.swift
//  MyPills
//

import SwiftUI

struct PillsListView: View {
    @Environment(AppStore.self) private var store
    @Environment(AuthStore.self) private var auth
    @Environment(\.dismiss) private var dismiss

    let folder: Folder

    @State private var showingAddPill = false
    @State private var showingEditFolder = false
    @State private var showingShareFolder = false
    @State private var showingDeleteConfirm = false
    @State private var searchText = ""

    private var isOwner: Bool {
        if(auth.currentUserId == nil) {
            return true
        }
        return folder.userId == auth.currentUserId
    }

    private var currentName: String {
        store.folderSummaries.first(where: { $0.id == folder.id })?.name ?? folder.name
    }

    private var sortedPills: [Pill] {
        store.pills(for: folder.id).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private var filteredPills: [Pill] {
        guard !searchText.isEmpty else { return sortedPills }
        return sortedPills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if sortedPills.isEmpty {
                ContentUnavailableView(
                    "No Pills Yet",
                    systemImage: "pills",
                    description: Text("Tap the + button to add a pill to this folder.")
                )
            } else if filteredPills.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    ForEach(filteredPills) { pill in
                        NavigationLink(value: pill) {
                            PillRow(pill: pill)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await store.deletePill(id: pill.id, folderId: folder.id) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle(currentName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(for: Pill.self) { pill in
            PillDetailView(pill: pill, folderId: folder.id)
        }
        .searchable(text: $searchText, prompt: "Search pills")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddPill = true
                } label: {
                    Label("Add Pill", systemImage: "plus")
                }
            }
            if isOwner {
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Button {
                            showingShareFolder = true
                        } label: {
                            Label("Share Folder", systemImage: "person.crop.circle.badge.plus")
                        }
                        Button {
                            showingEditFolder = true
                        } label: {
                            Label("Rename Folder", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Label("Delete Folder", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddPill) {
            PillFormView(pill: nil, folderId: folder.id)
        }
        .sheet(isPresented: $showingEditFolder) {
            FolderFormView(folder: folder)
        }
        .sheet(isPresented: $showingShareFolder) {
            FolderShareView(folder: folder)
        }
        .confirmationDialog(
            "Delete \(currentName)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.deleteFolder(id: folder.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This also deletes the \(sortedPills.count) \(sortedPills.count == 1 ? "pill" : "pills") inside it.")
        }
        .task { await store.loadPills(folderId: folder.id) }
    }
}

#Preview {
    NavigationStack {
        PillsListView(folder: Folder(
            id: UUID(),
            userId: UUID(),
            name: "Daily Vitamins",
            createdAt: .now,
            updatedAt: .now,
            deletedAt: nil
        ))
        .environment(AppStore())
        .environment(AuthStore())
    }
}
