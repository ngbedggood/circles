//
//  DailyMood.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 25/06/2025.
//

//  The purpose of this blueprint is to allow Firestore to convert a document into a DailyMood struct to be used within the app. But also the conversion of a daily note to be store in Firestore.

import FirebaseFirestore
import Foundation
import SwiftUI

enum MoodColor: String, Codable, CaseIterable, Identifiable {
    case teal = "Teal"
    case green = "Green"
    case yellow = "Yellow"
    case orange = "Orange"
    case gray = "Gray"
    case none = "No Color"

    var id: String { self.rawValue }

    var color: Color {
        switch self {
            case .teal: return .teal
            case .green: return .green
            case .yellow: return .yellow
            case .orange: return .orange
            case .gray: return .gray
            case .none: return .brown.opacity(0.5)
        }
    }
}

struct DailyMood: Codable, Identifiable, Equatable {

    @DocumentID var id: String?
    var mood: MoodColor?
    var noteContent: String?
    var createdAt: Date
    var updatedAt: Date

    init(id: String?, mood: MoodColor, noteContent: String, createdAt: Date, updatedAt: Date? = nil)
    {
        self.id = id
        self.mood = mood
        self.noteContent = noteContent
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt  // Set as as creation time if not available
    }

    // ID date to swift date
    var date: Date? {
        guard let id = id else { return nil }  // Only proceed if id exists
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current  // Keep consistent timezone
        return formatter.date(from: id)
    }

    // swift date back to ID date (YYYY-MM-DD)
    // will be used for Firestore document IDs
    static func dateId(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

}

struct FriendWithMood {
    var id: String
    var name: String
    var color: Color
    var note: String
}
