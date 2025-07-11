//
//  LoginViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/07/2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var displayName: String = ""
    @Published var errorMessage: String?

    let authManager: any AuthManagerProtocol

    init(authManager: any AuthManagerProtocol) {
        self.authManager = authManager
    }

    func signUp() {
        guard !email.isEmpty && !password.isEmpty && !username.isEmpty && !displayName.isEmpty
        else {
            self.errorMessage = "Fields cannot be empty"
            return
        }
        Task {
            do {
                try await authManager.signUp(
                    email: email, password: password, username: username, displayName: displayName)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func login() async {
        guard !email.isEmpty && !password.isEmpty else {
            self.errorMessage = "Fields cannot be empty"
            return
        }

        do {
            try await authManager.login(email: email, password: password)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
