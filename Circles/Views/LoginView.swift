//
//  LoginView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import SwiftUI

enum FieldFocus: Hashable {
    case secure, plain
}

struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: FieldFocus?

    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                    
                    Text("Circles")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .padding()
                        .accessibilityIdentifier("circlesTitleIdentifier")
                    
                    Group{
                        HStack {
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .font(.body)
                                .padding(18)
                                .accessibilityIdentifier("emailTextFieldIdentifier")
                        }
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 4)
                        
                        HStack {
                            ZStack {
                                TextField("Password", text: $viewModel.password)
                                    .keyboardType(.asciiCapable)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .plain)
                                    .font(.body)
                                    .padding(18)
                                    .accessibilityIdentifier("passwordFieldIdentifier")
                                    .opacity(isPasswordVisible ? 1 : 0)
                                
                                SecureField("Password", text: $viewModel.password)
                                    .focused($focusedField, equals: .secure)
                                    .font(.body)
                                    .padding(18)
                                    .accessibilityIdentifier("passwordFieldIdentifier")  // Should be fine using the same identifier considering only one is visible at the same time
                                    .opacity(isPasswordVisible ? 0 : 1)
                            }
                            Button(action: {
                                let wasFocused = focusedField
                                isPasswordVisible.toggle()
                                DispatchQueue.main.async {
                                    if wasFocused != nil {
                                        focusedField = isPasswordVisible ? .plain : .secure
                                    }
                                }
                                
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 20))
                                    .padding(.horizontal, 12)
                            }
                            .accessibilityIdentifier("showPasswordButtonIdentifier")
                        }
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 4)
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .foregroundStyle(.black.opacity(0.75))
                    
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
                    
                    Text(viewModel.errorMessage ?? "")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .opacity(viewModel.errorMessage != nil ? 1 : 0)
                        .transition(.scale)
                    
                    Spacer()
                    
                    VStack {
                        Button(
                            action: {
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
                                                .transition(.scale)
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
        .scrollDisabled(true) // Stupid hack to stop keyboard from shifting content
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
