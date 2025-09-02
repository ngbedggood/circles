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
                    ? Color(.clear)
                        : viewModel.currentMood?.color
                            ?? Color(.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            viewModel.currentMood == nil ? Color.gray :
                            Color.clear,
                            style: StrokeStyle(lineWidth: 2, dash: [4, 6])
                            // [dash length, gap length]
                        )
                )
                .zIndex(-1)
                .animation(.easeInOut.delay(0.1), value: viewModel.currentMood)
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
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(viewModel.currentMood?.color ?? .clear)
//                        .brightness(-0.1)
//                        .padding(24)
//                        .offset(y: 2)
//                        .animation(.easeInOut.delay(0.2), value: viewModel.currentMood)
//                )
    }
}

#Preview {
    BackgroundCardView(
        viewModel: DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
            firestoreManager: FirestoreManager(),
            streakManager: StreakManager(
                authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
                firestoreManager: FirestoreManager()),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        ),
        isFocused: true
    )
}
