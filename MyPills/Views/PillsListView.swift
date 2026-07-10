//
//  PillsListView.swift
//  MyPills
//

import SwiftUI
import SwiftData

struct PillsListView: View {
    @Bindable var folder: Folder

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddPill = false
    @State private var showingEditFolder = false
    @State private var showingDeleteConfirm = false
    @State private var searchText = ""

    private var sortedPills: [Pill] {
        folder.pills.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private var filteredPills: [Pill] {
        guard !searchText.isEmpty else { return sortedPills }
        return sortedPills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if folder.pills.isEmpty {
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
                                modelContext.delete(pill)
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
        .navigationTitle(folder.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(for: Pill.self) { pill in
            PillDetailView(pill: pill)
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
            ToolbarItem(placement: .secondaryAction) {
                Menu {
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
        .sheet(isPresented: $showingAddPill) {
            PillFormView(pill: nil, folder: folder)
        }
        .sheet(isPresented: $showingEditFolder) {
            FolderFormView(folder: folder)
        }
        .confirmationDialog(
            "Delete \(folder.name)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(folder)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This also deletes the \(folder.pills.count) \(folder.pills.count == 1 ? "pill" : "pills") inside it.")
        }
    }
}
