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
    @State private var showEmotePicker: Bool = false
    
    private let reacts = ["🦧", "❤️", "😆", "❤️", "❤️"]

    let radius: CGFloat = 100

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let baseWidth: CGFloat = 650
                let screenScale = min(1, screenHeight / baseWidth)
                
                
                VStack {
                    VStack {
                        Image(systemName: "arrowshape.up.fill")
                            .foregroundStyle(.white)
                    }
                    .padding()

                    ZStack {
                        
                        emotePicker(geometry: geometry)
                            .zIndex(0)
                        
                        GeometryReader { geometry in
                            friendCircles(in: geometry)
                                .scaleEffect(screenScale)
                        }
                    }

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
                        withAnimation(.easeInOut(duration: 0.3).delay(0.2)) {
                            showFriendCircles = true
                        }
                    }
                } else {
                    showFriendCircles = false
                    showPersonalCircle = false
                    showEmotePicker = false
                }
            }
            .onChange(of: viewModel.socialCard.friends) { _, friends in
                // Reset and re-trigger friend circles animation when friends data changes
                showFriendCircles = false
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    showFriendCircles = true
                }
            }
            .onChange(of: viewModel.dailyMood) { _, newValue in
                // Reset friend circles when mood changes
                showFriendCircles = false
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    showFriendCircles = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                    .shadow(radius: 8)
            )
            .onTapGesture {
                withAnimation(
                    .spring(
                        response: 0.55,
                        dampingFraction: 0.69,
                        blendDuration: 0
                    )
                ) {
                    viewModel.clearSelection()
                    showEmotePicker = false
                }
            }
            .padding(24)
        }
    }
    
    private func emotePicker(geometry: GeometryProxy) -> some View {
        EmoteSelectionView(
            showEmotePicker: $showEmotePicker,
            selectedEmote: $viewModel.selectedEmote
        ) { emote in
            viewModel.selectedEmote = emote
            Task { await viewModel.reactToFriendMood() }
        }
        .position(
            x: geometry.size.width / 2,
            y: showEmotePicker ? geometry.size.height / 2 + 100 : geometry.size.height / 2
        )
        .transition(.scale)
    }

    private func friendCircles(in geometry: GeometryProxy) -> some View {
        ZStack {
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            
            if showPersonalCircle {
                PersonalCircleView(
                    firestoreManager: firestoreManager,
                    isMeSelected: viewModel.isMeSelected,
                    someoneElseSelected: viewModel.someoneElseSelected,
                    me: viewModel.me,
                    center: center,
                    color: viewModel.dailyMood?.mood?.color ?? .brown,
                    note: viewModel.dailyMood?.noteContent ?? "No note.",
                    date: viewModel.date,
                    username: UserDefaults.standard.string(forKey: "Username") ?? "",
                    selectedFriend: $viewModel.selectedFriend,
                    showEmotePicker: $showEmotePicker
                )
                    .transition(.scale)
            }

            if showFriendCircles {
                ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) {
                    index, friend in
                    FriendCircleView(
                        friend: friend,
                        index: index,
                        center: center,
                        radius: radius,
                        scale: 1.0,
                        date: viewModel.date,
                        totalSpots: viewModel.socialCard.friends.count,
                        selectedFriend: $viewModel.selectedFriend,
                        showEmotePicker: $showEmotePicker,
                        firestoreManager: firestoreManager
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private func personalCircle(center: CGPoint) -> some View {
        let meScale: CGFloat =
            viewModel.isMeSelected ? 3.0 : (viewModel.someoneElseSelected ? 0.1 : 1.2)

        return Circle()
            .fill(viewModel.dailyMood?.mood?.color ?? .gray)
            .frame(width: 80 * meScale, height: 80 * meScale)
            .shadow(color: .black.opacity(0.2), radius: 4)
            .zIndex(viewModel.someoneElseSelected ? -1 : viewModel.isMeSelected ? 1 : 0)
            .overlay(
                Text(
                    viewModel.isMeSelected
                        ? (viewModel.dailyMood?.noteContent?.isEmpty == true
                            ? "No note" : viewModel.dailyMood?.noteContent ?? "No note")
                        : "Me"
                )
                .lineLimit(7)
                .font(
                    viewModel.isMeSelected
                        ? .satoshi(size: 22, weight: .regular) : .satoshi(size: 32, weight: .bold)
                )
                .multilineTextAlignment(.center)
                .minimumScaleFactor(2 / 24)
                .foregroundColor(.white)
                .padding(32)
            )
            .position(x: center.x, y: center.y)
            .onTapGesture {
                withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                    viewModel.selectedFriend = viewModel.isMeSelected ? nil : viewModel.me
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
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        )

        var body: some View {
            SocialCardView(
                viewModel: viewModel
            )
        }
    }

    return PreviewWrapper()
}
