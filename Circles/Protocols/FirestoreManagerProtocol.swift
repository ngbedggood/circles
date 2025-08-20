//
//  FirestoreManagerProtocol.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 10/07/2025.
//

import Foundation

protocol FirestoreManagerProtocol: ObservableObject {
    func isUsernameAvailable(_ username: String) async throws -> Bool
    func saveUserProfile(uid: String, username: String, displayName: String) async throws
    func loadUserProfile(for uid: String) async throws
    func fetchUsername(for uid: String) async throws -> String?
    func usernameToUID(username: String) async throws -> String
    func searchUsersWithRequestStatus(byUsername username: String, excludingUserID: String) async throws -> [SearchResultUser]
    func sendFriendRequest(from senderID: String, to receiverID: String) async throws
    func acceptFriendRequest(requestID: String, userID: String, friendID: String) async throws
    func fetchPendingFriendRequests(for userID: String) async throws -> [FriendRequest]
    func fetchUserProfile(userID: String) async throws -> UserProfile
    func fetchFriends(userID: String) async throws -> [String]
    func saveDailyMood(date: Date, mood: MoodColor, content: String?, forUserID userId: String) async throws 
    func getDailyMood(forDate date: Date, forUserId userId: String) async throws  -> DailyMood?
    func getDailyMoodForViewerLocalDate(forDate viewerDate: Date, forUserId userId: String) async throws -> DailyMood?
    func loadDailyMoods(forUserId userId: String)
    func deleteDailyMood(date: Date, forUserID userId: String) async throws
    @MainActor
    func loadPastMoods(forUserId userId: String) async throws
    func uploadFCMToken(uid: String, token: String) async throws
    func detachAllListeners()
    
}
