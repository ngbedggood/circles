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
    @Published var isAvailable: Bool = true
    @Published var errorMsg: String?

    // The AuthManager owns the instance of FirestoreManager, all data flows through here.
    let fm = FirestoreManager()
    @Published var isFirestoreLoading = true
    private var cancellables = Set<AnyCancellable>()

    init() {

        // How to bubble up flags in nested objects
        fm.$isLoading
            .receive(on: RunLoop.main)
            .assign(to: \.isFirestoreLoading, on: self)
            .store(in: &cancellables)

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
                    self.fm.loadUserProfile(for: uid)

                } else {
                    // If no one is logged in/authenticated then detach all Firestore listeners and clear data.
                    self.fm.detachAllListeners()
                    print("User logged out or not authenticated. Detaching Firestore listeners.")
                }

            }
        }
    }

    func login(email: String, password: String) {
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                let uid = result.user.uid

                await MainActor.run {
                    self.errorMsg = nil
                    self.currentUser = result.user
                    self.isAuthenticated = true
                }

                await MainActor.run {
                    self.fm.loadUserProfile(for: uid)
                    self.fm.loadPastMoods(forUserId: uid)
                }

                print("User logged in: \(result.user.email ?? "Unknown")")
            } catch {
                await MainActor.run {
                    self.errorMsg = error.localizedDescription
                }
                print("Login error: \(error.localizedDescription)")
            }
        }
    }

    func signUp(email: String, password: String, username: String, displayName: String) {
        Task {
            do {
                let isAvailable = try await fm.isUsernameAvailable(username)
                guard isAvailable else {
                    DispatchQueue.main.async {
                        self.errorMsg = "Username '\(username)' is already taken."
                    }
                    return
                }

                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = result.user.uid

                try await fm.saveUserProfile(uid: uid, username: username, displayName: displayName)

                // If loadUserProfile sets any @Published properties, wrap it:
                await MainActor.run {
                    self.currentUser = result.user
                    self.isAuthenticated = true
                }

                // These also need to run on main thread if they modify @Published vars
                await MainActor.run {
                    self.fm.loadUserProfile(for: uid)
                    self.fm.loadPastMoods(forUserId: uid)
                    self.errorMsg = nil
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMsg = error.localizedDescription
                    print("Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }
    

    func signOut() {
        do {
            try Auth.auth().signOut()
            fm.detachAllListeners()
            print("User signed out.")  // Listener handles updating isAuthenticated state
        } catch let signOutError as NSError {
            self.errorMsg = signOutError.localizedDescription
            print("Error signing out: \(signOutError)")

        }
    }
}
