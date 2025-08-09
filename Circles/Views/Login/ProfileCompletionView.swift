//
//  ProfileCompletionView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI



struct ProfileCompletionView: View {
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var focusedField: FieldFocus?
    var body: some View {
        VStack(spacing: 24) {
            Text("Get started by filling out your profile.")
            UsernameField(username: $viewModel.username, focusedField: $focusedField)
            DisplayNameField(displayName: $viewModel.displayName, focusedField: $focusedField)
            CircleActionButton(title: "Continue", isLoading: false) {
                Task {
                    await viewModel.completeProfile()
                }
            }
        }
        .animation(.easeInOut, value: focusedField)
        .offset(y: focusedField != nil ? -140 : -20)
        .padding(24)
    }
}

#Preview {
    ProfileCompletionView(
        viewModel: LoginViewModel(
            authManager: AuthManager()
        )
    )
}
