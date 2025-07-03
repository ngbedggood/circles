//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {

    @StateObject var viewModel: SocialCardViewModel

    @State private var hasLoadedData = false

    @Binding var verticalIndex: Int?

    let radius: CGFloat = 100

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
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
            VStack {
                VStack {
                    Image(systemName: "arrowshape.up.fill")
                        .foregroundStyle(.white)
                    Text(
                        "\(viewModel.firestoreManager.userProfile?.displayName ?? "No display name") (\(viewModel.firestoreManager.userProfile?.username ?? "No username"))"
                    )
                    .zIndex(1)
                    .foregroundColor(.black.opacity(0.2))
                    .font(.caption2)
                }
                .padding()

                ZStack {
                    GeometryReader { geometry in
                        friendCircles(in: geometry)
                    }
                }

                Text(viewModel.formattedDate())
                    .font(.title)
                    .fontWeight(.bold)
                    .zIndex(1)
                    .foregroundColor(.black.opacity(0.8))
                    .padding()
            }
        }
        .frame(height: 720)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task {  // Use .task to call the async method when the view appears
            await viewModel.retrieveFriendsWithMoods()
        }
        .onScrollVisibilityChange { isVisible in
            if isVisible {
                Task {
                    await viewModel.retrieveFriendsWithMoods()
                }
            }
        }
    }

    private func friendCircles(in geometry: GeometryProxy) -> some View {
        ZStack {
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            personalCircle(center: center)

            ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) {
                index, friend in
                socialCircle(friend: friend, index: index, center: center)
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
            .zIndex(viewModel.isMeSelected ? 1 : 0)
            .overlay(
                Text(
                    viewModel.isMeSelected
                        ? (viewModel.dailyMood?.noteContent?.isEmpty == true
                            ? "No note" : viewModel.dailyMood?.noteContent ?? "No note")
                        : "Me"
                )
                .lineLimit(7)
                .fontWeight(viewModel.isMeSelected ? .regular : .bold)
                .font(viewModel.isMeSelected ? .system(size: 24) : .system(size: 30))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(4 / 24)
                .foregroundColor(.white)
                .padding(12)
            )
            .position(x: center.x, y: center.y)
            .onTapGesture {
                withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                    viewModel.selectedFriend = viewModel.isMeSelected ? nil : viewModel.me
                }
            }
    }

    private func socialCircle(friend: FriendColor, index: Int, center: CGPoint) -> some View {
        let totalSpots = viewModel.socialCard.friends.count
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let isSelected = (viewModel.selectedFriend?.id == friend.id)
        let someoneSelected = viewModel.selectedFriend?.id != nil
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)

        let x = center.x + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
        let y = center.y - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))
        let scale: CGFloat = isSelected ? 3.0 : (someoneSelected ? 0.5 : 1.0)

        return ZStack {
            Circle()
                .fill(friend.color?.color ?? Color.gray)
                .frame(width: 80 * scale, height: 80 * scale)
                .shadow(color: .black.opacity(0.2), radius: 4)
                .zIndex(isSelected ? 1 : 0)
                .overlay(
                    Text(isSelected ? friend.note : friend.name)
                        .lineLimit(7)
                        .fontWeight(isSelected ? .regular : .bold)
                        .font(isSelected ? .system(size: 24) : .system(size: 20))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(4 / 24)
                        .foregroundColor(.white)
                        .padding(8)

                )
                .position(x: x, y: y)
                .onTapGesture {
                    withAnimation(.spring(response: 0.49, dampingFraction: 0.69)) {
                        viewModel.selectedFriend = isSelected ? nil : friend
                    }
                }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {

        var viewModel: SocialCardViewModel = SocialCardViewModel(
            date: Date(),
            dailyMood: DailyMood(
                id: "2025-06-24",
                mood: .teal,
                noteContent: "This is a test!",
                createdAt: .now),
            authManager: AuthManager(),
            firestoreManager: FirestoreManager()
        )

        @State private var verticalIndex: Int? = 0

        var body: some View {
            SocialCardView(
                viewModel: viewModel,
                verticalIndex: $verticalIndex
            )
        }
    }

    return PreviewWrapper()
}
