//
//  PillRow.swift
//  MyPills
//

import SwiftUI

struct PillRow: View {
    let pill: Pill

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        HStack(spacing: 12) {
            PillImageView(data: pill.photo)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(pill.name)
                    .font(.headline)
                    .lineLimit(1)
                if !pill.details.isEmpty {
                    Text(pill.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(pill.price, format: .currency(code: currencyCode))
                    .font(.subheadline.weight(.semibold))
                Text("Qty \(pill.quantity)")
                    .font(.caption)
                    .foregroundStyle(pill.quantity == 0 ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
