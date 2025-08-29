//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {

    @EnvironmentObject var firestoreManager: FirestoreManager

    @ObservedObject var viewModel: DayPageViewModel

    @State private var showFriendCircles: Bool = false
    @State private var showPersonalCircle: Bool = false
    

    let radius: CGFloat = 100
    
    var onUp: () -> Void

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let baseWidth: CGFloat = 650
                let screenScale = min(1, screenHeight / baseWidth)
                
                VStack {
                    Button {
                        onUp()
                    } label: {
                        Text("Friends Circles")
                            .font(.satoshi(.title, weight: 700))
                            .foregroundColor(.black.opacity(0.75))
                            .padding()
                    }
//                    Image(systemName: "arrowshape.up.fill")
//                        .foregroundStyle(.gray)
//                        .padding()
                
                    
                    GeometryReader { geometry in
                        friendCircles(
                            in: geometry,
                            screenScale: screenScale
                        )
                    }

                    Text("Reacting to friends moods for past days is locked.")
                        .font(.satoshi(.caption))
                        .foregroundColor(.gray)
                        .opacity(!viewModel.isEditable ? 1 : 0)
                    
                    Text(viewModel.formattedDate())
                        .font(.satoshi(.title, weight: .bold))
                        .zIndex(1)
                        .foregroundColor(.black.opacity(0.75))
                        .padding()
                }
            }
            .onScrollVisibilityChange { isVisible in
                if isVisible {
                    Task {
                        withAnimation {
                            viewModel.clearSelection()
                            showPersonalCircle = true
                        }
                        await viewModel.retrieveFriendsWithMoods()
                        
                        // Trigger friend circles animation after data loads
                        showFriendCircles = true
                    }
                } else {
                    showFriendCircles = false
                    showPersonalCircle = false
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20).fill(.backgroundTint)
                    .onTapGesture {
                        withAnimation(
                            .spring(
                                response: 0.49,
                                dampingFraction: 0.69,
                                blendDuration: 0
                            )
                        ) {
                            withAnimation {
                                viewModel.clearSelection()
                            }
                        }
                    }
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color.black.opacity(0.75),
                        style: StrokeStyle(lineWidth: 2)
                    )
            )
            .padding(24)
        }
    }

    private func friendCircles(in geometry: GeometryProxy, screenScale: CGFloat) -> some View {
        ZStack {
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let postedTime = viewModel.dailyMood?.updatedAt ?? viewModel.dailyMood?.createdAt ?? Date()
//            if showPersonalCircle {
//                ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) {
//                    index, friend in
//                    EmptyCircleView(
//                        friend: friend,
//                        index: index,
//                        center: center,
//                        radius: radius,
//                        date: viewModel.date,
//                        totalSpots: viewModel.socialCard.friends.count,
//                        selectedFriend: $viewModel.selectedFriend,
//                        firestoreManager: firestoreManager,
//                        isEditable: viewModel.isEditable
//                    )
//                    .transition(.scale.animation(.spring()))
//                    .zIndex(viewModel.isMeSelected ? 1 : 3)
//                    .zIndex(viewModel.selectedFriend == friend ? 2 : 1)
//                }
//                .scaleEffect(screenScale)
//            }
            if showFriendCircles {
                ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) {
                    index, friend in
                    FriendCircleView(
                        friend: friend,
                        index: index,
                        center: center,
                        radius: radius,
                        date: viewModel.date,
                        totalSpots: viewModel.socialCard.friends.count,
                        selectedFriend: $viewModel.selectedFriend,
                        firestoreManager: firestoreManager,
                        isEditable: viewModel.isEditable
                    )
                    .transition(.scale.animation(.spring()))
                    .zIndex(viewModel.isMeSelected ? 1 : 3)
                    .zIndex(viewModel.selectedFriend == friend ? 2 : 1)
                }
                .scaleEffect(screenScale)
            }
            
            if showPersonalCircle {
                PersonalCircleView(
                    firestoreManager: firestoreManager,
                    isMeSelected: viewModel.isMeSelected,
                    someoneElseSelected: viewModel.someoneElseSelected,
                    me: viewModel.me,
                    color: viewModel.dailyMood?.mood?.color ?? .brown,
                    note: viewModel.dailyMood?.noteContent ?? "No note.",
                    date: viewModel.date,
                    username: UserDefaults.standard.string(forKey: "Username") ?? "",
                    selectedFriend: $viewModel.selectedFriend,
                    postedTime: postedTime,
                    streakCount: viewModel.streakManager.currentStreakCount
                )
                .position(x: center.x, y: center.y)
                .transition(.scale)
                .zIndex(viewModel.isMeSelected ? 4 : 2)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State static var previewMood: DailyMood? = DailyMood(
            id: "2025-07-01",
            mood: .green,
            noteContent: "Feeling good!",
            createdAt: Date()
        )

        var viewModel: DayPageViewModel = DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()),
            firestoreManager: FirestoreManager(),
            streakManager: StreakManager(
                authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
                firestoreManager: FirestoreManager()),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        )

        var body: some View {
            SocialCardView(
                viewModel: viewModel,
                onUp: {}
            )
        }
    }

    return PreviewWrapper()
}
