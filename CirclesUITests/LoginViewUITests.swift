//
//  LoginViewUITests.swift
//  CirclesUITests
//
//  Created by Nathaniel Bedggood on 11/07/2025.
//

import XCTest


final class LoginViewUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginFlow() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments.append("UITEST") // MOCK TEST MODE
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let emailTextField = app.textFields["emailTextFieldIdentifier"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        let passwordSecureTextField = app.secureTextFields["passwordFieldIdentifier"]
        if passwordSecureTextField.exists {
            passwordSecureTextField.tap()
            passwordSecureTextField.typeText("test1234")
        } else {
            let passwordTextField = app.textFields["passwordFieldIdentifier"]
            XCTAssertTrue(passwordTextField.exists)
            passwordTextField.tap()
            passwordTextField.typeText("test1234")
            
        }
        
        app.keyboards.buttons["Return"].tap()
        
        let loginButton = app.buttons["loginButtonIdentifier"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let dayPageViewFriendsButton = app.buttons["showFriendsToggleButtonIdentifier"]
        XCTAssertTrue(dayPageViewFriendsButton.waitForExistence(timeout: 5))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
