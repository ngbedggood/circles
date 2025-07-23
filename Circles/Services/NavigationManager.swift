//
//  NavigationManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/07/2025.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var currentView: ViewType = .dayPage
    
    enum ViewType {
        case dayPage
        case friends
    }
}
