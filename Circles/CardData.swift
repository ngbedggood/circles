//
//  PersonalCard.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import Foundation

enum CardColor {
    case red, yellow, orange, green, blue
}

struct PersonalCard: Identifiable {
    let id = UUID()
    var date: String
    var color: CardColor?  // can be nil
}
