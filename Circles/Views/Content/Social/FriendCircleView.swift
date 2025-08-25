//
//  FriendCircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct CirclePositionCalculator {
    static func position(for index: Int, totalSpots: Int, center: CGPoint, radius: CGFloat, isSelected: Bool, someoneSelected: Bool) -> CGPoint {
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)
        return CGPoint(
            x: center.x + effectiveRadius * CGFloat(sin(angle.radians)),
            y: center.y - effectiveRadius * CGFloat(cos(angle.radians))
        )
    }

    static func scale(for totalSpots: Int, isSelected: Bool, someoneSelected: Bool) -> CGFloat {
        let baseScale = max(0.9, 1.0 - CGFloat(totalSpots - 1) * 0.05)
        return isSelected ? 3.0 : (someoneSelected ? 0.5 * baseScale : 1.0 * baseScale)
    }
}

struct FriendCircleView: View {
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
            CircleView(
                color: friend.color?.color ?? .gray,
                text: isSelected ? "\"\(friend.note)\"" : friend.name,
                font: isSelected ? .satoshi(size: 18, weight: .regular) : .satoshi(size: 32, weight: .bold),
                size: 80 * scale,
                padding: isSelected ? 32 : 8,
                isSelected: isSelected,
                hasReacted: hasReacted,
                timeAgo: timeAgo ?? ""
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                    selectedFriend = isSelected ? nil : friend
                    viewModel.toggleSelection()
                }
            }
            .onLongPressGesture {
                if isSelected {
                    if isEditable {
                        withAnimation { viewModel.showEmotePicker.toggle() }
                    } else {
                        viewModel.showLockedToast()
                    }
                }
            }
            .zIndex(2)

            if isSelected {
                ReactionsOverlayView(viewModel: viewModel, friend: friend, date: date)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(3)
                    .onAppear {
                        viewModel.getCurrentUserEmote()
                    }
            }
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
