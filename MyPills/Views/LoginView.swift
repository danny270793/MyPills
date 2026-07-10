//
//  LoginView.swift
//  MyPills
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthStore.self) private var auth

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false
    @State private var isPasswordVisible = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && password.count >= 6
    }

    var body: some View {
        @Bindable var auth = auth

        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.accentColor.gradient)
                        Image(systemName: "pills.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 88, height: 88)

                    Text("My Pills")
                        .font(.largeTitle.bold())
                    Text(isSignUpMode ? "Create an account to get started" : "Sign in to manage your pills")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
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
                        .padding(.trailing, 8)
                        .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                    }

                    if let errorMessage = auth.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                    if let infoMessage = auth.infoMessage {
                        Text(infoMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            if isSignUpMode {
                                await auth.signUp(email: email, password: password)
                            } else {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        if auth.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isValid || auth.isLoading)

                    Button {
                        isSignUpMode.toggle()
                        auth.errorMessage = nil
                        auth.infoMessage = nil
                    } label: {
                        Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.footnote)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }
}

#Preview {
    LoginView()
        .environment(AuthStore())
}
