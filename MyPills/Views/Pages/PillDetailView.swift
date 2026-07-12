//
//  PillDetailView.swift
//  MyPills
//

import SwiftUI

struct PillDetailView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let pill: Pill
    let folderId: UUID

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    private var currentPill: Pill {
        store.pills(for: folderId).first(where: { $0.id == pill.id }) ?? pill
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PillImageView(data: currentPill.photo, cornerRadius: 24)
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .padding(.top, 12)

                VStack(spacing: 6) {
                    Text(currentPill.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    if !currentPill.details.isEmpty {
                        Text(currentPill.details)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    StatCard(title: "Quantity", value: "\(currentPill.quantity)", systemImage: "number")
                    StatCard(
                        title: "Price",
                        value: currentPill.price.formatted(.currency(code: currencyCode)),
                        systemImage: "dollarsign.circle"
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(currentPill.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More")
            }
        }
        .sheet(isPresented: $showingEdit) {
            PillFormView(pill: currentPill, folderId: folderId)
        }
        .confirmationDialog(
            "Delete \(currentPill.name)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.deletePill(id: currentPill.id, folderId: folderId)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    NavigationStack {
        PillDetailView(
            pill: Pill(
                id: UUID(),
                userId: UUID(),
                folderId: UUID(),
                name: "Vitamin D3",
                details: "Take one tablet daily with food.",
                photoBase64: nil,
                quantity: 30,
                price: 12.99,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil
            ),
            folderId: UUID()
        )
        .environment(AppStore())
    }
}
