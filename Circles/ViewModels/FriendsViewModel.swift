//
//  FriendsViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Foundation
import Combine
import SwiftUI

class FriendsViewModel: ObservableObject {
    @Published var newDisplayName: String = ""
    @Published var searchQuery = ""
    @Published private(set) var newDisplayNameChangeSuccess: Bool = false
    @Published private(set) var searchResults: [SearchResultUser] = []
    @Published private(set) var pendingRequests: [FriendRequest] = []
    @Published private(set) var pendingRequestsWithUsers: [RequestWithUser] = []
    @Published private(set) var friendsList: [FriendColor] = []
    @Published private(set) var error: String?
    @Published private(set) var hasSearched: Bool = false
    @Published var errorMessage: String?
    
    @Published private(set) var isLoadingFriendsList: Bool = true
    @Published private(set) var isLoadingPendingRequests: Bool = true
    
    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success

    let firestoreManager: FirestoreManager
    let authManager: any AuthManagerProtocol

    init(firestoreManager: FirestoreManager, authManager: any AuthManagerProtocol) {
        self.firestoreManager = firestoreManager
        self.authManager = authManager
    }
    
    func updateDisplayName() async {
        guard !newDisplayName.isEmpty
        else {
            await MainActor.run {
                self.errorMessage = "Username can't be empty."
                self.showToast = false
                self.toastMessage = self.errorMessage ?? "An error occurred!"
                self.toastStyle = .error
                self.showToast = true
            }
            return
        }
        guard let currentUserID = authManager.currentUser?.uid else { return }
        Task {
            do {
                try await firestoreManager.updateDisplayName(uid: currentUserID, newName: newDisplayName)
                await MainActor.run {
                    self.showToast = false
                    self.toastMessage = "Updated display name"
                    self.toastStyle = .success
                    self.showToast = true
                }
                
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }
        }
    }

    func searchUsers() {
        withAnimation {
            hasSearched = false
        }
        guard !searchQuery.isEmpty else {
            return
        }
        guard let currentUserID = authManager.currentUser?.uid else { return }
        Task {
            do {
                let results = try await firestoreManager.searchUsersWithRequestStatus(byUsername: searchQuery.lowercased(), excludingUserID: currentUserID)
                await MainActor.run {
                    withAnimation {
                        self.searchResults = results
                        hasSearched = true
                    }
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
            await MainActor.run {
                if let index = searchResults.firstIndex(where: { $0.user.uid == user.uid }) {
                    withAnimation {
                        searchResults[index].requestSent = true
                    }
                }
                self.showToast = false
                self.toastMessage = "A friend request has been sent"
                self.toastStyle = .success
                self.showToast = true
            }
        }
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
    
    @MainActor
    func fetchFriendRequests() {
        self.isLoadingPendingRequests = true
        guard let userID = authManager.currentUser?.uid else { return }
        Task {
            do {
                let requests = try await firestoreManager.fetchPendingFriendRequests(for: userID)
                var enrichedRequests: [RequestWithUser] = []
                for request in requests {
                    let senderProfile = try await firestoreManager.fetchUserProfile(userID: request.from)
                    let combined = RequestWithUser(request: request, user: senderProfile)
                    enrichedRequests.append(combined)
                }

                await MainActor.run {
                    self.pendingRequestsWithUsers = enrichedRequests
                }
                self.isLoadingPendingRequests = false
            } catch {
                print("Error fetching pending requests with users: \(error.localizedDescription)")
                self.isLoadingPendingRequests = false
            }
        }
    }
    
    @MainActor
    func acceptRequest(_ request: FriendRequest) async {
        guard let requestID = request.id else { return }
        guard friendsList.count < 8 else {
            self.showToast = false
            self.toastMessage = "You've already reached the maximum nunber of friends"
            self.toastStyle = .warning
            self.showToast = true
            return
        }
        try? await firestoreManager.acceptFriendRequest(requestID: requestID, userID: request.to, friendID: request.from)
        await MainActor.run {
            if let index = pendingRequests.firstIndex(where: { $0.id == request.id }) {
                pendingRequests.remove(at: index)
            }
            if let index = pendingRequestsWithUsers.firstIndex(where: { $0.id == request.id }) {
                _ = withAnimation {
                    pendingRequestsWithUsers.remove(at: index)
                }
            }
            //self.pendingRequests.removeAll { $0.id == request.id }
            self.showToast = false
            self.toastMessage = "Accepted friend request!"
            self.toastStyle = .success
            self.showToast = true
            fetchFriendList()
        }
        print("Accepted request from: \(requestID)")
    }
    
    
    @MainActor
    func fetchFriendList() {
        self.isLoadingFriendsList = true
        guard let userID = authManager.currentUser?.uid else { return }
        Task {
            do {
                let friendsUID = try await firestoreManager.fetchFriends(userID: userID)

                for uid in friendsUID {
                    let profile = try await firestoreManager.fetchUserProfile(userID: uid)
                    let friend = FriendColor(
                        name: profile.displayName,
                        username: profile.username,
                        color: MoodColor.none,
                        note: ""
                    )
                    friendsList.append(friend)
                }
                self.isLoadingFriendsList = false
            } catch {
                print("FVM - Error fetching friends: \(error.localizedDescription)")
                self.isLoadingFriendsList = false
            }

        }
    }
    
    func deleteFriend(_ friendUsername: String) {
        guard let userID = authManager.currentUser?.uid else { return }
        
        Task {
            do {
                let friendID = try await firestoreManager.usernameToUID(username: friendUsername)
                try await firestoreManager.deleteFriend(userID: userID, friendID: friendID)
                await MainActor.run {
                    if let index = friendsList.firstIndex(where: { $0.username == friendUsername }) {
                        _ = withAnimation {
                            friendsList.remove(at: index)
                        }
                    }
                    self.showToast = false
                    self.toastMessage = "Deleted friend!"
                    self.toastStyle = .warning
                    self.showToast = true
                }
            } catch {
                print("FVM - Error deleting friend: \(error.localizedDescription)")
            }
        }
    }
}
