//
//  AuthManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import Combine
import FirebaseAuth
import Foundation

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMsg: String?

    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = (user != nil)
                print("Auth state changed. isAuthenticated: \(self?.isAuthenticated ?? false)")
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMsg = error.localizedDescription
                    print("Login error: \(error.localizedDescription)")
                } else {
                    self?.errorMsg = nil
                    print("User logged in: \(authResult?.user.email ?? "Unknown")")
                }
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMsg = error.localizedDescription
                    print("Sign up error: \(error.localizedDescription)")
                } else {
                    self?.errorMsg = nil
                    print("User signed up: \(authResult?.user.email ?? "Unknown")")
                }
            }

        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out.")  // Listener handles updating isAuthenticated state
        } catch let signOutError as NSError {
            self.errorMsg = signOutError.localizedDescription
            print("Error signing out: \(signOutError)")

        }
    }
}
