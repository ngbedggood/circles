//
//  FriendCircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

// 2. Position Calculator (could be a helper struct)
struct CirclePositionCalculator {
    static func position(for index: Int, totalSpots: Int, center: CGPoint, radius: CGFloat, isSelected: Bool, someoneSelected: Bool) -> CGPoint {
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)
        
        let x = center.x + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
        let y = center.y - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))
        
        return CGPoint(x: x, y: y)
    }
    
    static func scale(for totalSpots: Int, isSelected: Bool, someoneSelected: Bool) -> CGFloat {
        let baseScale = max(0.9, 1.0 - CGFloat(totalSpots - 1) * 0.05)
        return isSelected ? 3.0 : (someoneSelected ? 0.5 * baseScale : 1.0 * baseScale)
    }
}

// 3. Simplified FriendCircleView
struct FriendCircleView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: ReactionViewModel
    
    let friend: FriendColor
    let index: Int
    let center: CGPoint
    let radius: CGFloat
    let date: Date
    let totalSpots: Int
    let isEditable: Bool
    
    
    @State private var hasAppeared: Bool = false
    @Binding var selectedFriend: FriendColor?
    
    private var isSelected: Bool { selectedFriend?.id == friend.id }
    private var someoneSelected: Bool { selectedFriend?.id != nil }
    
    init(friend: FriendColor, index: Int, center: CGPoint, radius: CGFloat, date: Date, totalSpots: Int, selectedFriend: Binding<FriendColor?>, firestoreManager: FirestoreManager, isEditable: Bool) {
        self.friend = friend
        self.index = index
        self.center = center
        self.radius = radius
        self.date = date
        self.totalSpots = totalSpots
        self._selectedFriend = selectedFriend
        _viewModel = StateObject(wrappedValue: ReactionViewModel(firestoreManager: firestoreManager))
        self.isEditable = isEditable
    }
    
    var body: some View {
        let position = CirclePositionCalculator.position(
            for: index,
            totalSpots: totalSpots,
            center: center,
            radius: radius,
            isSelected: isSelected,
            someoneSelected: someoneSelected
        )
        let scale = CirclePositionCalculator.scale(
            for: totalSpots,
            isSelected: isSelected,
            someoneSelected: someoneSelected
        )
        
        ZStack {
            CircleView(
                color: friend.color?.color ?? Color.gray,
                text: isSelected ? "\"\(friend.note)\"" : friend.name,
                font: isSelected ? .satoshi(size: 18, weight: .regular) : .satoshi(size: 20, weight: .bold),
                size: 80 * scale,
                isSelected: isSelected
            )
            .zIndex(1)
            if isSelected {
                ReactionsOverlayView(viewModel: viewModel, friend: friend, date: date)
                    .zIndex(2)
            }
            
            
        }
        .position(position)
        .scaleEffect(hasAppeared ? 1 : 0)
        .opacity(hasAppeared ? 1 : 0)
        .onTapGesture { handleTap() }
        .onLongPressGesture { handleLongPress() }
        .onChange(of: selectedFriend) { _, _ in handleSelectionChange() }
        .onAppear { handleAppear() }
        .onDisappear { handleDisappear() }
    }
    
    // Simple, focused methods
    private func handleTap() {
        withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
            selectedFriend = isSelected ? nil : friend
            viewModel.setSelected(!isSelected)
            if !isSelected { viewModel.showEmotePicker = false }
        }
    }
    
    private func handleLongPress() {
        if isSelected && isEditable {
            withAnimation { viewModel.showEmotePicker = true }
        }
    }
    
    private func handleSelectionChange() {
        viewModel.setSelected(isSelected)
        if !isSelected { viewModel.showEmotePicker = false }
    }
    
    private func handleAppear() {
        Task { await viewModel.listenForReactions(username: friend.username, date: date) }
        withAnimation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1)) {
            hasAppeared = true
        }
    }
    
    private func handleDisappear() {
        viewModel.stopListening()
    }
}
