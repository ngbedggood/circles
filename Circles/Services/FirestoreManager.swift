//
//  FirestoreManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

// The purpose of the FirestoreManager is to communicate with the Firestore database to complete CRUD operations. Methods are laid out for use by the app's logic.

import FirebaseFirestore
import Foundation

class FirestoreManager: ObservableObject {

    let howManyDaysToRetrieve: Int = 7

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
    
    func saveUserProfile(uid: String, username: String, displayName: String) async throws {
        let userRef = db.collection("users").document(uid)
        let usernameRef = db.collection("usernames").document(username)

        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let usernameDoc: DocumentSnapshot
            do {
                usernameDoc = try transaction.getDocument(usernameRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            if usernameDoc.exists {
                let error = NSError(domain: "Firestore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
                errorPointer?.pointee = error
                return nil
            }

            transaction.setData(["uid": uid], forDocument: usernameRef)
            transaction.setData([
                "username": username,
                "displayName": displayName,
                "createdAt": FieldValue.serverTimestamp()
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
            try await moodDocRef.setData(from: moodToSave)
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
            print("Error fetching specific daily mood: \(error.localizedDescription)")  // Something else error
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
    func deleteDailyMood(date: Date, forUserId userId: String) async throws {
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

    func loadPastMoods(forUserId userId: String) {
        PastMoodsListener?.remove()

        let today = Calendar.current.startOfDay(for: Date())

        guard
            let startDate = Calendar.current.date(
                byAdding: .day, value: -(howManyDaysToRetrieve - 1), to: today)
        else {
            self.errorMsg = "Failed to calculate start date for moods."
            print("Could not calculate start date for past moods.")
            return
        }

        print("[\(Date())] FirestoreManager: Initiating fetch for moods from \(startDate)")

        PastMoodsListener = db.collection("users").document(userId).collection("dailyMoods")
            .whereField("createdAt", isGreaterThanOrEqualTo: startDate)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print(
                        "[\(Date())] ERROR: Firestore query failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {  // Ensure error state update is on main thread
                        self.errorMsg = "Failed to load moods: \(error.localizedDescription)"
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

                DispatchQueue.main.async {
                    self.pastMoods = fetchedMoods
                    self.isLoading = false
                    print(
                        "[\(Date())] Loaded \(self.pastMoods.count) moods for the last 7 days for user \(userId)."
                    )
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
        self.isLoading = true

        print("All Firestore listeners detached and data cleared.")
    }

}
