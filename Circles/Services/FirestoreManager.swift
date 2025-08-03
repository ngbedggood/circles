//
//  FirestoreManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

// The purpose of the FirestoreManager is to communicate with the Firestore database to complete CRUD operations. Methods are laid out for use by the app's logic.

import FirebaseFirestore
import Foundation
import SwiftUI

class FirestoreManager: FirestoreManagerProtocol {

    let daysToRetrieve: Int = 7

    private let db = Firestore.firestore()

    // reminder, published means that views observing this will update when DailyMoods changes.
    @Published var dailyMoods: [DailyMood] = []
    @Published var pastMoods: [String: DailyMood] = [:]  // Empty dictionary for date ID to mood
    @Published var isLoading: Bool = true
    @Published var userProfile: UserProfile?

    // This allows a "subscription" to Firestore. Will be managed to stop listening when user logs out.
    private var DailyMoodsListener: ListenerRegistration?
    private var PastMoodsListener: ListenerRegistration?

    private var errorMsg: String = ""

    // USER SIGNUP RELATED METHODS
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let doc = try await db.collection("usernames").document(username).getDocument()
        return !doc.exists
    }

    func updateDisplayName(uid: String, newName: String) async throws {

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        try await userRef.updateData([
            "displayName": newName
        ])
    }

    func saveUserProfile(uid: String, username: String, displayName: String) async throws {
        let userRef = db.collection("users").document(uid)
        let usernameRef = db.collection("usernames").document(username)

        try await _ = db.runTransaction({ (transaction, errorPointer) -> Any? in
            let usernameDoc: DocumentSnapshot
            do {
                usernameDoc = try transaction.getDocument(usernameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            if usernameDoc.exists {
                let error = NSError(
                    domain: "Firestore", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
                errorPointer?.pointee = error
                return nil
            }

            transaction.setData(["uid": uid], forDocument: usernameRef)
            transaction.setData(
                [
                    "username": username,
                    "displayName": displayName,
                    "createdAt": FieldValue.serverTimestamp(),
                ], forDocument: userRef)

            return nil
        })
    }

    func loadUserProfile(for uid: String) {
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }

            do {
                if let snapshot = snapshot, snapshot.exists {
                    self.userProfile = try snapshot.data(as: UserProfile.self)
                    print("Loaded user profile: \(self.userProfile?.username ?? "nil")")
                }
            } catch {
                print("Error decoding user profile: \(error.localizedDescription)")
            }
        }
    }

    func fetchUsername(for uid: String) async throws -> String? {

        Task { @MainActor in
            withAnimation {
                self.isLoading = true
            }
        }
        let querySnapshot = try await db.collection("usernames")
            .whereField("uid", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments()

        if let document = querySnapshot.documents.first {
            Task { @MainActor in
                withAnimation {
                    self.isLoading = false
                }
            }
            return document.documentID
        } else {
            Task { @MainActor in
                withAnimation {
                    self.isLoading = false
                }
            }
            return nil
        }
    }

    // SOCIAL STUFF
    func searchUsersWithRequestStatus(byUsername username: String, excludingUserID: String)
        async throws
        -> [SearchResultUser]
    {
        var results: [SearchResultUser] = []

        // Get users matching the username
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: username)
            .whereField("username", isLessThanOrEqualTo: username + "\u{f8ff}")
            .getDocuments()

        let foundUsers = snapshot.documents.compactMap { doc -> UserProfile? in
            let profile = try? doc.data(as: UserProfile.self)
            return profile?.uid != excludingUserID ? profile : nil
        }

        // Check for each user if a request from the current user exists in THEIR requests
        results = try await withThrowingTaskGroup(of: SearchResultUser.self) { group in
            for user in foundUsers {
                group.addTask {
                    let requestRef = self.db
                        .collection("users")
                        .document(user.uid ?? "")
                        .collection("friendRequests")

                    let snapshot =
                        try await requestRef
                        .whereField("from", isEqualTo: excludingUserID)
                        .limit(to: 1)
                        .getDocuments()

                    let requestExists = !snapshot.isEmpty

                    return SearchResultUser(user: user, requestSent: requestExists)
                }
            }

            return try await group.reduce(into: [SearchResultUser]()) { $0.append($1) }
        }

        return results
    }

    func sendFriendRequest(from senderID: String, to receiverID: String) async throws {

        // First check that there isn't already an existing request
        let requestsRef = db.collection("users").document(receiverID).collection("friendRequests")

        let query =
            requestsRef
            .whereField("from", isEqualTo: senderID)
            .whereField("to", isEqualTo: receiverID)

        let snapshot = try await query.getDocuments()

        let canSend = snapshot.documents.isEmpty

        guard canSend else {
            print("FSM: A friend request with this user already exists")
            return
        }

        let data: [String: Any] = [
            "from": senderID,
            "to": receiverID,
            "status": "pending",
        ]
        _ =
            try await db
            .collection("users")
            .document(receiverID)
            .collection("friendRequests")
            .addDocument(data: data)
    }

    func acceptFriendRequest(requestID: String, userID: String, friendID: String) async throws {
        // Add each user to the other's friend list
        print("Accessing myself:")
        try await db.collection("users").document(userID)
            .collection("friends").document(friendID).setData(["since": Date()])
        print("Accessing them:")
        try await db.collection("users").document(friendID)
            .collection("friends").document(userID).setData(["since": Date()])
        print("Trying to delete request:")

        // Delete the request
        try await db.collection("users").document(userID)
            .collection("friendRequests").document(requestID).delete()

        print("\(userID) and \(friendID) are now friends")
    }

    func fetchPendingFriendRequests(for userID: String) async throws -> [FriendRequest] {
        let snapshot = try await db.collection("users").document(userID).collection(
            "friendRequests"
        )
        .whereField("to", isEqualTo: userID)
        .getDocuments()

        return snapshot.documents.compactMap {
            try? $0.data(as: FriendRequest.self)
        }
    }

    func fetchUserProfile(userID: String) async throws -> UserProfile {
        let doc = try await db.collection("users").document(userID).getDocument()
        return try doc.data(as: UserProfile.self)
    }

    func fetchFriends(userID: String) async throws -> [String] {
        let friendsDocRef = db.collection("users").document(userID).collection("friends")
        let snapshot = try await friendsDocRef.getDocuments()

        return snapshot.documents.map { $0.documentID }  // Return documentID (friend's UID) from array of QueryDocumentSnapshot
    }

    func deleteFriend(userID: String, friendID: String) async throws {
        let currentUserFriendRef = db.collection("users").document(userID)
            .collection("friends").document(friendID)
        let otherUserFriendRef = db.collection("users").document(friendID)
            .collection("friends").document(userID)
        let batch = db.batch()
        batch.deleteDocument(currentUserFriendRef)
        batch.deleteDocument(otherUserFriendRef)

        // Firebase doesn’t support async batches yet, so we wrap it manually:
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            batch.commit { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

    }

    func usernameToUID(username: String) async throws -> String {
        let ref = db.collection("usernames").document(username)

        let snapshot = try await ref.getDocument()

        if let data = snapshot.data(),
            let uid = data["uid"] as? String
        {
            return uid
        } else {
            return ""
        }
    }

    // DAILY MOOD RELATED METHODS
    func saveDailyMood(date: Date, mood: MoodColor, content: String?, forUserID userId: String)
        async throws
    {
        // Convert date to string
        let moodId = DailyMood.dateId(from: date)
        // Create reference to doument path (/users/{userId}/DailyMoods/{YYYY-MM-DD}
        let moodDocRef = db.collection("users").document(userId).collection("dailyMoods").document(
            moodId)
        // Check if mood exists
        let existingmoodSnapshot = try? await moodDocRef.getDocument()
        let isNewmood = !(existingmoodSnapshot?.exists ?? false)

        let moodToSave: DailyMood
        // Fill in new mood
        if isNewmood {
            moodToSave = DailyMood(
                id: moodId,
                mood: mood,
                noteContent: content ?? "",
                createdAt: Date(),
                updatedAt: Date()
            )
        } else {
            // Check for and then update exisiting mood
            var existingmood =
                try existingmoodSnapshot?.data(as: DailyMood.self)
                ?? DailyMood(id: moodId, mood: mood, noteContent: "", createdAt: Date())
            existingmood.mood = mood
            existingmood.noteContent = content
            existingmood.updatedAt = Date()
            moodToSave = existingmood
        }

        do {
            try moodDocRef.setData(from: moodToSave)
            print("Daily mood for \(moodId) by \(userId) was save successfully!")
        } catch {
            print("Error saving daily mood: \(error.localizedDescription)")
            throw error
        }
    }

    // Fetch a daily mood from a specific date
    func getDailyMood(forDate date: Date, forUserId userId: String) async throws -> DailyMood? {
        let moodId = DailyMood.dateId(from: date)
        let moodDocRef = db.collection("users").document((userId)).collection("dailyMoods")
            .document(moodId)
        do {
            // Try to retrieve document and convert to DailyMood struct
            let document = try await moodDocRef.getDocument()
            return try document.data(as: DailyMood.self)
        } catch let error as NSError
            where error.domain == FirestoreErrorDomain
            && error.code == FirestoreErrorCode.notFound.rawValue
        {
            print("No mood found for \(moodId).")  // Cant find mood error
            return nil
        } catch {
            //print("Error fetching specific daily mood for \(userId): \(error.localizedDescription)")  // Something else error
            throw error
        }

    }

    // Load all moods
    func loadDailyMoods(forUserId userId: String) {
        DailyMoodsListener?.remove()

        DailyMoodsListener = db.collection("users").document(userId).collection("dailyMoods")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in  // This block runs whenever data changes.
                guard let self = self else { return }  // Safely unwrap self to prevent retain cycles.
                if let error = error {
                    print("Error fetching daily moods: \(error.localizedDescription)")
                    return
                }
                // If there are documents, map them into our DailyMood array.
                // compactMap handles potential conversion errors
                self.dailyMoods =
                    querySnapshot?.documents.compactMap { document in
                        try? document.data(as: DailyMood.self)
                    } ?? []  // If no documents or an error, set to an empty array.
                print("Loaded \(self.dailyMoods.count) daily moods for user \(userId).")

            }
    }

    // Deletes a specific daily mood.
    func deleteDailyMood(date: Date, forUserID userId: String) async throws {
        let moodId = DailyMood.dateId(from: date)
        do {
            let moodDocRef = db.collection("users").document(userId).collection("dailyMoods")
                .document(moodId)
            try await moodDocRef.delete()
            print("Daily mood for \(moodId) by \(userId) successfully deleted!")
        } catch {
            print("Error deleting daily mood: \(error.localizedDescription)")
            throw error
        }
    }

    @MainActor
    func loadPastMoods(forUserId userId: String) {
        withAnimation {
            self.isLoading = true
        }
        self.errorMsg = ""
        self.pastMoods = [:]

        PastMoodsListener?.remove()

        let calendar = Calendar.current
        let now = Date()
        let todayStartOfDay = calendar.startOfDay(for: now)

        // Calculate the start and end date for the query range
        guard
            let startDate = calendar.date(
                byAdding: .day, value: -(daysToRetrieve - 1), to: todayStartOfDay),
            let endDate = calendar.date(byAdding: .day, value: 1, to: todayStartOfDay)
        else {
            self.errorMsg = "Failed to calculate date range for past moods."
            withAnimation {
                self.isLoading = false
            }
            return
        }

        // Generate the lower and upper bound document ID string
        let startDocID = DailyMood.dateId(from: startDate)
        let endDocID = DailyMood.dateId(from: endDate)

        print(
            "[\(Date())] FirestoreManager: Initiating fetch for moods with Document IDs from \(startDocID) (inclusive) to \(endDocID) (exclusive)."
        )

        PastMoodsListener = db.collection("users").document(userId).collection("dailyMoods")
            // Using Document ID instead of createBy date for filtering
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: startDocID)
            .whereField(FieldPath.documentID(), isLessThan: endDocID)
            .order(by: FieldPath.documentID(), descending: false)  // Chronological
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print(
                        "[\(Date())] ERROR: Firestore query failed: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.errorMsg = "Failed to load moods: \(error.localizedDescription)"
                        withAnimation {
                            self.isLoading = false
                        }
                    }
                    return
                }

                var fetchedMoods: [String: DailyMood] = [:]
                for document in querySnapshot?.documents ?? [] {
                    do {
                        let dailyMood = try document.data(as: DailyMood.self)
                        fetchedMoods[document.documentID] = dailyMood
                    } catch {
                        print(
                            "[\(Date())] Failed to decode DailyMood for document ID '\(document.documentID)': \(error.localizedDescription)"
                        )
                        if let decodingError = error as? DecodingError {
                            print("  - Decoding Error Details: \(decodingError)")
                        }
                    }
                }

                Task { @MainActor in
                    self.pastMoods = fetchedMoods
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
    }

    // Call this method when a user logs out to stop all Firestore real-time updates
    // and clear any data that belongs to the previous user.
    func detachAllListeners() {
        DailyMoodsListener?.remove()
        DailyMoodsListener = nil
        self.dailyMoods = []

        PastMoodsListener?.remove()
        PastMoodsListener = nil
        self.pastMoods = [:]
        withAnimation {
            self.isLoading = true
        }

        print("All Firestore listeners detached and data cleared.")
    }

}
