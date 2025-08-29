//
//  DayPageViewModelsHolder.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 10/08/2025.
//

import SwiftUI

class DayPageViewModelsHolder: ObservableObject {
    @Published var models: [DayPageViewModel] = []
    private var isInitializing = false

    init(pastDays: Int) {}
    
    func initializeModels(
            pastDays: Int,
            authManager: AuthManager,
            firestoreManager: FirestoreManager,
            streakManager: StreakManager,
            notificationManager: NotificationManager,
            scrollManager: ScrollManager
        ) {
            guard !isInitializing else { return }
            guard models.isEmpty else { return } // Only initialize once
            
            isInitializing = true
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            let newModels = (0..<pastDays).reversed().map { i in
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                return DayPageViewModel(
                    date: date,
                    authManager: authManager,
                    firestoreManager: firestoreManager,
                    streakManager: streakManager,
                    notificationManager: notificationManager,
                    scrollManager: scrollManager,
                    isEditable: Calendar.current.isDateInToday(date)
                )
            }
            
            Task { @MainActor in
                self.models = newModels
                self.isInitializing = false
            }
        }
    
    func purgeModels() {
        models.removeAll()
        isInitializing = false
        print("View models have been purged.")
    }
    
    
}
