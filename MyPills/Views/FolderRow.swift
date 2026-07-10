//
//  FolderRow.swift
//  MyPills
//

import SwiftUI

struct FolderRow: View {
    let folder: Folder

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
                Text(folder.name)
                    .font(.headline)
                Text("\(folder.pills.count) \(folder.pills.count == 1 ? "pill" : "pills")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
