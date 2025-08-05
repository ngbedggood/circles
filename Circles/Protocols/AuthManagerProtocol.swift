//
//  AuthManagerProtocol.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/07/2025.
//

import Foundation
import FirebaseAuth

protocol AuthManagerProtocol: ObservableObject {
    
    var currentUser: UserProtocol? { get }
    var isAuthenticated: Bool { get set }
    var isAvailable: Bool { get set }
    var errorMsg: String? { get set }
    var pendingSignUpEmail: String? { get set }
    var firestoreManager: any FirestoreManagerProtocol { get }
    var isVerified: Bool { get }
    var isProfileComplete: Bool { get }
    var isInitializing: Bool { get }

    func login(email: String, password: String) async throws
    func signUp(email: String, password: String, username: String, displayName: String) async throws
    func sendVerificationEmail(email: String) async throws
    func signOut()
    func handleIncomingURL(url: URL) async
    
    func createAccount(email: String, password: String) async throws
    
    func finishProfile(username: String, displayName: String) async throws
    func uploadFCMToken(_ token: String) async
}
