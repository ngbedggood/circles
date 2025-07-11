//
//  MockAuthManager.swift
//  CirclesTests
//
//  Created by Nathaniel Bedggood on 09/07/2025.
//


import Foundation
import FirebaseAuth
@testable import Circles

extension User: UserProtocol {}

class MockAuthManager: AuthManagerProtocol {
    @Published var currentUser: UserProtocol?
    @Published var isAuthenticated: Bool = false
    @Published var isAvailable: Bool = true
    @Published var errorMsg: String?
    
    var firestoreManager: any FirestoreManagerProtocol = MockFirestoreManger()
    
    var loginShouldSucceed: Bool = true
    var signUpShouldSucceed: Bool = true
    var mockError: Error?
    
    func login(email: String, password: String) async throws {
        if loginShouldSucceed {
            isAuthenticated = true
            currentUser = MockUser(uid: "test-uid", email: "test@example.com")
            errorMsg = nil
            print("Login success: \(loginShouldSucceed), isAuthenticated: \(isAuthenticated)")
        } else {
            isAuthenticated = false
            currentUser = nil
            errorMsg = "Login failed"
            throw NSError(domain: "Auth", code: 401, userInfo: nil)
        }
    }
    
    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        if let error = mockError {
            self.errorMsg = error.localizedDescription
            throw error
        }
        
        if signUpShouldSucceed {
            self.isAuthenticated = true
            self.currentUser = MockUser(uid: "test-uid", email: "test@example.com")
            self.errorMsg = nil
        } else {
            self.errorMsg = "Signup failed"
        }
        print("Error is: \(self.errorMsg ?? "")")
    }
    
    func signOut() {
        self.isAuthenticated = false
        self.currentUser = nil
        self.errorMsg = nil
    }
    
}

struct MockUser: UserProtocol {
    let uid: String
    let email: String?
}
