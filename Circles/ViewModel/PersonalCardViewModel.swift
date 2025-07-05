//
//  PersonalCardViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Foundation
import SwiftUI

class PersonalCardViewModel: ObservableObject {
    @Published var currentMood: MoodColor?
    @Published var note: String = ""
    @Published var isMoodSelectionVisible: Bool = true
    @Published var expanded: Bool = false
    @Published var isVisible: Bool = true

    @Binding var dailyMood: DailyMood?

    let date: Date
    let initialMood: MoodColor?
    let initialNote: String?

    let authManager: AuthManager
    let firestoreManager: FirestoreManager

    init(
        date: Date, dailyMood: Binding<DailyMood?>, authManager: AuthManager,
        firestoreManager: FirestoreManager
    ) {
        self.date = date
        self._dailyMood = dailyMood
        self.authManager = authManager
        self.firestoreManager = firestoreManager

        let moodEntry = dailyMood.wrappedValue
        self.initialMood = moodEntry?.mood
        self.initialNote = moodEntry?.noteContent
        self.currentMood = moodEntry?.mood
        self.note = moodEntry?.noteContent ?? ""
        self.isMoodSelectionVisible = moodEntry?.mood == nil
        self.expanded = moodEntry?.mood != nil
    }

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

        print("PVM -> The current mood is: \(dailyMood?.mood?.color ?? .none)")
        print("PVM -> The current note is: \(dailyMood?.noteContent ?? .none)")

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

    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }
}
