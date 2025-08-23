//
//  TopBarView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 07/08/2025.
//

import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var viewModel: DayPageViewModel
    @FocusState.Binding var isFocused: Bool
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    navigationManager.currentView = .friends
                }
            } label: {
                if viewModel.isEditable {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 32))
                }

            }
            .frame(minWidth: 48)
            .accessibilityIdentifier("showFriendsToggleButtonIdentifier")
            Spacer()
            Text(viewModel.formattedDate())
                .font(.satoshi(.title, weight: .bold))
            Spacer()
            Button {
                isFocused = false
                Task {
                    await viewModel.deleteEntry()
                }
            } label: {
                if viewModel.isEditable {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 32))
                        .opacity(viewModel.currentMood == nil ? 0 : 1)
                        .foregroundColor(.white)
                }
            }
            .frame(minWidth: 48)
        }
        .zIndex(5)
        .foregroundColor(
            viewModel.showFriends
                ? .black.opacity(0.75)
                : viewModel.currentMood == nil ? .black.opacity(0.75) : .white
        )
        .animation(.easeInOut.delay(0.1), value: viewModel.currentMood)
        .padding()
    }
}

#Preview {
    @Previewable @FocusState var isFocused
    TopBarView(
        viewModel: DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
            firestoreManager: FirestoreManager(),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        ),
        isFocused: $isFocused
    )
}
