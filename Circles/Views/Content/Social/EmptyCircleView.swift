//
//  FriendCircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct EmptyCircleView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject var viewModel: ReactionViewModel

    let friend: FriendColor
    let index: Int
    let center: CGPoint
    let radius: CGFloat
    let date: Date
    let totalSpots: Int
    @Binding var selectedFriend: FriendColor?
    let isEditable: Bool

    @State private var hasAppeared = false

    private var isSelected: Bool { selectedFriend?.id == friend.id }

    init(friend: FriendColor,
         index: Int,
         center: CGPoint,
         radius: CGFloat,
         date: Date,
         totalSpots: Int,
         selectedFriend: Binding<FriendColor?>,
         firestoreManager: FirestoreManager,
         isEditable: Bool) {
        self.friend = friend
        self.index = index
        self.center = center
        self.radius = radius
        self.date = date
        self.totalSpots = totalSpots
        self._selectedFriend = selectedFriend
        self.isEditable = isEditable
        _viewModel = StateObject(wrappedValue: ReactionViewModel(
            firestoreManager: firestoreManager
        ))
    }

    var body: some View {
        let position = CirclePositionCalculator.position(
            for: index,
            totalSpots: totalSpots,
            center: center,
            radius: radius,
            isSelected: isSelected,
            someoneSelected: selectedFriend != nil
        )
        let scale = CirclePositionCalculator.scale(
            for: totalSpots,
            isSelected: isSelected,
            someoneSelected: selectedFriend != nil
        )
        
        let hasReacted = UserDefaults.standard.bool(forKey: "hasReacted")
        let timeAgo = viewModel.timeAgo(from: friend.time)

        ZStack {
            Circle()
                .fill(Color.clear)
                .strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [4, 6]))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(friend.name)
                        .lineLimit(7)
                        .font(.satoshi(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(2 / 20)
                        .foregroundColor(.gray)
                        .padding(8)
                )
                .scaleEffect(scale)
        }
        .position(position)
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0)
        .onAppear {
            hasAppeared = true
            Task {
                await viewModel.listenForReactions(
                    username: friend.username,
                    date: date
                )
            }
        }
        .onDisappear { viewModel.stopListening() }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}
