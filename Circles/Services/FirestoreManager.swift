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

    private let db: Firestore

    // reminder, published means that views observing this will update when DailyMoods changes.
    @Published var dailyMoods: [DailyMood] = []
    @Published var pastMoods: [String: DailyMood] = [:]  // Empty dictionary for date ID to mood
    @Published var isLoading: Bool = true
    @Published var isFirstLoad: Bool = true
    @Published var userProfile: UserProfile?

    // This allows a "subscription" to Firestore. Will be managed to stop listening when user logs out.
    private var DailyMoodsListener: ListenerRegistration?
    private var PastMoodsListener: ListenerRegistration?

    private var errorMsg: String = ""
    
    init() {
        db = Firestore.firestore()
    }
    
    // Used by StreakManager class
    func fetchUserData(userId: String) async throws -> [String: Any] {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document data was empty."])
        }
        return data
    }

    func updateUserData(userId: String, fields: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(fields)
    }

    // USER SIGNUP RELATED METHODS
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let doc = try await db.collection("usernames").document(username).getDocument()
        return !doc.exists
    }

    func updateDisplayName(uid: String, newName: String) async throws {
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

    @MainActor
    func loadUserProfile(for uid: String) async {
        let userRef = db.collection("users").document(uid)
        do {
            self.userProfile = try await userRef.getDocument(as: UserProfile.self)
            print("Successfully loaded user profile: \(self.userProfile?.username ?? "N/A")")
        } catch {
            print("Error loading or decoding user profile: \(error.localizedDescription)")
        }
    }
    
    func saveUserTimezone(for uid: String) async throws {
        let tzIdentifier = TimeZone.current.identifier
            
        try await db.collection("users").document(uid).setData([
            "timezone": tzIdentifier
        ], merge: true)
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
    
    func findFriendMoodDocumentID(forViewerDate: Date, friendUID: String) async throws -> String? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let startOfDay = calendar.startOfDay(for: forViewerDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let query = db.collection("users").document(friendUID).collection("dailyMoods")
            .whereField("createdAt", isGreaterThanOrEqualTo: startOfDay)
            .whereField("createdAt", isLessThan: endOfDay)
            .limit(to: 1)

        let snapshot = try await query.getDocuments()
        return snapshot.documents.first?.documentID
    }


    // SOCIAL STUFF
    func emoteReactToFriendsPost(date: Date, fromUID: String, toUID: String, emote: String) async throws {
        

        guard let moodId = try await findFriendMoodDocumentID(forViewerDate: date, friendUID: toUID) else {
            print("Couldn't find friend mood ID")
            return
        }

        
        let reactDocRef = db
            .collection("users")
            .document(toUID)
            .collection("dailyMoods")
            .document(moodId)
            .collection("reactions")
            .document(fromUID)
        
        
        // Check if mood exists
        let existingReactionSnapshot = try? await reactDocRef.getDocument()
        let isNewReact = !(existingReactionSnapshot?.exists ?? false)
        
        let reactToSave: Reaction
        // Fill in new mood
        if isNewReact {
            reactToSave = Reaction(
                fromUID: fromUID,
                reaction: emote,
                createdAt: Date(),
                updatedAt: Date(),
                removed: false
            )
        } else {
            // Check for and then update exisiting mood
            var existingReact =
            try existingReactionSnapshot?.data(as: Reaction.self)
            ?? Reaction(fromUID: fromUID, reaction: emote, createdAt: Date(), updatedAt: Date(), removed: false)
            existingReact.reaction = emote
            existingReact.updatedAt = Date()
            existingReact.removed = false
            reactToSave = existingReact
            print("Update emote react.")
        }

        do {
            try reactDocRef.setData(from: reactToSave)
            print("Successfully reacted with \(emote) to: \(toUID) on their mood ID: \(moodId)")
        } catch {
            print("Error reacting to mood: \(error.localizedDescription)")
            throw error
        }
    }
    
    func removeReact(fromUID: String, toUID: String, date: Date) async throws {
        guard let moodId = try await findFriendMoodDocumentID(forViewerDate: date, friendUID: toUID) else {
            print("Couldn't find friend mood ID")
            return
        }
        do {
            let reactDocRef = db.collection("users").document(toUID).collection("dailyMoods")
                .document(moodId).collection("reactions").document(fromUID)
            try await reactDocRef.delete()
            print("React on \(moodId) for \(toUID) by \(fromUID) successfully deleted!")
        } catch {
            print("Error deleting react: \(error.localizedDescription)")
            throw error
        }
    }
    
    func softRemoveReact(fromUID: String, toUID: String, date: Date) async throws {
        do {
            
            guard let moodId = try await findFriendMoodDocumentID(forViewerDate: date, friendUID: toUID) else {
                print("Couldn't find friend mood ID")
                return
            }
            
            let reactDocRef = db
                .collection("users")
                .document(toUID)
                .collection("dailyMoods")
                .document(moodId)
                .collection("reactions")
                .document(fromUID)
            
            try await reactDocRef.updateData([
                "removed": true,
                "updatedAt": Date()
            ])
        }
    }
    
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

        // Check for each user if a request from the current user exists in their requests
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
    
    func fetchFriendCount(userID: String) async throws -> Int {
        let friendsDocRef = db.collection("users").document(userID).collection("friends")
        let snapshot = try await friendsDocRef.getDocuments()
        return snapshot.documents.count
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
        async throws -> Bool
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
        print("creating mood")
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
            print("updated mood")
        }
        

        do {
            try moodDocRef.setData(from: moodToSave)
            print("Daily mood for \(moodId) by \(userId) was save successfully!")
        } catch {
            print("Error saving daily mood: \(error.localizedDescription)")
            throw error
        }
        
        return isNewmood
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
    
    func getDailyMoodForViewerLocalDate(
        forDate viewerDate: Date,
        forUserId userId: String
    ) async throws -> DailyMood? {
        // 1. Use the current user's calendar to define the 24-hour window.
        var calendar = Calendar.current // This uses the viewer's local timezone
        calendar.timeZone = TimeZone.current

        // 2. Get the start and end of the day from the viewer's perspective.
        let startOfDay = calendar.startOfDay(for: viewerDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw NSError(domain: "DateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not calculate end of day."])
        }

        // `startOfDay` and `endOfDay` are now absolute UTC timestamps marking the viewer's local day.
        
        // 3. Query the friend's moods collection using a UTC time range.
        let query = db.collection("users").document(userId).collection("dailyMoods")
            .whereField("createdAt", isGreaterThanOrEqualTo: startOfDay)
            .whereField("createdAt", isLessThan: endOfDay)
            .limit(to: 1) // There should only be one mood per day.

        let snapshot = try await query.getDocuments()

        // 4. Decode and return the first document found.
        // using `compactMap` is a safe way to handle potential decoding errors.
        let dailyMood = snapshot.documents.compactMap { document -> DailyMood? in
            try? document.data(as: DailyMood.self)
        }.first

        return dailyMood
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
    func loadPastMoods(forUserId userId: String) async throws {
//        withAnimation {
//            self.isLoading = true
//        }
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
//            withAnimation {
//                self.isLoading = false
//            }
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
                    print("[\(Date())] Loaded \(fetchedMoods.count) past moods for user \(userId)")
                    
                    // IMPORTANT: Set loading to false AFTER pastMoods is updated
                    // This ensures the Combine observer fires before isLoading becomes false
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
    }
    
    func uploadFCMToken(uid: String, token: String) async throws {
        // Set reference
        let tokenRef = db
            .collection("users")
            .document(uid)
            .collection("deviceTokens")
            .document(token)
        
        do {
            // First check to minimise unecessary writes
            let snapshot = try await tokenRef.getDocument()
            if snapshot.exists {
                try await tokenRef.updateData([
                    "lastUpdated": FieldValue.serverTimestamp()
                ])
                print("Token already exists for \(uid), timestamp refreshed.")
                return
            }
            try await tokenRef.setData([
                "token": token,
                "lastUpdated": FieldValue.serverTimestamp()
            ])
            print("Token \(token) uploaded successfully for user \(uid)")
        } catch {
            print("Error uploading FCM token for user \(uid): \(error.localizedDescription)")
        }
    }

    // Call this method when a user logs out to stop all Firestore real-time updates
    // and clear any data that belongs to the previous user.
    func detachAllListeners() {
        self.userProfile = nil
        self.errorMsg = ""
        
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

extension Date {
    func convertToUTC(from timeZone: TimeZone) -> Date {
        let seconds = TimeInterval(timeZone.secondsFromGMT(for: self))
        return self.addingTimeInterval(-seconds)
    }
}
