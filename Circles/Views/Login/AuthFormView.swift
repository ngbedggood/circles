//
//  AuthFormField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct AuthFormView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var isPasswordVisible = false
    @State private var isSignUp = false
    @State private var isLoading = false
    @FocusState private var focusedField: FieldFocus?
    var body: some View {
            VStack(spacing: 24) {
                Text("Circles")
                    .font(.satoshi(size: 38, weight: .bold))
                    .animation(.easeInOut, value: focusedField)
                    .accessibilityIdentifier("circlesTitleIdentifier")
                
                EmailField(email: $viewModel.email, focusedField: $focusedField)
                PasswordField(password: $viewModel.password, focusedField: $focusedField)
                
                CircleActionButton(
                    title: isSignUp ? "Sign Up" : "Login",
                    isLoading: isLoading
                ) {
                    Task {
                        isLoading = true
                        defer { isLoading = false }  // Runs when the Task is complete
                        do {
                            if isSignUp {
                                await viewModel.signUp()
                            } else {
                                await viewModel.login()
                            }
                        }
                    }
                }
                
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                    }
                },
                       label: {
                    Text(isSignUp ? "I already have an account" : "I don't have an account")
                        .font(.satoshi(size: 12))
                        .foregroundStyle(.gray)
                        .frame(height: 30)
                }
                )
                .accessibilityIdentifier("signUpToggleButtonIdentifier")
            }
            .animation(.easeInOut, value: focusedField)
            .offset(y: focusedField != nil ? -140 : -20)
            .padding(24)
    }
}

#Preview {
    AuthFormView(
        viewModel: LoginViewModel(authManager: AuthManager(firestoreManager: FirestoreManager()))
    )
}
