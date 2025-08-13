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

    init(firestoreManager: any FirestoreManagerProtocol) {
        self.firestoreManager = firestoreManager

        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            Task {
                guard let uid = user?.uid, !uid.isEmpty else {
                    await MainActor.run {
                        self.firestoreManager.detachAllListeners()
                        self.currentUser = nil
                        self.isAuthenticated = false
                        self.isVerified = false
                        self.isProfileComplete = false
                        self.errorMsg = "No user logged in?"
                        self.isInitializing = false
                    }
                    print("No user logged in?")
                    return
                }
                do {
                    let username = try await self.firestoreManager.fetchUsername(for: uid)
                    let userProfile = try await self.firestoreManager.fetchUserProfile(userID: uid)
                    
                    try await self.firestoreManager.loadPastMoods(forUserId: uid)
                    try await self.firestoreManager.loadUserProfile(for: uid)

                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                        self.isVerified = ((user?.isEmailVerified) != nil)
                        self.isProfileComplete = (username != nil)
                        self.errorMsg = nil

                        UserDefaults.standard.set(username, forKey: "Username")
                        UserDefaults.standard.set(userProfile.displayName, forKey: "DisplayName")

                        print("User \(uid) logged in. Starting Firestore past moods listener.")
                        print("isAuthenticated: \(self.isAuthenticated)")
                        print("isVerified: \(self.isVerified)")
                        print("isProfileComplete: \(self.isProfileComplete)")

                        withAnimation {
                            self.isInitializing = false
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.errorMsg = "Error fetching user data: \(error.localizedDescription)"
                        self.isInitializing = false
                    }
                }
            }
        }
    }
    
    func setFirestoreManager(_ firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func uploadFCMToken(_ token: String) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user; cannot upload FCM token yet.")
            return
        }
        do {
            try await firestoreManager.uploadFCMToken(uid: uid, token: token)       
            //print("FCM token uploaded to Firestore for user \(uid)")
        } catch {
            print("Failed to upload FCM token: \(error.localizedDescription)")
        }
    }

    @MainActor
    func login(email: String, password: String) async throws {
        // Attempt sign-in
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        let uid = user.uid

        // Check profile completeness
        let hasUsername = (try await self.firestoreManager.fetchUsername(for: uid)) != nil
        self.isProfileComplete = hasUsername

        // Check email verification
        guard user.isEmailVerified else {
            self.isVerified = false
            throw SignUpError.emailNotVerified
        }

        self.currentUser = user
        self.isAuthenticated = true
        self.isVerified = true
        self.errorMsg = nil

        // Load Firestore content
        try await self.firestoreManager.loadUserProfile(for: uid)
        try await self.firestoreManager.loadPastMoods(forUserId: uid)
        print("")

        print("User logged in: \(user.email ?? "Unknown")")
    }

    func sendVerificationEmail(email: String) async throws {
//        let actionCodeSettings = ActionCodeSettings()
//        actionCodeSettings.url = URL(string: "https://circles-nz.firebaseapp.com")
//        actionCodeSettings.handleCodeInApp = true
//        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
//
//        print("Attempting to send email to: \(email)")
//        print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
//
//        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) {
//            [weak self] error in
//            Task { @MainActor in
//                if let error = error {
//                    print("Firebase Error: \(error)")
//                    print("Error Code: \(error._code)")
//                    self?.errorMsg = "Failed to send email: \(error.localizedDescription)"
//                } else {
//                    print("Email sent successfully")
//                    UserDefaults.standard.set(email, forKey: "AuthEmail")
//                    self?.pendingSignUpEmail = email
//                }
//            }
//        }
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
        UserDefaults.standard.set(username, forKey: "Username")
        UserDefaults.standard.set(displayName, forKey: "DisplayName")

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

    @MainActor
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
            // Clear Firestore Data
            firestoreManager.detachAllListeners()
            UserDefaults.standard.removeObject(forKey: "AuthEmail")
            UserDefaults.standard.removeObject(forKey: "Username")
            UserDefaults.standard.removeObject(forKey: "DisplayName")
            UserDefaults.standard.removeObject(forKey: "hasPromptedForPush")
            
            print("User signed out.")  // Listener handles updating isAuthenticated state
        } catch let signOutError as NSError {
            self.errorMsg = signOutError.localizedDescription
            print("Error signing out: \(signOutError)")

        }
    }
    
    @MainActor
    func handleIncomingURL(url: URL) async {
        print("url: \(url.absoluteString)")
        
        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let linkQuery = urlComponents.queryItems?.first(where: { $0.name == "link" })?.value,
            let innerURL = URL(string: linkQuery),
            let innerComponents = URLComponents(url: innerURL, resolvingAgainstBaseURL: false),
            let oobCode = innerComponents.queryItems?.first(where: { $0.name == "oobCode" })?.value
        else {
            print("Failed to extract oobCode from URL")
            return
        }
        print("Extracted oobCode: \(oobCode)")
        
        do {
            try await Auth.auth().applyActionCode(oobCode)
            print("Email verified successfully!")
            
            if let user = Auth.auth().currentUser {
                try await user.reload()
                print("User reloaded, isEmailVerified: \(user.isEmailVerified)")
                withAnimation {
                    self.isVerified = user.isEmailVerified
                }
                self.errorMsg = nil
            }
            
        } catch {
            print("Failed to apply action code: \(error.localizedDescription)")
            self.errorMsg = error.localizedDescription
        }
    }
}
