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
    @Query(sort: \Pill.name) private var pills: [Pill]

    @State private var showingAddPill = false
    @State private var searchText = ""

    private var filteredPills: [Pill] {
        guard !searchText.isEmpty else { return pills }
        return pills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if pills.isEmpty {
                    ContentUnavailableView(
                        "No Pills Yet",
                        systemImage: "pills",
                        description: Text("Tap the + button to add your first pill.")
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
            .navigationTitle("My Pills")
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
            }
            .sheet(isPresented: $showingAddPill) {
                PillFormView(pill: nil)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Pill.self, inMemory: true)
}
