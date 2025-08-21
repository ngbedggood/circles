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
    let color: Color
    let note: String?
    let date: Date
    let username: String
    
    @Binding var selectedFriend: FriendColor?
    
    init(
        firestoreManager: FirestoreManager,
        isMeSelected: Bool,
        someoneElseSelected: Bool,
        me: FriendColor,
        color: Color,
        note: String?,
        date: Date,
        username: String,
        selectedFriend: Binding<FriendColor?>
    ){
        self.isMeSelected = isMeSelected
        self.someoneElseSelected = someoneElseSelected
        self.me = me
        self.color = color
        self.note = note
        self.date = date
        self.username = username
        self._selectedFriend = selectedFriend
        _viewModel = StateObject(wrappedValue: ReactionViewModel(firestoreManager: firestoreManager))
    }
    
    var body: some View {
        let meScale: CGFloat =
            isMeSelected ? 3.0 : (someoneElseSelected ? 0.01 : 1.2)
        ZStack {
            CircleView(
                color: color,
                text: isMeSelected ?
                    (note?.isEmpty == true ?
                        "\"No note\"" : note ?? "\"No note\""
                    )
                : "Me",
                font: isMeSelected ?
                    .satoshi(size: 18, weight: .regular) :
                        .satoshi(size: 32, weight: .bold),
                size: 80 * meScale,
                isSelected: isMeSelected
            )
                .zIndex(someoneElseSelected ? -1 : isMeSelected ? 1 : 0)
                .opacity(someoneElseSelected ? 0 : 1)
                .onTapGesture {
                    withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                        if isMeSelected {
                            selectedFriend = nil
                            //viewModel.setSelected(false)
                        } else {
                            selectedFriend = me
                            //viewModel.setSelected(true)
                        }
                    }
                }
            if isMeSelected {
                CircleReactionsView(reactions: viewModel.reactions)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(6)
            }
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
