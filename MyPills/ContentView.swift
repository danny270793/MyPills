//
//  ContentView.swift
//  MyPills
//
//  Created by Danny Vaca on 9/7/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) private var store
    @Environment(AuthStore.self) private var auth

    @State private var showingAddFolder = false
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var searchText = ""

    private var filteredSummaries: [FolderSummary] {
        guard !searchText.isEmpty else { return store.folderSummaries }
        return store.folderSummaries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in if !isPresented { store.errorMessage = nil } }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if !store.hasLoadedFolders {
                    ProgressView()
                } else if store.folderSummaries.isEmpty {
                    ContentUnavailableView(
                        "No Folders Yet",
                        systemImage: "folder",
                        description: Text("Tap the + button to create your first folder.")
                    )
                } else if filteredSummaries.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredSummaries) { summary in
                            let isOwner = summary.userId == auth.currentUserId
                            NavigationLink(value: summary.folder) {
                                FolderRow(summary: summary, isSharedWithMe: !isOwner)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if isOwner {
                                    Button(role: .destructive) {
                                        Task { await store.deleteFolder(id: summary.id) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
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
            .navigationDestination(isPresented: $showingProfile) {
                ProfileView()
            }
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
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
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showingProfile = true
                    } label: {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                FolderFormView(folder: nil)
            }
            .refreshable { await store.loadFolders() }
            .task { await store.loadFolders() }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
        .environment(AuthStore())
}
