//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {

    @ObservedObject var viewModel: DayPageViewModel

    @State private var circleAppeared: [Bool] = []
    @State private var animatingCircles: Bool = true
    @State private var showPersonalCircle: Bool = false

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
                            showPersonalCircle = true
                        }
                        await viewModel.retrieveFriendsWithMoods()
                    }
                } else {
                    circleAppeared = Array(
                        repeating: false, count: viewModel.socialCard.friends.count)
                    showPersonalCircle = false
                }
            }
            .onChange(of: viewModel.socialCard.friends) { _, friends in
                circleAppeared = Array(repeating: false, count: friends.count)
                animateCirclesInSequence()
            }
            .onChange(of: viewModel.dailyMood) { _, newValue in
                circleAppeared = Array(repeating: false, count: viewModel.socialCard.friends.count)
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
                }
            }
            .padding(24)
        }
    }

    private func animateCirclesInSequence() {
        for index in viewModel.socialCard.friends.indices {
            // Apply a delayed spring animation to each circle.
            withAnimation(.spring().delay(0.15 * Double(index))) {
                if index < circleAppeared.count {
                    circleAppeared[index] = true
                }
            }
        }
        animatingCircles = false
    }

    private func friendCircles(in geometry: GeometryProxy) -> some View {
        ZStack {
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            if showPersonalCircle {
                personalCircle(center: center)
                    .transition(.scale)
            }

            ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) {
                index, friend in
                if index < circleAppeared.count {
                    socialCircle(
                        friend: friend,
                        index: index,
                        center: center,
                        hasAppeared: circleAppeared[index]
                    )
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

    private func socialCircle(friend: FriendColor, index: Int, center: CGPoint, hasAppeared: Bool)
        -> some View
    {
        let totalSpots = viewModel.socialCard.friends.count
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let isSelected = (viewModel.selectedFriend?.id == friend.id)
        let someoneSelected = viewModel.selectedFriend?.id != nil
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)

        let x = center.x + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
        let y = center.y - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))

        let anotherScale = max(0.9, 1.0 - CGFloat(totalSpots - 1) * 0.05)  // Subtle scaling as more friends are shown (base scale = 1.0, min scale = 0.7)

        let scale: CGFloat =
            isSelected ? 3.0 : (someoneSelected ? 0.5 * anotherScale : 1.0 * anotherScale)

        return ZStack {
            Circle()
                .fill(friend.color?.color ?? Color.gray)
                .frame(width: 80 * scale, height: 80 * scale)
                .shadow(color: .black.opacity(0.3), radius: 4)
                .zIndex(isSelected ? 1 : 0)
                .overlay(
                    ZStack {
                        Text(isSelected ? friend.note : friend.name)
                            .lineLimit(7)
                            .font(
                                isSelected
                                    ? .satoshi(size: 22, weight: .regular)
                                    : .satoshi(size: 20, weight: .bold)
                            )
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(4 / 24)
                            .foregroundColor(.white)
                            .padding(8)
                        // Message icon for future chat functionality
                        //                        if isSelected {
                        //                            Button(action: {
                        //
                        //                            }) {
                        //                                Image(systemName: "ellipsis.message.fill")
                        //                                    .font(.system(size: 28))
                        //                                    .foregroundColor(.white)
                        //                            }
                        //                            .offset(y: 88)
                        //                        }
                    }
                    .transition(.scale)
                )
                .position(x: x, y: y)
                .onTapGesture {
                    withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                        viewModel.selectedFriend = isSelected ? nil : friend
                    }
                }
                .scaleEffect(hasAppeared ? 1 : 0)
                .opacity(hasAppeared ? 1 : 0)
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
            authManager: AuthManager(),
            firestoreManager: FirestoreManager(),
            scrollManager: ScrollManager()
        )

        var body: some View {
            SocialCardView(
                viewModel: viewModel
            )
        }
    }

    return PreviewWrapper()
}
