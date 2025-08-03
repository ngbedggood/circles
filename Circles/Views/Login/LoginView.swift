//
//  LoginView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import SwiftUI

enum FieldFocus: Hashable {
    case secure, plain, email, username, displayname
}

struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: FieldFocus?
    @FocusState private var isFocused: Bool

    @State private var horizontalIndex: Int = 0

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            TabView(selection: $horizontalIndex) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                        .shadow(radius: 8)
                    ScrollView {
                        VStack {
                            VStack(spacing: 24) {
                                Text("Circles")
                                    .font(.satoshi(size: 38, weight: .bold))
                                    .scaleEffect(focusedField != nil ? 0.7 : 1)
                                    .offset(y: focusedField != nil ? 12 : 0)
                                    .animation(.easeInOut, value: focusedField)
                                    .accessibilityIdentifier("circlesTitleIdentifier")
                                if viewModel.authManager.isVerified
                                    && !viewModel.authManager.isProfileComplete
                                {

                                    VStack {
                                        Text("Get started by filling out your profile.")
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
                                            .focused($isFocused)
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
                                                .focused($isFocused)
                                                .foregroundColor(.black.opacity(0.75))
                                                .font(.body)
                                                .padding(18)
                                                .accessibilityIdentifier(
                                                    "displayNameFieldIdentifier")

                                        }
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .shadow(radius: 4)
                                        Button(
                                            action: {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                                                Task {
                                                    do {
                                                        await viewModel.completeProfile()
                                                    }
                                                }
                                            }
                                        ) {
                                            Circle()
                                                .fill(.teal)
                                                .frame(width: 80, height: 80)
                                                .overlay(
                                                    Text("Continue")
                                                        .foregroundColor(.white)
                                                    //.font(.satoshi(size: 12))
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 4)
                                        }
                                        .padding()
                                        .accessibilityIdentifier("continueButtonIdentifier")
                                    }
                                    .transition(.opacity)
                                } else {

                                    Group {
                                        HStack {
                                            TextField("Email", text: $viewModel.email)
                                                .focused($focusedField, equals: .email)
                                                .keyboardType(.emailAddress)
                                                .padding(18)
                                                .accessibilityIdentifier("emailTextFieldIdentifier")
                                        }
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .shadow(radius: 4)
                                        .zIndex(2)

                                        HStack {
                                            ZStack {
                                                TextField("Password", text: $viewModel.password)
                                                    .keyboardType(.asciiCapable)
                                                    .textContentType(.password)
                                                    .focused($focusedField, equals: .plain)
                                                    .padding(18)
                                                    .accessibilityIdentifier(
                                                        "passwordFieldIdentifier"
                                                    )
                                                    .opacity(isPasswordVisible ? 1 : 0)

                                                SecureField("Password", text: $viewModel.password)
                                                    .focused($focusedField, equals: .secure)
                                                    .padding(18)
                                                    .accessibilityIdentifier(
                                                        "passwordFieldIdentifier"
                                                    )  // Should be fine using the same identifier considering only one is visible at the same time
                                                    .opacity(isPasswordVisible ? 0 : 1)
                                            }
                                            Button(action: {
                                                let wasFocused = focusedField
                                                isPasswordVisible.toggle()
                                                if wasFocused != nil {
                                                    focusedField =
                                                        isPasswordVisible ? .plain : .secure
                                                }

                                            }) {
                                                Image(
                                                    systemName: isPasswordVisible
                                                        ? "eye.slash.fill" : "eye.fill"
                                                )
                                                .font(.system(size: 20))
                                                .padding(.horizontal, 12)
                                            }
                                            .accessibilityIdentifier("showPasswordButtonIdentifier")
                                        }
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .shadow(radius: 4)
                                        .zIndex(1)
                                    }
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .foregroundStyle(.black.opacity(0.75))

                                    VStack {
                                        Button(
                                            action: {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
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
                                                                .accessibilityIdentifier(
                                                                    "loadingIdentifier")
                                                        } else {
                                                            Text(isSignUp ? "Sign up" : "Login")
                                                                .foregroundColor(.white)
                                                                .transition(.scale)
                                                                .accessibilityIdentifier(
                                                                    "signUpOrLoginTextIdentifier")
                                                        }
                                                    }

                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 4)
                                        }
                                        .padding()
                                        .disabled(isLoading)
                                        .accessibilityIdentifier("loginButtonIdentifier")

                                        Button(
                                            action: {
                                                withAnimation {
                                                    isSignUp.toggle()
                                                }
                                            },
                                            label: {
                                                Text(
                                                    isSignUp
                                                        ? "I already have an account"
                                                        : "I don't have an account"
                                                )
                                                .font(.satoshi(size: 12))
                                                .foregroundStyle(.gray)
                                            }
                                        )
                                        .accessibilityIdentifier("signUpToggleButtonIdentifier")

                                    }
                                }

                            }
                            .frame(maxWidth: screenWidth)
                            .padding(24)
                            .offset(y: focusedField != nil ? -160 : -20)
                            .animation(.easeInOut, value: focusedField)
                        }
                        .frame(height: screenHeight, alignment: .center)
                    }
                }
                .scrollDisabled(true)  // Stupid hack to stop keyboard from shifting content
                .onTapGesture {
                    focusedField = nil
                }
                .padding(24)

            }
            .transition(.opacity)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .toast(
                isShown: $viewModel.showToast,
                type: viewModel.toastStyle,
                title: "Success",
                message: viewModel.toastMessage
            )

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
