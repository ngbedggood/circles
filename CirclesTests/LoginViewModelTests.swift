//
//  LoginViewModelTests.swift
//  CirclesTests
//
//  Created by Nathaniel Bedggood on 10/07/2025.
//

import Foundation
import XCTest
@testable import Circles

final class LoginViewModelTests: XCTestCase {
    
    var mockAuthManager: MockAuthManager!
    var viewModel: LoginViewModel!
    
    // These run everytime between tests to ensure they run in a "white room", saves calling these for each method too.
    override func setUp() {
        super.setUp()
        mockAuthManager = MockAuthManager()
        viewModel = LoginViewModel(authManager: mockAuthManager)
    }
    
    override func tearDown() {
        mockAuthManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testLoginSuccess() async {
        mockAuthManager.loginShouldSucceed = true
        
        viewModel.email = "test@example.com"
        viewModel.password = "test1234"
        
        await viewModel.login()
 
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(mockAuthManager.isAuthenticated)
        XCTAssertEqual(mockAuthManager.currentUser?.email, "test@example.com")
        
    }
    
    func testLoginFailureEmailNotRegistered() async {
        mockAuthManager.loginShouldSucceed = false
        mockAuthManager.mockError = NSError(domain: "Auth", code: 404, userInfo: [
            NSLocalizedDescriptionKey: "No account found for that email address."
        ])
        
        viewModel.email = "example@example.com"
        viewModel.password = "test1234"
        
        await viewModel.login()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(mockAuthManager.isAuthenticated)
        XCTAssertNil(mockAuthManager.currentUser)
    }
    
    func testLoginFailureWrongPassword() async {
        mockAuthManager.loginShouldSucceed = false
        mockAuthManager.mockError = NSError(domain: "Auth", code: 401, userInfo: [
            NSLocalizedDescriptionKey: "Invalid credentials"
        ])
        
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        
        await viewModel.login()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(mockAuthManager.isAuthenticated)
        XCTAssertNil(mockAuthManager.currentUser)
    }
    
    func testLoginEmptyFields() async {
        
        viewModel.email = ""
        viewModel.password = ""
        
        await viewModel.login()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage!, "Fields cannot be empty.")
    }
    
    func testSignUpSuccess() async {
        mockAuthManager.loginShouldSucceed = true
        
        viewModel.email = "test@example.com"
        viewModel.password = "test1234"
        viewModel.username = "testuser"
        viewModel.displayName = "Test User"
        
        await viewModel.signUp()
 
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(mockAuthManager.isAuthenticated)
        XCTAssertEqual(mockAuthManager.currentUser?.email, "test@example.com")
        
    }
    
    func testSignUpFailureUsernameTaken() async {
        mockAuthManager.loginShouldSucceed = false
        mockAuthManager.mockError = NSError(domain: "Auth", code: 409, userInfo: [
            NSLocalizedDescriptionKey: "Username tessa is already taken."
        ])
        
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        viewModel.username = "tessa"
        viewModel.displayName = "Test User"
        
        await viewModel.signUp()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(mockAuthManager.isAuthenticated)
        XCTAssertNil(mockAuthManager.currentUser)
    }
    
    func testSignupEmptyFields() async {
        
        viewModel.email = ""
        viewModel.password = ""
        viewModel.username = ""
        viewModel.displayName = ""
        
        await viewModel.signUp()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage!, "Fields cannot be empty.")
    }
}
