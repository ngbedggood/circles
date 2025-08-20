//
//  Reaction.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 18/08/2025.
//

import Foundation
import FirebaseFirestore

struct Reaction: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUID: String
    var reaction: String
    var createdAt: Date
    var updatedAt: Date
}
