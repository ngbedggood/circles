//
//  LoginViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/07/2025.
//

import Combine
import Foundation

@MainActor
class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var displayName: String = ""
    @Published var errorMessage: String?

    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success

    @Published var authManager: any AuthManagerProtocol

    @Published var isVerified: Bool = false

    init(authManager: any AuthManagerProtocol) {
        self.authManager = authManager
    }

    func signUp() async {
        guard !email.isEmpty && !password.isEmpty  //&& !username.isEmpty && !displayName.isEmpty
        else {
            self.errorMessage = "Fields cannot be empty."
            await MainActor.run {
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .warning
                self.showToast = true
            }
            return
        }
        do {
            try await authManager.createAccount(
                email: email,
                password: password
            )
            await MainActor.run {
                self.showToast = false
                self.errorMessage = "A verfication email was sent"
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .success
                self.showToast = true
            }

        } catch {
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
            await MainActor.run {
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .error
                self.showToast = true
            }
        }
    }

    func login() async {
        guard !email.isEmpty && !password.isEmpty
        else {
            self.errorMessage = "Fields cannot be empty."
            await MainActor.run {
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .warning
                self.showToast = true
            }

            return
        }
        do {
            try await authManager.login(
                email: email,
                password: password
            )
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
            await MainActor.run {
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .error
                self.showToast = true
            }
        }
    }

    @MainActor
    func completeProfile() async {
        guard !username.isEmpty && !displayName.isEmpty else {
            self.toastMessage = "Fields cannot be empty."
            self.toastStyle = .warning
            self.showToast = true
            return
        }
        
        do {
            let isAvailable = try await authManager.firestoreManager.isUsernameAvailable(username)
            
            guard isAvailable else {
                self.toastMessage = "Username already taken."
                self.toastStyle = .warning
                self.showToast = true
                return
            }
            
        } catch {
            print("Error checking username availability: \(error.localizedDescription)")
            return
        }
        
        do {
            try await authManager.finishProfile(username: username, displayName: displayName)
//            self.toastMessage = "Profile completed successfully!"
//            self.toastStyle = .success
//            self.showToast = true
        } catch {
            print("Error finishing profile: \(error.localizedDescription)")
        }
    }

    func verifyEmail() async {
        guard !email.isEmpty
        else {
            self.errorMessage = "Email cannot be empty."
            await MainActor.run {
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .warning
                self.showToast = true
            }

            return
        }
        if (authManager.pendingSignUpEmail) != nil {
            await MainActor.run {
                self.showToast = false
                self.toastMessage = "A verificaiton email was already sent, please check your inbox"
                self.toastStyle = .success
                self.showToast = true
            }
        } else {
            do {
                try await authManager.sendVerificationEmail(email: email)
                self.errorMessage = nil
                print("LVM - email sent?")
            } catch {
                self.errorMessage = error.localizedDescription
                print(error.localizedDescription)
                await MainActor.run {
                    self.showToast = false
                    self.toastMessage = self.errorMessage ?? "An error occurred!"
                    self.toastStyle = .error
                    self.showToast = true
                }
            }
        }
    }
}
