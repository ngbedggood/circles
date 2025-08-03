//
//  UserProfile.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 28/06/2025.
//

import FirebaseFirestore
import Foundation

struct FriendRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var from: String
    var to: String
    var status: String
}

struct UserProfile: Identifiable, Codable, Equatable {
    @DocumentID var uid: String?  // Automatically uses document ID
    var id: String { uid ?? UUID().uuidString }
    var username: String
    var displayName: String
}

struct RequestWithUser: Identifiable {
    var id: String { request.id ?? UUID().uuidString }
    let request: FriendRequest
    let user: UserProfile
}

struct SearchResultUser: Identifiable {
    var id: String { user.uid ?? UUID().uuidString }
    let user: UserProfile
    var requestSent: Bool
}
