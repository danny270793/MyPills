//
//  FolderRow.swift
//  MyPills
//

import SwiftUI

struct FolderRow: View {
    let summary: FolderSummary
    var isSharedWithMe: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.gradient)
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.name)
                    .font(.headline)
                Text("\(summary.pillCount) pills")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSharedWithMe {
                Image(systemName: "person.2.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
