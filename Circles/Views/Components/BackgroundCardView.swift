//
//  BackgroundCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 07/08/2025.
//

import SwiftUI

struct BackgroundCardView: View {
    @ObservedObject var viewModel: DayPageViewModel
    var isFocused: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                viewModel.showFriends
                    ? Color(red: 0.92, green: 0.88, blue: 0.84)
                    : viewModel.currentMood?.color
                        ?? Color(red: 0.92, green: 0.88, blue: 0.84)
            )
            .zIndex(-1)
            .animation(.easeInOut.speed(0.8), value: viewModel.currentMood)
            .padding(24)
            .shadow(radius: 8)
            .onTapGesture {
                if isFocused {
                    Task {
                        await viewModel.saveEntry(isButtonSubmit: false)
                    }
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                        for: nil)
                }
            }
    }
}

#Preview {
    BackgroundCardView(
        viewModel: DayPageViewModel(
            date: Date(),
            authManager: AuthManager() as (any AuthManagerProtocol),
            firestoreManager: FirestoreManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        ),
        isFocused: true
    )
}
