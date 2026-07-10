//
//  PillDetailView.swift
//  MyPills
//

import SwiftUI
import SwiftData

struct PillDetailView: View {
    @Bindable var pill: Pill

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PillImageView(data: pill.photo, cornerRadius: 24)
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .padding(.top, 12)

                VStack(spacing: 6) {
                    Text(pill.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    if !pill.details.isEmpty {
                        Text(pill.details)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    StatCard(title: "Quantity", value: "\(pill.quantity)", systemImage: "number")
                    StatCard(
                        title: "Price",
                        value: pill.price.formatted(.currency(code: currencyCode)),
                        systemImage: "dollarsign.circle"
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(pill.name)
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
            }
        }
        .sheet(isPresented: $showingEdit) {
            PillFormView(pill: pill)
        }
        .confirmationDialog(
            "Delete \(pill.name)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(pill)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
