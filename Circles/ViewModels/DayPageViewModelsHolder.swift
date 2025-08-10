//
//  DayPageViewModelsHolder.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 10/08/2025.
//

import SwiftUI

class DayPageViewModelsHolder: ObservableObject {
    @Published var models: [DayPageViewModel] = []

    init(pastDays: Int) {}
    
    func initializeModels(
            pastDays: Int,
            authManager: AuthManager,
            firestoreManager: FirestoreManager,
            scrollManager: ScrollManager
        ) {
            guard models.isEmpty else { return } // Only initialize once
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            models = (0..<pastDays).reversed().map { i in
                let date = calendar.date(byAdding: .day, value: -i, to: today)!
                return DayPageViewModel(
                    date: date,
                    authManager: authManager,
                    firestoreManager: firestoreManager,
                    scrollManager: scrollManager,
                    isEditable: Calendar.current.isDateInToday(date)
                )
            }
        }
    
    
}
