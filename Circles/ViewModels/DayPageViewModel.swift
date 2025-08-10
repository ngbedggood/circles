//
//  DayPageViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import Combine
import Foundation

class DayPageViewModel: ObservableObject {

    // PersonalCardView stuff
    @Published var currentMood: MoodColor?
    @Published var note: String = ""
    @Published var expanded: Bool = false
    @Published var isVisible: Bool = true
    @Published private(set) var isMoodSelectionVisible: Bool = true
    @Published private(set) var showFriends: Bool = false

    // SocialCardView stuff
    @Published var selectedFriend: FriendColor? = nil
    @Published private(set) var friendsWithMoods: [FriendWithMood] = []
    @Published private(set) var socialCard: SocialCard = SocialCard(date: "", friends: [])
    @Published private(set) var isLoading: Bool

    // Shared stuff
    @Published private(set) var dailyMood: DailyMood?
    @Published var isDayVerticalScrollDisabled: Bool = false

    let date: Date
    let authManager: any AuthManagerProtocol
    let firestoreManager: FirestoreManager
    private var scrollManager: ScrollManager
    @Published var isEditable: Bool

    let me: FriendColor
    
    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success

    init(
        date: Date, authManager: any AuthManagerProtocol, firestoreManager: FirestoreManager,
        scrollManager: ScrollManager, isEditable: Bool
    ) {
        self.isLoading = true
        self.date = date
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        self.scrollManager = scrollManager
        self.isEditable = isEditable
        self.me = FriendColor(name: "Me", username: "me", color: .gray, note: "Let's roll?")
    }
    
    @MainActor
        func loadInitialData() async {
            self.isLoading = true
            let dateId = DailyMood.dateId(from: date)

            let dailyMood = firestoreManager.pastMoods[dateId]
            
            self.dailyMood = dailyMood
            self.currentMood = dailyMood?.mood
            self.note = dailyMood?.noteContent ?? ""
            self.isMoodSelectionVisible = dailyMood?.mood == nil
            self.expanded = dailyMood?.mood != nil
            
            setup()
            self.isLoading = false
        }

    func setup() {
        if dailyMood != nil {
            self.isDayVerticalScrollDisabled = false
        } else {
            self.isDayVerticalScrollDisabled = true
        }
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
                    if let mood = try await firestoreManager.getDailyMoodForViewerLocalDate(
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
            
            if results.isEmpty {
                self.showToast = false
                self.toastMessage = "None of your friends have posted a mood yet."
                self.toastStyle = .info
                self.showToast = true
            }

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
    
    func resetSelections() {
        selectedFriend = nil
    }

    // PERSONAL VIEW METHODS
    @MainActor
    func saveEntry(isButtonSubmit: Bool) async {
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
        do {
            try await firestoreManager.saveDailyMood(
                date: date,
                mood: currentMood ?? MoodColor.none,
                content: newNote.isEmpty ? nil : newNote,
                forUserID: userId
            )
            print("Daily entry saved successfully")
            if isButtonSubmit {
                self.showToast = false
                self.toastMessage = "Your entry has been saved successfully."
                self.toastStyle = .success
                self.showToast = true
            }
        } catch {
            print("Error saving daily entry: \(error.localizedDescription)")
        }
        isMoodSelectionVisible = false
        expanded = false
        self.isDayVerticalScrollDisabled = false
    }

    @MainActor
    func deleteEntry() async {
        guard let userId = authManager.currentUser?.uid else {
            print("Error: User not logged in. Cannot delete note.")
            return
        }
        do {
            try await firestoreManager.deleteDailyMood(date: date, forUserID: userId)
            print("Daily entry for \(date) deleted successfully")
//            self.showToast = false
//            self.toastMessage = "Daily entry deleted."
//            self.toastStyle = .warning
//            self.showToast = true
        } catch {
            print(
                "Error deleting daily entry: \(error.localizedDescription)"
            )
        }
        isMoodSelectionVisible = true
        currentMood = nil
        expanded = false
        isVisible = true
        self.isDayVerticalScrollDisabled = true
    }

    @MainActor
    func toggleFriends() {
        if showFriends {
            self.isDayVerticalScrollDisabled = false
            scrollManager.isHorizontalScrollDisabled = false
            showFriends = false
        } else {
            self.isDayVerticalScrollDisabled = true
            scrollManager.isHorizontalScrollDisabled = true
            showFriends = true
        }
    }

}
