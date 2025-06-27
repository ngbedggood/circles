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
    @Published var currentUser: User?  // Firebase user object
    @Published var isAuthenticated: Bool = false
    @Published var errorMsg: String?

    // The AuthManager owns the instance of FirestoreManager, all data flows through here.
    let fm = FirestoreManager()

    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentUser = user
                self.isAuthenticated = (user != nil)  // If 'user' is not nil, they're authenticated.
                self.errorMsg = nil

                if let uid = user?.uid {
                    // If we have a UID then start downloading the logged in users notes
                    print("User \(uid) logged in. Starting Firestore past moods listener.")
                    self.fm.loadPastMoods(forUserId: uid)
                    self.fm.isLoading = false  // But here seems to work with having the content view listent to the flag???
                } else {
                    // If no one is logged in/authenticated then detach all Firestore listeners and clear data.
                    self.fm.detachAllListeners()
                    print("User logged out or not authenticated. Detaching Firestore listeners.")
                }

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
