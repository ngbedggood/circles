//
//  ScrollManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 14/07/2025.
//

import Foundation

class ScrollManager: ObservableObject {
    @Published var isHorizontalScrollDisabled: Bool = false
    @Published var isVerticalScrollDisabled: Bool = false

    func disableHorizontalScroll(state: Bool) {
        isHorizontalScrollDisabled = state
    }

    func disabledVerticalScroll(state: Bool) {
        isVerticalScrollDisabled = state
    }
}
