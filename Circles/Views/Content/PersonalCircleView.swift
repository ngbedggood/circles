//
//  PersonalCircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct PersonalCircleView: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    @StateObject private var viewModel: ReactionViewModel
    
    let isMeSelected: Bool
    let someoneElseSelected: Bool
    let me: FriendColor
    let center: CGPoint
    let color: Color
    let note: String?
    let date: Date
    let username: String
    
    @Binding var selectedFriend: FriendColor?
    @Binding var showEmotePicker: Bool
    
    init(
        firestoreManager: FirestoreManager,
        isMeSelected: Bool,
        someoneElseSelected: Bool,
        me: FriendColor,
        center: CGPoint,
        color: Color,
        note: String?,
        date: Date,
        username: String,
        selectedFriend: Binding<FriendColor?>,
        showEmotePicker: Binding<Bool>
    ){
        self.isMeSelected = isMeSelected
        self.someoneElseSelected = someoneElseSelected
        self.me = me
        self.center = center
        self.color = color
        self.note = note
        self.date = date
        self.username = username
        self._selectedFriend = selectedFriend
        self._showEmotePicker = showEmotePicker
        _viewModel = StateObject(wrappedValue: ReactionViewModel(firestoreManager: firestoreManager))
    }
    
    var body: some View {
        let meScale: CGFloat =
            isMeSelected ? 3.0 : (someoneElseSelected ? 0.1 : 1.2)
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 80 * meScale, height: 80 * meScale)
                .shadow(color: .black.opacity(0.2), radius: 4)
                .zIndex(someoneElseSelected ? -1 : isMeSelected ? 1 : 0)
                .overlay(
                    ZStack {
                        Text(
                            isMeSelected
                            ? (note?.isEmpty == true
                               ? "No note" : note ?? "No note")
                            : "Me"
                        )
                        .lineLimit(7)
                        .font(
                            isMeSelected
                            ? .satoshi(size: 18, weight: .regular) : .satoshi(size: 32, weight: .bold)
                        )
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(2 / 20)
                        .foregroundColor(.white)
                        .padding(32)
                        
                        // Reactions positioned around top edge
                        CircleReactionsView(reactions: viewModel.reactions, visibleReactions: viewModel.visibleReactions)
                    }
                )
                .position(x: center.x, y: center.y)
                .onTapGesture {
                    withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                        if isMeSelected {
                            selectedFriend = nil
                            showEmotePicker = false
                            viewModel.setSelected(false)
                        } else {
                            selectedFriend = me
                            viewModel.setSelected(true)
                        }
                    }
                }
        }
        .onChange(of: selectedFriend) { oldValue, newValue in
            // Update this viewModel's selection state based on the global selection
            let shouldBeSelected = newValue?.id == me.id
            viewModel.setSelected(shouldBeSelected)

        }
        .onAppear {
            Task {
                await viewModel.listenForReactions(username: username, date: date)
            }
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}
