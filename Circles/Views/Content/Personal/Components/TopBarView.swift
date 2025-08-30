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
                    ZStack {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 32))
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Text(
                                    "" // keep this for potential labelling in future
                                )
                                .font(.satoshi(size: 8, weight: .bold))
                                .foregroundColor(.white)
                            )
                            .offset(x: -15, y: -15)
                            .opacity(viewModel.hasAlert ? 1 : 0)
                            .animation(.easeInOut, value: viewModel.hasAlert)
                    }
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
                ? .fakeBlack
                : viewModel.currentMood == nil ? .fakeBlack : .white
        )
        .animation(.easeInOut.delay(0.1), value: viewModel.currentMood)
        .padding()
    }
}

