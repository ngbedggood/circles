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
    
    @EnvironmentObject var authManager: AuthManager

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
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                        .padding(24)
                        .shadow(radius: 8)
                        .onTapGesture {
                            focusedField = nil
                        }
                        VStack {
                            Group {
                                if authManager.isVerified && !authManager.isProfileComplete {
                                    ProfileCompletionView(viewModel: viewModel)
                                        .transition(.opacity)
                                } else {
                                    AuthFormView(viewModel: viewModel)
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut, value: authManager.isVerified && !authManager.isProfileComplete)
                        }
                        .frame(maxWidth: screenWidth)
                        .padding(24)
                }
                .frame(height: screenHeight, alignment: .center)
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
