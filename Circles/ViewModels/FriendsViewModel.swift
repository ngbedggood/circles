//
//  FriendsViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Combine
import Foundation

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

    @Published var showNotificationsRequestPrompt: Bool = false

    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success
    
    // Notification related
//    @MainActor
//    @Published var selectedTime: Date {
//        didSet { notificationManager.updateReminderNotification(isReminderOn: isReminderSet, selectedTime: selectedTime) }
//    }
//    @MainActor
//    @Published var isReminderSet: Bool {
//        didSet { notificationManager.updateReminderNotification(isReminderOn: isReminderSet, selectedTime: selectedTime) }
//    }
    @Published var selectedTime: Date
    @Published var isReminderOn: Bool
    var lastSelectedTime: Date?
    var lastReminderState: Bool?

    let firestoreManager: FirestoreManager
    let authManager: any AuthManagerProtocol
    let notificationManager: NotificationManager

    @MainActor
    init(
        firestoreManager: FirestoreManager, authManager: any AuthManagerProtocol,
        notificationManager: NotificationManager
    ){
        self.firestoreManager = firestoreManager
        self.authManager = authManager
        self.notificationManager = notificationManager
        self.newDisplayName = UserDefaults.standard.string(forKey: "DisplayName") ?? ""
        
        self.selectedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date ?? Date()
        self.isReminderOn = UserDefaults.standard.bool(forKey: "reminderOn")
        var hasMoodToday = false
        Task {
            let uid = authManager.currentUser?.uid ?? ""
            hasMoodToday = (try await firestoreManager.getDailyMood(forDate: Date(), forUserId: uid)) != nil
        }
        if hasMoodToday {
            notificationManager.scheduleNextBatchOfReminders(forTime: selectedTime)
        }
    }

    func promptUserForNotifications() {
        print("before: \(showNotificationsRequestPrompt)")
        showNotificationsRequestPrompt = true
        print("before: \(showNotificationsRequestPrompt)")
    }

    // Call notificationManager's request method
    func requestNotifications() async {
        print("requesting notifications")
        await notificationManager.requestAuthorization()
    }

    func checkNotificationAuthStatus() async -> Bool {
        await notificationManager.getAuthStatus()
        return notificationManager.hasPermission
    }
    
    // Reminder related notifications
    func updateReminderNotification() {
        // Track the previous state to avoid unecessary method calls when navigating around
        if selectedTime != lastSelectedTime || isReminderOn != lastReminderState {
            notificationManager.updateReminderNotification(isReminderOn: isReminderOn, selectedTime: selectedTime)
            lastSelectedTime = selectedTime
            lastReminderState = isReminderOn
        }
    }

    @MainActor
    func updateDisplayName() async {
        guard !newDisplayName.isEmpty
        else {
            self.errorMessage = "Name can't be empty."
            self.showToast = false
            self.toastMessage = self.errorMessage ?? "An error occurred!"
            self.toastStyle = .error
            self.showToast = true
            return
        }
        guard let currentUserID = authManager.currentUser?.uid else { return }
        do {
            try await firestoreManager.updateDisplayName(
                uid: currentUserID, newName: newDisplayName)
            self.showToast = false
            self.toastMessage = "Updated display name"
            self.toastStyle = .success
            self.showToast = true
            UserDefaults.standard.set(newDisplayName, forKey: "DisplayName")
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func searchUsers() async {
        hasSearched = false
        guard !searchQuery.isEmpty else {
            return
        }
        guard let currentUserID = authManager.currentUser?.uid else { return }
        do {
            let results = try await firestoreManager.searchUsersWithRequestStatus(
                byUsername: searchQuery.lowercased(),
                excludingUserID: currentUserID
            )

            self.searchResults = results
            hasSearched = true
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func sendRequest(to user: UserProfile) async {
        guard let fromID = authManager.currentUser?.uid else { return }
        guard let toID = user.uid else { return }

        // Check if user is already a friend
        if friendsList.contains(where: { $0.username == user.username }) {
            self.showToast = false
            self.toastMessage = "They're already on your friends list."
            self.toastStyle = .warning
            self.showToast = true
            return
        }

        try? await firestoreManager.sendFriendRequest(from: fromID, to: toID)
        if let index = searchResults.firstIndex(where: { $0.user.uid == user.uid }) {
            searchResults[index].requestSent = true
        }
        self.showToast = false
        self.toastMessage = "A friend request has been sent"
        self.toastStyle = .success
        self.showToast = true
    }

    @MainActor
    func fetchFriendRequests() async {
        self.isLoadingPendingRequests = true
        guard let userID = authManager.currentUser?.uid else { return }
        do {
            let requests = try await firestoreManager.fetchPendingFriendRequests(for: userID)
            let enrichedRequests: [RequestWithUser] = try await withThrowingTaskGroup(
                of: RequestWithUser.self
            ) { group in
                for request in requests {
                    group.addTask {
                        let senderProfile = try await self.firestoreManager.fetchUserProfile(
                            userID: request.from)
                        return RequestWithUser(request: request, user: senderProfile)
                    }
                }
                var results: [RequestWithUser] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
            self.pendingRequestsWithUsers = enrichedRequests
        } catch {
            print("Error fetching pending requests with users: \(error.localizedDescription)")
        }
        self.isLoadingPendingRequests = false
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
        try? await firestoreManager.acceptFriendRequest(
            requestID: requestID, userID: request.to, friendID: request.from)
        if let index = pendingRequests.firstIndex(where: { $0.id == request.id }) {
            pendingRequests.remove(at: index)
        }
        if let index = pendingRequestsWithUsers.firstIndex(where: { $0.id == request.id }) {
            pendingRequestsWithUsers.remove(at: index)
        }
        //self.pendingRequests.removeAll { $0.id == request.id }
        self.showToast = false
        self.toastMessage = "Accepted friend request!"
        self.toastStyle = .success
        self.showToast = true
        await fetchFriendList()
        print("Accepted request from: \(requestID)")
    }

    @MainActor
    func fetchFriendList() async {
        self.isLoadingFriendsList = true
        guard let userID = authManager.currentUser?.uid else { return }

        do {
            let friendsUID = try await firestoreManager.fetchFriends(userID: userID)
            var fetchedFriends: [FriendColor] = []

            // Parallell retrieving
            try await withThrowingTaskGroup(of: FriendColor.self) { group in
                for uid in friendsUID {
                    group.addTask {
                        let profile = try await self.firestoreManager.fetchUserProfile(userID: uid)
                        return FriendColor(
                            uid: uid,
                            name: profile.displayName,
                            username: profile.username,
                            color: MoodColor.none,
                            note: "",
                            time: Date(),
                            streakCount: 0
                        )
                    }
                }

                for try await friend in group {
                    fetchedFriends.append(friend)
                }
            }
            self.friendsList = fetchedFriends
            self.isLoadingFriendsList = false

            // Prompting for permission when a friend is found before the first time the user is prompted
            if friendsList.count > 0 {
                print(
                    "UserDefaults - hasPromptedForPush: \(UserDefaults.standard.bool(forKey: "hasPromptedForPush"))"
                )
                if !UserDefaults.standard.bool(forKey: "hasPromptedForPush") {
                    let isNotificationsEnabled = await checkNotificationAuthStatus()
                    if !isNotificationsEnabled {
                        print("About to prompt user for notifications")
                        promptUserForNotifications()
                    }
                }
            } else {
                print("No friends just yet...")
            }
        } catch {
            print("FVM - Error fetching friends: \(error.localizedDescription)")
            self.isLoadingFriendsList = false
        }
    }

    @MainActor
    func deleteFriend(_ friendUsername: String) async {
        guard let userID = authManager.currentUser?.uid else { return }
        do {
            let friendID = try await firestoreManager.usernameToUID(username: friendUsername)
            try await firestoreManager.deleteFriend(userID: userID, friendID: friendID)
            if let index = friendsList.firstIndex(where: { $0.username == friendUsername }) {
                friendsList.remove(at: index)
            }
            self.showToast = false
            self.toastMessage = "Deleted friend!"
            self.toastStyle = .warning
            self.showToast = true
        } catch {
            print("FVM - Error deleting friend: \(error.localizedDescription)")
        }
    }

    @MainActor
    func signOut() async {
        authManager.signOut()
    }
}
