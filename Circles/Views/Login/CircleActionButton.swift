//
//  CircleActionButton.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct CircleActionButton: View {
    var title: String
    var isLoading: Bool
    var action: () -> Void
    var body: some View {
        Button(
            action: {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil)
                action()
            }
        ) {
            Circle()
                .fill(.teal)
                .frame(width: 80, height: 80)
                .overlay(
                    Group {
                        if isLoading {
                            Text("Loading")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Text(title)
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                )
                .shadow(color: .black.opacity(0.2), radius: 4)
        }
    }
}

#Preview {
    CircleActionButton(title: "title", isLoading: false, action: {})
}
