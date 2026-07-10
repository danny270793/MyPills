//
//  PillFormView.swift
//  MyPills
//

import SwiftUI
import PhotosUI

struct PillFormView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    /// Pill being edited, or nil when creating a new one.
    var pill: Pill?
    /// Folder the pill belongs to.
    var folderId: UUID

    @State private var name: String = ""
    @State private var details: String = ""
    @State private var quantity: Int = 1
    @State private var price: Double = 0
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isSaving = false

    private var isEditing: Bool { pill != nil }
    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            PillImageView(data: photoData)
                                .frame(width: 100, height: 100)

                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label(photoData == nil ? "Add Photo" : "Change Photo", systemImage: "photo.badge.plus")
                            }

                            if photoData != nil {
                                Button("Remove Photo", role: .destructive) {
                                    photoData = nil
                                    selectedPhotoItem = nil
                                }
                                .font(.footnote)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Inventory") {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 0...9999)
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("0.00", value: $price, format: .currency(code: currencyCode))
                            .multilineTextAlignment(.trailing)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Pill" : "New Pill")
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
            .onAppear(perform: loadExistingPill)
            .task(id: selectedPhotoItem) {
                if let selectedPhotoItem,
                   let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
            .disabled(isSaving)
        }
    }

    private func loadExistingPill() {
        guard let pill else { return }
        name = pill.name
        details = pill.details
        quantity = pill.quantity
        price = pill.price
        photoData = pill.photo
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        let draft = PillDraft(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            photo: photoData,
            quantity: quantity,
            price: price
        )

        if let pill {
            await store.updatePill(id: pill.id, draft: draft, folderId: folderId)
        } else {
            await store.createPill(draft, folderId: folderId)
        }

        dismiss()
    }
}
