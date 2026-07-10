//
//  ContentView.swift
//  MyPills
//
//  Created by Danny Vaca on 9/7/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]

    @State private var showingAddFolder = false
    @State private var searchText = ""

    private var filteredFolders: [Folder] {
        guard !searchText.isEmpty else { return folders }
        return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if folders.isEmpty {
                    ContentUnavailableView(
                        "No Folders Yet",
                        systemImage: "folder",
                        description: Text("Tap the + button to create your first folder.")
                    )
                } else if filteredFolders.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredFolders) { folder in
                            NavigationLink(value: folder) {
                                FolderRow(folder: folder)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(folder)
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
            .navigationTitle("Folders")
            .navigationDestination(for: Folder.self) { folder in
                PillsListView(folder: folder)
            }
            .searchable(text: $searchText, prompt: "Search folders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Label("Add Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                FolderFormView(folder: nil)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Pill.self], inMemory: true)
}
