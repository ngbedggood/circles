//
//  EmailRegistrationView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/07/2025.
//

import SwiftUI

struct EmailRegistrationView: View {
    
    @StateObject var viewModel: LoginViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                .shadow(radius: 8)
            VStack(spacing: 24) {
                
                HStack {
                    TextField("Email", text: $viewModel.email)
                        .focused($isFocused)
                        .keyboardType(.emailAddress)
                        .font(.body)
                        .padding(18)
                        .accessibilityIdentifier("emailTextFieldIdentifier")
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 4)
            }
            //.opacity(isSignUp ? 1 : 0)
        }
        .padding(24)
    }
}

#Preview {
    EmailRegistrationView(viewModel: LoginViewModel(authManager: AuthManager()))
}
