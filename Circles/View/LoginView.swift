//
//  LoginView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false

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

                HStack {
                    TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.black.opacity(0.75))
                    .font(.body)
                    .padding(18)
                    .textInputAutocapitalization(.never)
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)
                

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            //.frame(height: 48)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                    } else {
                        SecureField("Password", text: $password)
                            //.frame(height: 48)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                            .padding(.horizontal, 12)
                    }
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)
                
                if isSignUp {
                    HStack {
                        TextField("Username", text: Binding(
                            get: { username },
                            set: { newValue in
                                username = newValue.lowercased()
                            }
                        ))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.black.opacity(0.75))
                        .font(.body)
                        .padding(18)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                    
                    HStack {
                        TextField("Display Name", text: $displayName)
                        .foregroundColor(.black.opacity(0.75))
                        .font(.body)
                        .padding(18)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                }

                if let errorMsg = authManager.errorMsg {
                    Text(errorMsg)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack {
                    Button(action: {

                        if isSignUp {
                            authManager.signUp(
                                email: email,
                                password: password,
                                username: username,
                                displayName: displayName
                            )
                        } else {
                            authManager.login(
                                email: email,
                                password: password
                            )
                        }

                    }) {
                        Circle()
                            .fill(.teal)
                            .frame(maxWidth: 80)
                            .overlay(
                                Text(isSignUp ? "Sign up" : "Login")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    .padding(16)

                    Button(
                        action: {
                            isSignUp.toggle()
                        },
                        label: {
                            Text(isSignUp ? "I already have an account" : "I don't have an account")
                                .foregroundStyle(.gray)
                                .font(.caption)
                        })

                }
            }
            .frame(width: 310)
            .padding()
            

        }
    }
}

#Preview {
    LoginView()
}
