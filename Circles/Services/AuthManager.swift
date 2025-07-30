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
    var isVerifiedPublisher: Published<Bool>.Publisher { $isVerified } 
    @Published var isAvailable: Bool = true
    @Published var errorMsg: String?

    private(set) var firestoreManager: any FirestoreManagerProtocol

    init() {
        self.firestoreManager = FirestoreManager()
        // Listen for authentication state changes
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentUser = user
                self.isAuthenticated = (user != nil)  // If 'user' is not nil, they're authenticated.
                self.errorMsg = nil

                if let uid = user?.uid {
                    // If we have a UID then start downloading the logged in users notes
                    print("User \(uid) logged in. Starting Firestore past moods listener.")
                    self.firestoreManager.loadPastMoods(forUserId: uid)
                    self.firestoreManager.loadUserProfile(for: uid)

                } else {
                    // If no one is logged in/authenticated then detach all Firestore listeners and clear data.
                    self.firestoreManager.detachAllListeners()
                    print("User logged out or not authenticated. Detaching Firestore listeners.")
                }

            }
        }
    }

    func setFirestoreManager(_ firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }

    func login(email: String, password: String) async throws {
        
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
        
        await MainActor.run {
            self.isVerified = result.user.isEmailVerified
        }
        
        if !result.user.isEmailVerified {
            throw SignUpError.emailNotVerified
        }

        await MainActor.run {
            self.errorMsg = nil
            self.currentUser = result.user
            self.isAuthenticated = true
        }

        await MainActor.run {
            self.firestoreManager.loadUserProfile(for: uid)
            self.firestoreManager.loadPastMoods(forUserId: uid)
        }

        print("User logged in: \(result.user.email ?? "Unknown")")
    }
    
    func sendVerificationEmail(email: String) async throws {
        let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://circles-nz.firebaseapp.com")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        print("Attempting to send email to: \(email)")
        print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Firebase Error: \(error)")
                    print("Error Code: \(error._code)")
                    self?.errorMsg = "Failed to send email: \(error.localizedDescription)"
                } else {
                    print("Email sent successfully")
                    UserDefaults.standard.set(email, forKey: "AuthEmail")
                    //self?.isEmailSent = true
                }
            }
        }
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
            firestoreManager.detachAllListeners()
            print("User signed out.")  // Listener handles updating isAuthenticated state
        } catch let signOutError as NSError {
            self.errorMsg = signOutError.localizedDescription
            print("Error signing out: \(signOutError)")

        }
    }
    
    func handleIncomingURL(url: URL) async {
        print("I received a URL: \(url.absoluteString)")
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
            await MainActor.run {
                self.isVerified = true
                print("Yeah?")
            }
        } else {
            print("nah not verified")
        }
    }
}
