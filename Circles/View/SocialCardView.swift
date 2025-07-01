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

    let radius: CGFloat = 100
    var isPreview: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
                .onTapGesture {
                    withAnimation(.spring(
                        response: 0.55,
                        dampingFraction: 0.69,
                        blendDuration: 0
                    )) {
                        viewModel.clearSelection()
                    }
                }
                VStack {
                    Image(systemName: "arrowshape.up.fill")
                        .foregroundStyle(.white)
                        .offset(y: -170)
                    Text("\(viewModel.firestoreManager.userProfile?.displayName ?? "No display name") (\(viewModel.firestoreManager.userProfile?.username ?? "No username"))")
                        .zIndex(1)
                        .foregroundColor(.black.opacity(0.2))
                        .font(.caption2)
                        .offset(y: -140)

                    ZStack {
                        GeometryReader { geometry in
                            friendCircles(in: geometry)
                        }
                        
                        Text(viewModel.formattedDate())
                            .font(.title)
                            .fontWeight(.bold)
                            .zIndex(1)
                            .foregroundColor(.black.opacity(0.8))
                            .offset(y: 320)  // hacky fix for now
                    }
                }
                .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        .task { // Use .task to call the async method when the view appears
            await viewModel.retrieveFriendsWithMoods()
            print("And here too?")
            
        }
        
    }
    
    private func friendCircles(in geometry: GeometryProxy) -> some View {
        ZStack {
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            personalCircle(center: center)

            ForEach(Array(viewModel.socialCard.friends.enumerated()), id: \.element.id) { index, friend in
                socialCircle(friend: friend, index: index, center: center)
            }
        }
    }

    
    // Need to seperate this into another view file, xcode is screaming about view complexity now.
    private func personalCircle(center: CGPoint) -> some View {
        let meScale: CGFloat = viewModel.isMeSelected ? 3.0 : (viewModel.someoneElseSelected ? 0.1 : 1.2)

        return Circle()
            .fill(viewModel.dailyMood?.mood?.color ?? .gray)
            .frame(width: 80, height: 80)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        Image(systemName: "hourglass.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    } else {
                        Text(viewModel.isMeSelected
                             ? (viewModel.dailyMood?.noteContent?.isEmpty == true ? "No note" : viewModel.dailyMood?.noteContent ?? "No note")
                             : "Me"
                        )
                        .font(viewModel.isMeSelected ? .system(size: 6) : .system(size: 24))
                        .fontWeight(viewModel.isMeSelected ? .regular : .bold)
                        .padding(12)
                    }
                }
                .foregroundColor(.white)
            )
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.2)
            .clipShape(Circle())
            .position(x: center.x, y: center.y)
            .scaleEffect(meScale)
            .zIndex(viewModel.isMeSelected ? 1 : 0)
            .shadow(color: .black.opacity(0.2), radius: 4)
            .onTapGesture {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.69)) {
                    viewModel.selectedFriend = viewModel.isMeSelected ? nil : viewModel.me
                }
            }
    }

    private func socialCircle(friend: FriendColor, index: Int, center: CGPoint) -> some View {
        let totalSpots = viewModel.socialCard.friends.count
        let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
        let isSelected = (viewModel.selectedFriend?.id == friend.id)
        let someoneSelected = viewModel.selectedFriend != nil
        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)

        let x = center.x + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
        let y = center.y - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))
        let scale: CGFloat = isSelected ? 3.0 : (someoneSelected ? 0.5 : 1.0)

        return Circle()
            .fill(friend.color?.color ?? Color.gray)
            .frame(width: 80, height: 80)
            .overlay(
                Text(isSelected ? friend.note : friend.name)
                    .foregroundColor(.white)
                    .fontWeight(isSelected ? .regular : .bold)
                    .padding(12)
            )
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.2)
            .padding(20)
            .clipShape(Circle())
            .font(isSelected ? .system(size: 6) : .system(size: 24))
            .scaleEffect(scale)
            .position(x: x, y: y)
            .shadow(color: .black.opacity(0.2), radius: 4)
            .onTapGesture {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.69)) {
                    viewModel.selectedFriend = isSelected ? nil : friend
                }
            }
            .zIndex(isSelected ? 1 : 0)
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

        var body: some View {
            SocialCardView(
                viewModel: viewModel,
                isPreview: true)
        }
    }

    return PreviewWrapper()
}
