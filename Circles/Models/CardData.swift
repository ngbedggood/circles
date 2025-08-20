//
//  PersonalCard.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import Foundation
import SwiftUI

enum CardColor {
    case gray, yellow, orange, green, teal, none

    var swiftUIColor: Color {
        switch self {
            case .gray: return .gray
            case .yellow: return .yellow
            case .orange: return .orange
            case .green: return .green
            case .teal: return .teal
            case .none: return .gray
        }
    }
}

struct PersonalCard: Identifiable {
    let id = UUID()
    var date: String
    var color: MoodColor?
    var note: String
}

struct FriendColor: Identifiable, Equatable{
    let id = UUID()
    var uid: String
    var name: String
    var username: String
    var color: MoodColor?
    var note: String
}

struct SocialCard: Identifiable {
    let id = UUID()
    var date: String
    var friends: [FriendColor]
}
