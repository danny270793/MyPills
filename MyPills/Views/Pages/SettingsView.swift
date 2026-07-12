//
//  SettingsView.swift
//  MyPills
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink { AboutView() } label: {
                    Label("About", systemImage: "info.circle")
                }
                NavigationLink {
                    LegalDocumentView(title: "Terms and Conditions", text: Self.termsAndConditions)
                } label: {
                    Label("Terms and Conditions", systemImage: "doc.text")
                }
                NavigationLink {
                    LegalDocumentView(title: "Privacy Policy", text: Self.privacyPolicy)
                } label: {
                    Label("Privacy", systemImage: "hand.raised")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private static let termsAndConditions: LocalizedStringKey = """
    Last updated: 2026

    1. Acceptance of Terms
    By using My Pills, you agree to these Terms and Conditions. If you do not agree, please do not use the app.

    2. Description of Service
    My Pills helps you keep track of your medications by organizing them into folders. You may record details such as name, description, quantity, and price, and optionally attach a photo.

    3. Not Medical Advice
    My Pills is an organizational tool only. It does not provide medical advice, diagnosis, or treatment, and is not a substitute for guidance from a qualified healthcare professional. Always verify dosage and usage information with your doctor or pharmacist.

    4. Your Account
    You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account.

    5. Sharing Folders
    You may choose to share a folder with another person by email. Anyone you share a folder with can view its contents. You are responsible for only sharing folders with people you trust.

    6. Accuracy of Information
    You are solely responsible for the accuracy of the information you enter into the app.

    7. Limitation of Liability
    My Pills is provided "as is" without warranties of any kind. To the fullest extent permitted by law, the developer is not liable for any damages arising from your use of the app.

    8. Changes to These Terms
    These Terms may be updated from time to time. Continued use of the app after changes constitutes acceptance of the updated Terms.

    9. Contact
    Questions about these Terms can be directed to the developer at https://github.com/danny270793.
    """

    private static let privacyPolicy: LocalizedStringKey = """
    Last updated: 2026

    1. Information We Collect
    - Account information: the email address and password you use to sign in.
    - App data: the folders and pills you create, including names, descriptions, quantities, prices, and photos you choose to add.
    - Sharing information: the email addresses of people you choose to share a folder with.

    2. How We Use Your Information
    Your information is used solely to provide the app's features: authenticating your account, storing your pill and folder data, and enabling folder sharing with people you invite.

    3. Where Your Data Is Stored
    Your data is stored using Supabase, a third-party backend provider, which hosts the app's database and handles authentication.

    4. Sharing of Information
    We do not sell your data or share it with advertisers. Folder data is only visible to you and to anyone you explicitly share that folder with.

    5. Data Retention and Deletion
    Deleting a folder or pill removes it from your account. If you would like your account and all associated data permanently deleted, contact the developer at https://github.com/danny270793.

    6. Security
    We take reasonable measures to protect your data, but no method of electronic storage is 100% secure.

    7. Changes to This Policy
    This Privacy Policy may be updated from time to time. Continued use of the app after changes constitutes acceptance of the updated policy.

    8. Contact
    Questions about this Privacy Policy can be directed to the developer at https://github.com/danny270793.
    """
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
