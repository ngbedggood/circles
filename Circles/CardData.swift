//
//  PersonalCard.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import Foundation
import SwiftUI

enum CardColor {
    case red, yellow, orange, green, blue, none
    
    var swiftUIColor: Color {
            switch self {
            case .red: return .red
            case .yellow: return .yellow
            case .orange: return .orange
            case .green: return .green
            case .blue: return .blue
            case .none: return .gray
            }
        }
}

struct PersonalCard: Identifiable {
    let id = UUID()
    var date: String
    var color: CardColor?  // can be nil
}

struct FriendColor: Identifiable {
    let id = UUID()
    var name: String
    var color: CardColor?
}

struct SocialCard: Identifiable {
    let id = UUID()
    var date: String
    var friends: [FriendColor]
}
