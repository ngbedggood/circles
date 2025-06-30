//
//  SocialCardViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import Foundation
import SwiftUI

class SocialCardViewModel: ObservableObject {
    @Published var selectedFriend: FriendColor? = nil
    
    let me = FriendColor(name: "Me", color: .gray, note: "Lets roll!")
    
    let date: Date
    let dailyMood: DailyMood?
    let socialCard: SocialCard
    
    let authManager: AuthManager
    let firestoreManager: FirestoreManager

    init(date: Date, dailyMood: DailyMood?, socialCard: SocialCard, authManager: AuthManager, firestoreManager: FirestoreManager) {
        self.date = date
        self.dailyMood = dailyMood
        self.socialCard = socialCard
        self.authManager = authManager
        self.firestoreManager = firestoreManager
    }

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
}
