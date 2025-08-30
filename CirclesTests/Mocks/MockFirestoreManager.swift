//
//  MockFirestoreManager.swift
//  CirclesTests
//
//  Created by Nathaniel Bedggood on 10/07/2025.
//

import Foundation
@testable import Circles

class MockFirestoreManager: FirestoreManagerProtocol {
    func saveUserTimezone(for uid: String) async throws {}
    func fetchUsername(for uid: String) async throws -> String? {return ""}
    func usernameToUID(username: String) async throws -> String {return ""}
    func searchUsersWithRequestStatus(byUsername username: String, excludingUserID: String) async throws -> [Circles.SearchResultUser] {return []}
    func getDailyMoodForViewerLocalDate(forDate viewerDate: Date, forUserId userId: String) async throws -> Circles.DailyMood? {return nil}
    func uploadFCMToken(uid: String, token: String) async throws {}
    func isUsernameAvailable(_ username: String) async throws -> Bool {return true}
    func saveUserProfile(uid: String, username: String, displayName: String) async throws {}
    func loadUserProfile(for uid: String) {}
    func searchUsers(byUsername username: String, excludingUserID: String) async throws -> [UserProfile] {return []}
    func sendFriendRequest(from senderID: String, to receiverID: String) async throws {}
    func acceptFriendRequest(requestID: String, userID: String, friendID: String) async throws {}
    func fetchPendingFriendRequests(for userID: String) async throws -> [FriendRequest] {return []}
    func fetchUserProfile(userID: String) async throws -> UserProfile {return UserProfile(uid: "mockuid", username: "mockusername", displayName: "Mock User")}
    func fetchFriends(userID: String) async throws -> [String] {return []}
    func saveDailyMood(date: Date, mood: MoodColor, content: String?, forUserID userId: String) async throws {}
    func getDailyMood(forDate date: Date, forUserId userId: String) async throws  -> DailyMood? {return nil}
    func loadDailyMoods(forUserId userId: String) {}
    func deleteDailyMood(date: Date, forUserID userId: String) async throws {}
    func loadPastMoods(forUserId userId: String) {}
    func detachAllListeners() {}
}
