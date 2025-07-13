//
//  LoginView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import SwiftUI

struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.92, green: 0.88, blue: 0.84))

            VStack(spacing: 24) {
                Spacer()

                Text("Circles")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .foregroundStyle(.black.opacity(0.75))
                    .padding()
                    .accessibilityIdentifier("circlesTitleIdentifier")

                HStack {
                    TextField("Email", text: $viewModel.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.black.opacity(0.75))
                        .font(.body)
                        .padding(18)
                        .textInputAutocapitalization(.never)
                        .accessibilityIdentifier("emailTextFieldIdentifier")
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                            //.frame(height: 48)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                            .accessibilityIdentifier("passwordFieldIdentifier")
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            //.frame(height: 48)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                            .accessibilityIdentifier("passwordFieldIdentifier") // Should be fine using the same identifier considering only one is visible at the same time
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                            .padding(.horizontal, 12)
                    }
                    .accessibilityIdentifier("showPasswordButtonIdentifier")
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)

                Group {
                    HStack {
                        TextField(
                            "Username",
                            text: Binding(
                                get: { viewModel.username },
                                set: { newValue in
                                    viewModel.username = newValue.lowercased()
                                }
                            )
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.black.opacity(0.75))
                        .font(.body)
                        .padding(18)
                        .accessibilityIdentifier("usernameFieldIdentifier")

                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)

                    HStack {
                        TextField("Display Name", text: $viewModel.displayName)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                            .accessibilityIdentifier("displayNameFieldIdentifier")

                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                }
                .opacity(isSignUp ? 1 : 0)
                
                Spacer()

                Text(viewModel.errorMessage ?? "")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .opacity(viewModel.errorMessage != nil ? 1 : 0)

                Spacer()

                VStack {
                    Button(
                        action: {
                            Task {
                                isLoading = true
                                defer { isLoading = false } // Runs when the Task is complete
                                
                                do {
                                    if isSignUp {
                                        try await viewModel.signUp()
                                    } else {
                                        try await viewModel.login()
                                    }
                                } catch {
                                    print("Authentication failed: \(error.localizedDescription)")
                                }
                            }
                        }
                    ) {
                        Circle()
                            .fill(.teal)
                            .frame(width: 80, height: 80)
                            .overlay(
                                ZStack {
                                    if isLoading {
                                        Text("Loading...")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12))
                                            .accessibilityIdentifier("loadingIdentifier")
                                    } else {
                                        Text(isSignUp ? "Sign up" : "Login")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .accessibilityIdentifier("signUpOrLoginTextIdentifier")
                                    }
                                }

                            )
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    .padding(16)
                    .disabled(isLoading)
                    .accessibilityIdentifier("loginButtonIdentifier")

                    Button(
                        action: {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        },
                        label: {
                            Text(isSignUp ? "I already have an account" : "I don't have an account")
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }
                    )
                    .accessibilityIdentifier("signUpToggleButtonIdentifier")

                }
            }
            .frame(width: 310)
            .padding()

        }
    }
}

#Preview {

    struct PreviewWrapper: View {

        let viewModel = LoginViewModel(authManager: AuthManager())

        var body: some View {
            LoginView(
                viewModel: viewModel
            )
        }
    }

    return PreviewWrapper()
}
