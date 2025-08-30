//
//  ReactionsOverlayView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 20/08/2025.
//

import SwiftUI

struct ReactionsOverlayView: View {
    @ObservedObject var viewModel: ReactionViewModel
    let friend: FriendColor
    let date: Date
    
    var body: some View {
        ZStack {
            CircleReactionsView(
                reactions: viewModel.reactions,
                color: friend.color?.color ?? .white
            )
            
            EmoteSelectionView(
                showEmotePicker: viewModel.showEmotePicker,
                selectedEmote: $viewModel.currentUserEmote
            ) { emote in
                Task {
                    withAnimation {
                        viewModel.currentUserEmote = emote
                    }
                    await viewModel.reactToFriendMood(friend: friend, date: date)
                }
            }
            .foregroundColor(.fakeBlack)
            .opacity(viewModel.showEmotePicker ? 1 : 0)
            .offset(y: viewModel.showEmotePicker ? 210 : 60)
        }
    }
}
