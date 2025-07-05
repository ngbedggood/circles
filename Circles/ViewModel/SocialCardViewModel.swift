//
//  SocialCardViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Foundation
import SwiftUI

struct FriendWithMood {
    var id: String
    var name: String
    var color: Color
    var note: String
}

class SocialCardViewModel: ObservableObject {
    @Published var selectedFriend: FriendColor? = nil
    @Published var friendsWithMoods: [FriendWithMood] = []
    @Published var socialCard: SocialCard = SocialCard(date: "", friends: [])
    @Published var isLoading: Bool
    
    @Binding var dailyMood: DailyMood?
    
    let me = FriendColor(name: "Me", color: .gray, note: "Lets roll!")
    
    let date: Date
    
    let authManager: AuthManager
    let firestoreManager: FirestoreManager

    init(date: Date, dailyMood: Binding<DailyMood?>, authManager: AuthManager, firestoreManager: FirestoreManager) {
        self.date = date
        self._dailyMood = dailyMood
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        self.isLoading = true
    }

    // UI functionality
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
        FriendColor(name: "Me", color: .gray, note: "Let's roll!")
    }
    
    var isMeSelected: Bool {
        selectedFriend?.id == me.id
    }

    var someoneElseSelected: Bool {
        selectedFriend != nil && !isMeSelected
    }
    
    // Friend retrieval functionality
    @MainActor // Ensures all property updates within this method happen on the main thread
    func retrieveFriendsWithMoods() async {
        isLoading = true // Start loading
        print("SVM -> The current mood is: \(dailyMood?.mood?.color ?? .none)")

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
                    if let mood = try await firestoreManager.getDailyMood(forDate: date, forUserId: uid) {
                        let profile = try await firestoreManager.fetchUserProfile(userID: uid)
                        let friend = FriendColor(
                            name: profile.displayName,
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
    
}
