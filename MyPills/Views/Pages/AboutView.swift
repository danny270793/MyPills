//
//  AboutView.swift
//  MyPills
//

import SwiftUI

struct AboutView: View {
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "My Pills"
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.accentColor.gradient)
                            Image(systemName: "pills.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                        Text(appName)
                            .font(.title2.bold())
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section("App") {
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
            }

            Section("Developer") {
                Link(destination: URL(string: "https://github.com/danny270793")!) {
                    Label("danny270793", systemImage: "link")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
