//
//  StreakManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 28/08/2025.
//

import Foundation
import FirebaseCore

class StreakManager: ObservableObject {
    
    @Published var currentStreakCount: Int = 0
    @Published var showStreakLostToast: Bool = false
    
    private let authManager: any AuthManagerProtocol
    private let firestoreManager: FirestoreManager
    
    init(authManager: any AuthManagerProtocol, firestoreManager: FirestoreManager) {
        self.authManager = authManager
        self.firestoreManager = firestoreManager
    }
    
    // Set isNewEntry to true when making an entry otherwise set false for checking
    @MainActor
    func manageStreak(isNewEntry: Bool) async {
        guard let userId = authManager.currentUser?.uid else { return }

        do {
            // Fetch
            let data = try await firestoreManager.fetchUserData(userId: userId)
            let currentStreak = data["streakCount"] as? Int ?? 0
            let lastEntryDate = (data["lastEntry"] as? Timestamp)?.dateValue()

            // Check if is new streak
            let newStreak = calculateNewStreak(
                currentStreak: currentStreak,
                lastEntry: lastEntryDate,
                today: Date() // Pass the current date
            )

            var fieldsToUpdate: [String: Any] = [:]

            // Update stored streak count if the calculated one is off
            if newStreak != currentStreak {
                fieldsToUpdate["streakCount"] = newStreak
                // If the streak was lost, show a message
                if newStreak == 0 && currentStreak > 0 {
                    showStreakLostToast = true
                }
            }

            // Update time stamp for new entries
            if isNewEntry {
                fieldsToUpdate["lastEntry"] = Timestamp(date: Date())
            }
            
            if !fieldsToUpdate.isEmpty {
                try await firestoreManager.updateUserData(userId: userId, fields: fieldsToUpdate)
            }
            
            self.currentStreakCount = newStreak

        } catch {
            print("Error managing streak: \(error.localizedDescription)")
            return
        }
    }
    
    func calculateNewStreak(currentStreak: Int, lastEntry: Date?, today: Date) -> Int {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if let lastEntry = lastEntry {
            if calendar.isDate(lastEntry, inSameDayAs: today) {
                return currentStreak // already logged today
            } else if calendar.isDate(lastEntry, inSameDayAs: yesterday) {
                return currentStreak + 1 // continue streak
            } else {
                return 0 // reset
            }
        } else {
            return 1
        }
    }
    
    
    
}
