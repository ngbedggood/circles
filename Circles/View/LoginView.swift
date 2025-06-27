//
//  LoginView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var am: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSignUp: Bool = false

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))

            VStack {
                Spacer()

                Text("Circles")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .frame(height: 24)
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(4)

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                            .frame(height: 24)
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(4)
                    } else {
                        SecureField("Password", text: $password)
                            .frame(height: 24)
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(4)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(4)
                }

                if let errorMsg = am.errorMsg {
                    Text(errorMsg)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack {
                    Button(action: {

                        if isSignUp {
                            am.signUp(email: email, password: password)
                        } else {
                            am.login(email: email, password: password)
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
                    .padding(20)

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
            .padding(20)

        }
    }
}

#Preview {
    LoginView()
}
