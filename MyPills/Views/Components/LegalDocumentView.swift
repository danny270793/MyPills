//
//  LegalDocumentView.swift
//  MyPills
//
//  Plain scrollable text page, used for Terms and Conditions and the
//  Privacy Policy — matches the "Legal" pages in Settings.app.
//

import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        LegalDocumentView(title: "Terms and Conditions", text: "Sample legal text.")
    }
}
