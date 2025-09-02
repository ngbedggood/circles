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
            
            var fieldsToUpdate: [String: Any] = [:]
            var finalStreak = currentStreak

            if isNewEntry {
                // New entry checking and updating
                let newStreak = calculateNewStreak(
                    currentStreak: currentStreak,
                    lastEntry: lastEntryDate,
                    today: Date()
                )
                fieldsToUpdate["streakCount"] = newStreak
                fieldsToUpdate["lastEntry"] = Timestamp(date: Date())
                finalStreak = newStreak
            } else {
                // Checking
                let calendar = Calendar.current
                let today = Date()
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

                if let lastEntry = lastEntryDate {
                    if !calendar.isDate(lastEntry, inSameDayAs: today) && !calendar.isDate(lastEntry, inSameDayAs: yesterday) {
                        if currentStreak > 0 {
                            fieldsToUpdate["streakCount"] = 0
                            showStreakLostToast = true
                        }
                        finalStreak = 0
                    }
                }
            }
            
            // Update Firestore if there are changes
            if !fieldsToUpdate.isEmpty {
                try await firestoreManager.updateUserData(userId: userId, fields: fieldsToUpdate)
            }
            
            self.currentStreakCount = finalStreak

        } catch {
            print("Error managing streak: \(error.localizedDescription)")
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
