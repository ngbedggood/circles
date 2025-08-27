//
//  DayPageViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import Combine
import Foundation
import SwiftUI

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
    
    
    @Published var selectedEmote: String? = nil

    // Shared stuff
    @Published private(set) var dailyMood: DailyMood?
    @Published var isDayVerticalScrollDisabled: Bool = false

    let date: Date
    
    let authManager: any AuthManagerProtocol
    let firestoreManager: FirestoreManager
    let notificationManager: NotificationManager
    private var scrollManager: ScrollManager
    
    @Published var isEditable: Bool
    @Published var hasAlert: Bool = false

    let me: FriendColor
    
    // Toast related
    @Published var showToast: Bool = false
    @Published private(set) var toastMessage: String = ""
    @Published private(set) var toastStyle: ToastStyle = .success
    
    // Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    init(
        date: Date,
        authManager: any AuthManagerProtocol,
        firestoreManager: FirestoreManager,
        notificationManager: NotificationManager,
        scrollManager: ScrollManager,
        isEditable: Bool
    ) {
        self.isLoading = true
        self.date = date
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        self.notificationManager = notificationManager
        self.scrollManager = scrollManager
        self.isEditable = isEditable
        self.me = FriendColor(uid: "", name: "Me", username: "me", color: .gray, note: "Let's roll?", time: Date())

        setupPastMoodsObserver()
        
        
    }
    
    //@MainActor
    func setupPastMoodsObserver() {
        firestoreManager.$pastMoods
            .dropFirst() // Skip the initial empty state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pastMoods in
                self?.updateDataFromPastMoods(pastMoods)
                
                if let self = self, Calendar.current.isDateInToday(self.date) {
                   
                   let todayDateId = DailyMood.dateId(from: Date())
                   let hasTodayMood = pastMoods[todayDateId] != nil
                    
                   notificationManager.syncNotificationStateWithMoodData(hasTodayMood: hasTodayMood)
               }
            }
            .store(in: &cancellables)
    }
    
    private func updateDataFromPastMoods(_ pastMoods: [String: DailyMood]) {
        let dateId = DailyMood.dateId(from: date)
        let dailyMood = pastMoods[dateId]
        
        self.dailyMood = dailyMood
        self.currentMood = dailyMood?.mood
        self.note = dailyMood?.noteContent ?? ""
        self.isMoodSelectionVisible = dailyMood?.mood == nil
        self.expanded = dailyMood?.mood != nil
        
        setup()
        self.isLoading = false
        
        //print("Updated view model for date \(dateId) with mood: \(dailyMood?.mood?.rawValue ?? "none")")
    }
    
    @MainActor
    func checkForAlerts() async {
        guard let userID = authManager.currentUser?.uid else { return }
        do {
            let requests = try await firestoreManager.fetchPendingFriendRequests(for: userID)
            self.hasAlert = !requests.isEmpty
        } catch {
            print(error.localizedDescription)
        }
            
    }
    
    @MainActor
        func loadInitialData() async {
            self.isLoading = true
            if !firestoreManager.pastMoods.isEmpty {
                updateDataFromPastMoods(firestoreManager.pastMoods)
            } else {
                print("Past moods not yet loaded, waiting for Combine observer...")
            }
            
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
                        //print(reacts)
                        let friend = FriendColor(
                            uid: uid,
                            name: profile.displayName,
                            username: profile.username,
                            color: mood.mood,
                            note: mood.noteContent == "" ? "No note" : mood.noteContent ?? "No note",
                            time: mood.createdAt > mood.updatedAt ? mood.createdAt : mood.updatedAt
                            //reacts: reacts
                        )
                        results.append(friend)
                    } else {
                        let profile = try await firestoreManager.fetchUserProfile(userID: uid)
                        //print(reacts)
                        let friend = FriendColor(
                            uid: uid,
                            name: profile.displayName,
                            username: profile.username,
                            color: nil,
                            note: "",
                            time: Date()
                            //reacts: reacts
                        )
                        results.append(friend)
                    }
                } catch {
                    //print("Failed to process friend \(uid): \(error.localizedDescription)")
                }
            }
            
            if results.isEmpty {
                self.showToast = false
                self.toastMessage = "None of your friends have posted a mood this day."
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
            
            // Cancel today's notification reminder when a mood entry is made
            if Calendar.current.isDateInToday(date) {
                print("About to cancel reminder notification?")
                notificationManager.syncNotificationStateWithMoodData(hasTodayMood: true)
                print("About to debug after cancelling reminder.")
                notificationManager.debugPrintPendingNotifications()
            }
            
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
            
            // Immediately schedule a today notifcation if necessary
            if Calendar.current.isDateInToday(date) {
                notificationManager.syncNotificationStateWithMoodData(hasTodayMood: false)
            }
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
