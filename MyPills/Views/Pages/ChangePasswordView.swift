//
//  ChangePasswordView.swift
//  MyPills
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(AuthStore.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isSaving = false

    private var isValid: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }

    var body: some View {
        @Bindable var auth = auth

        NavigationStack {
            Form {
                Section {
                    passwordField("New Password", text: $newPassword)
                    passwordField("Confirm Password", text: $confirmPassword)
                } footer: {
                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("Passwords don't match.")
                            .foregroundStyle(.red)
                    } else {
                        Text("Use at least 6 characters.")
                    }
                }

                if let errorMessage = auth.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Change Password")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(!isValid || isSaving)
                }
            }
            .disabled(isSaving)
            .onAppear { auth.errorMessage = nil }
        }
    }

    @ViewBuilder
    private func passwordField(_ title: LocalizedStringKey, text: Binding<String>) -> some View {
        HStack {
            Group {
                if isPasswordVisible {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
            .autocorrectionDisabled()

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let succeeded = await auth.changePassword(newPassword: newPassword)
        if succeeded {
            dismiss()
        }
    }
}

#Preview {
    ChangePasswordView()
        .environment(AuthStore())
}
