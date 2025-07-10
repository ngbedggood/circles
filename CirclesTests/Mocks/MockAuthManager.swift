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
        if let error = mockError {
            self.errorMsg = error.localizedDescription
            throw error
        }
        
        if loginShouldSucceed {
            self.isAuthenticated = true
            self.currentUser = MockUser(uid: "mock-uid", email: "mock@mock.com") // Create a mock user object
            self.errorMsg = nil
        } else {
            self.errorMsg = "Login failed"
        }
    }
    
    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        if let error = mockError {
            self.errorMsg = error.localizedDescription
            throw error
        }
        
        if signUpShouldSucceed {
            self.isAuthenticated = true
            self.currentUser = MockUser(uid: "mock-uid", email: "mock@mock.com")
            self.errorMsg = nil
        } else {
            self.errorMsg = "Signup failed"
        }
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
