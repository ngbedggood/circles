//
//  DayPageViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import Combine
import Foundation
import SwiftUI

// The unified ViewModel
class DayPageViewModel: ObservableObject {

    // PersonalCardView stuff
    @Published var currentMood: MoodColor?
    @Published var note: String = ""
    @Published var isMoodSelectionVisible: Bool = true
    @Published var expanded: Bool = false
    @Published var isVisible: Bool = true

    // SocialCardView stuff
    @Published var selectedFriend: FriendColor? = nil
    @Published var friendsWithMoods: [FriendWithMood] = []
    @Published var socialCard: SocialCard = SocialCard(date: "", friends: [])
    @Published var isLoading: Bool

    // Shared stuff
    @Published var dailyMood: DailyMood?

    let date: Date

    let authManager: AuthManager
    let firestoreManager: FirestoreManager

    let me : FriendColor
    
    init(date: Date, authManager: AuthManager, firestoreManager: FirestoreManager) {
        self.date = date
        self.authManager = authManager
        self.firestoreManager = firestoreManager

        self.isLoading = true

        let dateId = DailyMood.dateId(from: date)
        let dailyMood = firestoreManager.pastMoods[dateId]

        self.dailyMood = dailyMood
        self.currentMood = dailyMood?.mood
        self.note = dailyMood?.noteContent ?? ""
        self.isMoodSelectionVisible = dailyMood?.mood == nil
        self.expanded = dailyMood?.mood != nil
        
        self.me = FriendColor(name: "Me", username: "me", color: .gray, note: "Let's roll?")
        

    }

    // SOCIAL VIEW METHODS
    @MainActor  // Ensures all property updates within this method happen on the main thread
    func retrieveFriendsWithMoods() async {
        isLoading = true  // Start loading

        guard let userID = authManager.currentUser?.uid else {
            self.isLoading = false
            return
        }
        do {
            //self.dailyMood = try await firestoreManager.getDailyMood(forDate: date, forUserId: userID)
            let friendsUID = try await firestoreManager.fetchFriends(userID: userID)
            var results: [FriendColor] = []

            for uid in friendsUID {
                // do-catch block for each friend stops whole retrieval process from collapsing if a single friends getDailyMood() fails
                do {
                    if let mood = try await firestoreManager.getDailyMood(
                        forDate: date, forUserId: uid)
                    {
                        let profile = try await firestoreManager.fetchUserProfile(userID: uid)
                        let friend = FriendColor(
                            name: profile.displayName,
                            username: profile.username,
                            color: mood.mood,
                            note: mood.noteContent == "" ? "No note" : mood.noteContent ?? "No note"
                        )
                        results.append(friend)
                    }
                } catch {
                    //print("Failed to process friend \(uid): \(error.localizedDescription)")
                }
            }

            //for friend in results {
            //    print("\(friend.name) - \(friend.color?.color) - \(friend.note.prefix(40))")
            //}

            let todayString = DailyMood.dateId(from: date)
            self.socialCard = SocialCard(date: todayString, friends: results)
            self.isLoading = false
        } catch {
            self.isLoading = false
            print("Error: \(error.localizedDescription)")
        }
    }

    // SOCIAL VIEW UI FUNCTIONALITY STUFF
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }

    func toggleSelection(of friend: FriendColor) {
        if selectedFriend?.id == friend.id {
            selectedFriend = nil
        } else {
            selectedFriend = friend
        }
    }

    func clearSelection() {
        selectedFriend = nil
    }

    var meAsFriend: FriendColor {
        FriendColor(name: "Me", username: "me", color: .gray, note: "Let's roll!")
    }

    var isMeSelected: Bool {
        selectedFriend?.id == me.id
    }

    var someoneElseSelected: Bool {
        selectedFriend != nil && !isMeSelected
    }

    // PERSONAL VIEW METHODS
    func saveEntry() {
        guard let userId = authManager.currentUser?.uid else {
            print("Error: User not logged in. Cannot save note.")
            return
        }

        let entry = DailyMood(
            id: DailyMood.dateId(from: date),
            mood: currentMood ?? MoodColor.none,
            noteContent: note,
            createdAt: dailyMood?.createdAt ?? Date()
        )
        self.dailyMood = entry

        let newNote = note
        Task {
            do {
                try await firestoreManager.saveDailyMood(
                    date: date,
                    mood: currentMood ?? MoodColor.none,
                    content: newNote.isEmpty ? nil : newNote,
                    forUserID: userId
                )
                print("Daily entry saved successfully")
            } catch {
                print("Error saving daily entry: \(error.localizedDescription)")
            }
        }
        isMoodSelectionVisible = false
        expanded = false
    }

    func deleteEntry() {
        guard let userId = authManager.currentUser?.uid else {
            print("Error: User not logged in. Cannot delete note.")
            return
        }
        Task {
            do {
                try await firestoreManager.deleteDailyMood(date: date, forUserID: userId)
                print("Daily entry for \(date) deleted successfully")
            } catch {
                print(
                    "Error deleting daily entry: \(error.localizedDescription)"
                )
            }
        }
        isMoodSelectionVisible = true
        currentMood = nil
        expanded = false
        isVisible = true
    }
}
