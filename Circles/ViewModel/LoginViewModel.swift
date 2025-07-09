//
//  LoginViewModel.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/07/2025.
//

import Foundation
//import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var displayName: String = ""
    
    let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        
    }
    
    
    func signUp() {
        authManager.signUp(email: email, password: password, username: username, displayName: displayName)
    }
    
    func login() {
        authManager.login(email: email, password: password)
    }
    
    func errorMsg() -> String? {
        return authManager.errorMsg
    }
    
}
