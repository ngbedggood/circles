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

    let date: Date
    let initialMood: MoodColor?
    let initialNote: String?

    let authManager: AuthManager

    init(date: Date, dailyMood: DailyMood?, authManager: AuthManager) {
        self.date = date
        self.initialMood = dailyMood?.mood
        self.initialNote = dailyMood?.noteContent
        self.authManager = authManager

        self.currentMood = dailyMood?.mood
        self.note = dailyMood?.noteContent ?? ""
        self.isMoodSelectionVisible = dailyMood?.mood == nil
        self.expanded = dailyMood?.mood != nil
    }

    func saveEntry() {
        guard let userId = authManager.currentUser?.uid else {
            print("Error: User not logged in. Cannot save note.")
            return
        }

        let newNote = note
        Task {
            do {
                try await authManager.fm.saveDailyMood(
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
                    try await authManager.fm.deleteDailyMood(date: date, forUserId: userId)
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
