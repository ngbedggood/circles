//
//  FriendsViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Foundation
import SwiftUI

class FriendsViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [UserProfile] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var pendingRequestsWithUsers: [RequestWithUser] = []
    @Published var error: String?
    

    private let firestoreManager: FirestoreManager
    private let authManager: AuthManager

    init(firestoreManager: FirestoreManager, authManager: AuthManager) {
        self.firestoreManager = firestoreManager
        self.authManager = authManager
    }

    func searchUsers() {
        guard let currentUserID = authManager.currentUser?.uid else { return }
        Task {
            do {
                let results = try await firestoreManager.searchUsers(byUsername: searchQuery.lowercased(), excludingUserID: currentUserID)
                await MainActor.run {
                    self.searchResults = results
                    print("Search results: \(results)")
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }
        }
    }

    func sendRequest(to user: UserProfile) {
        guard let fromID = authManager.currentUser?.uid else { return }
        guard let toID = user.uid else { return }
        Task {
            try? await firestoreManager.sendFriendRequest(from: fromID, to: toID)
        }
        print("Sent request to: \(user.uid)")
    }

    func loadPendingRequests() {
        guard let userID = authManager.currentUser?.uid else { return }
        Task {
            let requests = try await firestoreManager.fetchPendingFriendRequests(for: userID)
            await MainActor.run {
                self.pendingRequests = requests
            }
        }
        print("Pending requests: \(self.pendingRequests)")
    }
    
    func fetchFriendRequests() {
        guard let userId = authManager.currentUser?.uid else { return }
        Task {
            do {
                let requests = try await firestoreManager.fetchPendingFriendRequests(for: userId)
                var enrichedRequests: [RequestWithUser] = []

                for request in requests {
                    let senderProfile = try await firestoreManager.fetchUserProfile(uid: request.from)
                    let combined = RequestWithUser(request: request, user: senderProfile)
                    enrichedRequests.append(combined)
                }

                await MainActor.run {
                    self.pendingRequestsWithUsers = enrichedRequests
                }
                print(self.pendingRequestsWithUsers)
            } catch {
                print("Error fetching pending requests with users: \(error.localizedDescription)")
            }
        }
    }

    func acceptRequest(_ request: FriendRequest) {
        guard let requestID = request.id else { return }
        Task {
            try? await firestoreManager.acceptFriendRequest(requestID: requestID, userID: request.to, friendID: request.from)
            await MainActor.run {
                self.pendingRequests.removeAll { $0.id == request.id }
            }
        }
        print("Accepted request from: \(requestID)")
    }
}
