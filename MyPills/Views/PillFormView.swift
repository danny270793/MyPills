//
//  PillFormView.swift
//  MyPills
//

import SwiftUI
import SwiftData
import PhotosUI

struct PillFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Pill being edited, or nil when creating a new one.
    var pill: Pill?
    /// Folder the new pill is created into. Ignored when editing an existing pill.
    var folder: Folder?

    @State private var name: String = ""
    @State private var details: String = ""
    @State private var quantity: Int = 1
    @State private var price: Double = 0
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?

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
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExistingPill)
            .task(id: selectedPhotoItem) {
                if let selectedPhotoItem,
                   let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
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

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)

        if let pill {
            pill.name = trimmedName
            pill.details = trimmedDetails
            pill.quantity = quantity
            pill.price = price
            pill.photo = photoData
        } else {
            let newPill = Pill(
                name: trimmedName,
                details: trimmedDetails,
                photo: photoData,
                quantity: quantity,
                price: price,
                folder: folder
            )
            modelContext.insert(newPill)
        }

        dismiss()
    }
}
