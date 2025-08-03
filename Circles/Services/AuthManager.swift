//
//  AuthManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

extension User: UserProtocol {}

enum SignUpError: LocalizedError {
    case usernameTaken(String)
    case emailNotVerified

    var errorDescription: String? {
        switch self {
            case .usernameTaken(let username):
                return "Username '\(username)' is already taken."
            case .emailNotVerified:
                return "Please check your inbox for a verification email."
        }
    }
}

class AuthManager: AuthManagerProtocol {
    @Published var currentUser: UserProtocol?  // Firebase user object
    @Published var isAuthenticated: Bool = false
    @Published var isVerified: Bool = false
    @Published var isAvailable: Bool = true
    @Published var errorMsg: String?
    @Published var pendingSignUpEmail: String?

    @Published var isProfileComplete: Bool = false
    @Published var isInitializing: Bool = true

    private(set) var firestoreManager: any FirestoreManagerProtocol

    init() {
        self.firestoreManager = FirestoreManager()

        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            Task {
                let username = try await self.firestoreManager.fetchUsername(for: user?.uid ?? "")

                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = (user != nil)
                    self.isVerified = (user?.isEmailVerified ?? false)
                    self.isProfileComplete = (username != nil)
                    self.errorMsg = nil

                    if let uid = user?.uid {
                        print("User \(uid) logged in. Starting Firestore past moods listener.")
                        print("isAuthenticated: \(self.isAuthenticated)")
                        print("isVerified: \(self.isVerified)")
                        print("isProfileComplete: \(self.isProfileComplete)")
                        self.firestoreManager.loadPastMoods(forUserId: uid)
                        self.firestoreManager.loadUserProfile(for: uid)

                    } else {
                        self.firestoreManager.detachAllListeners()
                        print(
                            "User logged out or not authenticated. Detaching Firestore listeners.")
                    }
                }
                await MainActor.run {
                    withAnimation {
                        self.isInitializing = false
                    }
                }
            }
        }
    }
    func setFirestoreManager(_ firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }

    func login(email: String, password: String) async throws {
        // Attempt sign-in
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        let uid = user.uid

        // Check profile completeness
        let hasUsername = (try await self.firestoreManager.fetchUsername(for: uid)) != nil
        await MainActor.run {
            self.isProfileComplete = hasUsername
        }

        // Check email verification
        guard user.isEmailVerified else {
            await MainActor.run {
                self.isVerified = false
            }
            throw SignUpError.emailNotVerified
        }

        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.isVerified = true
            self.errorMsg = nil
        }

        // Load Firestore content
        await MainActor.run {
            self.firestoreManager.loadUserProfile(for: uid)
            self.firestoreManager.loadPastMoods(forUserId: uid)
            print("")
        }

        print("User logged in: \(user.email ?? "Unknown")")
    }

    func sendVerificationEmail(email: String) async throws {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://circles-nz.firebaseapp.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        print("Attempting to send email to: \(email)")
        print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")

        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) {
            [weak self] error in
            Task { @MainActor in
                if let error = error {
                    print("Firebase Error: \(error)")
                    print("Error Code: \(error._code)")
                    self?.errorMsg = "Failed to send email: \(error.localizedDescription)"
                } else {
                    print("Email sent successfully")
                    UserDefaults.standard.set(email, forKey: "AuthEmail")
                    self?.pendingSignUpEmail = email
                }
            }
        }
    }

    func createAccount(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        await MainActor.run {
            self.currentUser = result.user
            self.errorMsg = nil
            self.isAuthenticated = true
        }
        print("AUTHENTICATION STATUS IS: \(isAuthenticated)")

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://circles-nz.firebaseapp.com")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        try await result.user.sendEmailVerification(with: actionCodeSettings)
    }

    func finishProfile(username: String, displayName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }

        let uid = user.uid

        try await firestoreManager.saveUserProfile(
            uid: uid, username: username, displayName: displayName)

        await MainActor.run {
            self.errorMsg = nil
            self.currentUser = user
            self.isAuthenticated = true
            self.isProfileComplete = true
        }
        print("PROFILE COMPLETENESS STATUS IS: \(isProfileComplete)")

    }

    func signUp(email: String, password: String, username: String, displayName: String) async throws
    {
        let isAvailable = try await firestoreManager.isUsernameAvailable(username)
        guard isAvailable else {
            throw SignUpError.usernameTaken(username)
        }

        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid

        try await result.user.sendEmailVerification()

        try await firestoreManager.saveUserProfile(
            uid: uid, username: username, displayName: displayName)

        await MainActor.run {
            self.errorMsg = nil
            self.currentUser = result.user
            self.isAuthenticated = true
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            withAnimation {
                self.errorMsg = nil
                self.currentUser = nil
                self.isAuthenticated = false
                self.isVerified = false
                self.isProfileComplete = false
            }
            firestoreManager.detachAllListeners()
            print("User signed out.")  // Listener handles updating isAuthenticated state
        } catch let signOutError as NSError {
            self.errorMsg = signOutError.localizedDescription
            print("Error signing out: \(signOutError)")

        }
    }
    func handleIncomingURL(url: URL) async {
        print("at the start?")

        if let user = Auth.auth().currentUser {
            // Reload the user's data
            user.reload { error in
                if let error = error {
                    print("Error reloading user data: \(error.localizedDescription)")
                } else {
                    print("User data reloaded successfully.")
                    // Access the updated user properties
                    print("Updated display name: \(user.displayName ?? "N/A")")
                    print("Updated email: \(user.email ?? "N/A")")
                    if user.isEmailVerified {
                        self.errorMsg = nil
                        self.isVerified = true
                    } else {
                        print("Email is not verified")
                    }
                }
            }
        } else {
            print("No user is currently signed in.")
        }
        print("VERIFIED STATUS IS: \(isVerified)")
        print("PROFILE COMPLETENESS STATUS IS: \(isProfileComplete)")
    }
}
