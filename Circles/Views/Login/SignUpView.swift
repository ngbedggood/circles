//
//  SignUpView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/07/2025.
//

import SwiftUI

struct SignUpView: View {
    
    @StateObject var viewModel: LoginViewModel
    @FocusState private var focusedField: FieldFocus?
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                .shadow(radius: 8)
            VStack(spacing: 24) {
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
                        .accessibilityIdentifier("displayNameFieldIdentifier")
                    
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)
            }
            .padding()
        }
    }
}

#Preview {
    SignUpView(viewModel: LoginViewModel(authManager: AuthManager()))
}
