//
//  FriendCircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct FriendCircleView: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    @StateObject private var viewModel: ReactionViewModel
    
    let friend: FriendColor
    let index: Int
    let center: CGPoint
    let radius: CGFloat
    let scale: CGFloat
    let date: Date
    let totalSpots: Int
    
    @State private var hasAppeared: Bool = false
    
    @Binding var selectedFriend: FriendColor?
    @Binding var showEmotePicker: Bool
    
    init(friend: FriendColor,
         index: Int,
         center: CGPoint,
         radius: CGFloat,
         scale: CGFloat,
         date: Date,
         totalSpots: Int,
         selectedFriend: Binding<FriendColor?>,
         showEmotePicker: Binding<Bool>,
         firestoreManager: FirestoreManager)
    {
        self.friend = friend
        self.index = index
        self.center = center
        self.radius = radius
        self.scale = scale
        self.date = date
        self.totalSpots = totalSpots
        self._selectedFriend = selectedFriend
        self._showEmotePicker = showEmotePicker
        _viewModel = StateObject(wrappedValue: ReactionViewModel(firestoreManager: firestoreManager))
    }
    
    var body: some View {
        //let totalSpots = 8 // maximum number of friends you display
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let isSelected = (selectedFriend?.id == friend.id)
        let someoneSelected = selectedFriend?.id != nil
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)
        
        let x = center.x + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
        let y = center.y - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))
        
        let anotherScale = max(0.9, 1.0 - CGFloat(totalSpots - 1) * 0.05)
        let circleScale: CGFloat = isSelected ? 3.0 : (someoneSelected ? 0.5 * anotherScale : 1.0 * anotherScale)
        
        ZStack {
            Circle()
                .fill(friend.color?.color ?? Color.gray)
                .frame(width: 80 * circleScale, height: 80 * circleScale)
                .shadow(color: .black.opacity(0.3), radius: 4)
                .zIndex(isSelected ? 1 : 0)
                .overlay(
                    ZStack {
                        Text(isSelected ? "\"\(friend.note)\"" : friend.name)
                            .lineLimit(7)
                            .font(
                                isSelected
                                    ? .satoshi(size: 18, weight: .regular)
                                    : .satoshi(size: 20, weight: .bold)
                            )
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(4 / 24)
                            .foregroundColor(.white)
                            .padding(8)
                        
                        // Reactions positioned around top edge
                        CircleReactionsView(reactions: viewModel.reactions, visibleReactions: viewModel.visibleReactions)
                    }
                    .transition(.scale)
                )
                .position(x: x, y: y)
                .scaleEffect(hasAppeared ? 1 : 0)
                .opacity(hasAppeared ? 1 : 0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                        selectedFriend = isSelected ? nil : friend
                        if selectedFriend == nil {
                            withAnimation {
                                showEmotePicker = false
                                viewModel.setSelected(false)
                            }
                        } else {
                            viewModel.setSelected(true)
                        }
                    }
                }
                .onLongPressGesture {
                    if selectedFriend != nil {
                        withAnimation {
                            showEmotePicker = true
                        }
                    }
                }
        }
        .onAppear {
            Task {
                await viewModel.listenForReactions(username: friend.username, date: date)
            }
            withAnimation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1)) {
                hasAppeared = true
            }
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
