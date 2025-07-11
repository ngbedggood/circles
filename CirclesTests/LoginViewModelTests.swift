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
    
    func testLoginSuccess() async {
        let mockAuthManager = MockAuthManager()
        mockAuthManager.loginShouldSucceed = true
        let viewModel = LoginViewModel(authManager: mockAuthManager)
        
        viewModel.email = "test@example.com"
        viewModel.password = "test1234"
        
        try await viewModel.login()
 
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(mockAuthManager.isAuthenticated)
        XCTAssertEqual(mockAuthManager.currentUser?.email, "test@example.com")
        
    }
    
    func testLoginFailure() async {
        let mockAuthManager = MockAuthManager()
        mockAuthManager.loginShouldSucceed = false
        let viewModel = LoginViewModel(authManager: mockAuthManager)
        
        viewModel.email = "test@example.com"
        viewModel.password = "test1234"
        
        try await viewModel.login()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(mockAuthManager.isAuthenticated)
        XCTAssertNil(mockAuthManager.currentUser)
    }
    
    func testLoginEmptyFields() async {
        let mockAuthManager = MockAuthManager()
        let viewModel = LoginViewModel(authManager: mockAuthManager)
        
        viewModel.email = ""
        viewModel.password = ""
        
        await viewModel.login()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage!, "Fields cannot be empty")
    }
    
}
