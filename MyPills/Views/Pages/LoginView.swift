//
//  LoginView.swift
//  MyPills
//
//  Presented as a bottom sheet over WelcomeView by RootView.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) private var auth

    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && password.count >= 6
    }

    var body: some View {
        @Bindable var auth = auth

        ScrollView {
            VStack(spacing: 24) {
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

                    Text("Welcome Back")
                        .font(.title2.bold())
                    Text("Sign in to manage your pills.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        TextField("Email", text: $email)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            #endif
                            .autocorrectionDisabled()
                    }
                    .padding(.vertical, 12)

                    Divider()
                        .padding(.leading, 32)

                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                            .accessibilityHidden(true)
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
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
                        .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                    }
                    .padding(.vertical, 12)
                }
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(spacing: 8) {
                    if let errorMessage = auth.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                    if let infoMessage = auth.infoMessage {
                        Label(infoMessage, systemImage: "info.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Button {
                    Task {
                        await auth.signIn(email: email, password: password)
                    }
                } label: {
                    if auth.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isValid || auth.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 460)
        #endif
    }
}

#Preview {
    LoginView()
        .environment(AuthStore())
}
