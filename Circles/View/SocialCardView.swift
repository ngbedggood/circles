//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {

    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }

    @State private var selectedFriend: FriendColor? = nil
    let me = FriendColor(name: "Me", color: .gray, note: "Lets roll!")

    let radius: CGFloat = 100
    var isPreview: Bool = false
    var date: Date
    var socialCard: SocialCard
    var dailyMood: DailyMood?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            VStack {

                Image(systemName: "arrowshape.up.fill")
                    .foregroundStyle(.white)
                    .offset(y: -170)

                ZStack {
                    GeometryReader { geometry in
                        let center = CGPoint(
                            x: geometry.size.width / 2, y: geometry.size.height / 2)

                        let isMeSelected = selectedFriend?.id == me.id
                        let someoneElseSelected = selectedFriend != nil && !isMeSelected
                        let meY = center.y
                        let meX = center.x
                        let meScale: CGFloat =
                            isMeSelected ? 3.0 : (someoneElseSelected ? 0.1 : 1.2)

                        // Personal circle
                        Circle()
                            .fill(dailyMood?.mood?.color ?? .gray)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(
                                    isMeSelected
                                        ? (dailyMood?.noteContent?.isEmpty == true
                                            ? "No note" : dailyMood?.noteContent ?? "No note")
                                        : "Me"
                                )
                                .font(isMeSelected ? .system(size: 6) : .system(size: 24))
                                .foregroundColor(.white)
                                .fontWeight(isMeSelected ? .regular : .bold)
                                .padding(12)
                            )
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.2)
                            .clipShape(Circle())
                            .position(x: meX, y: meY)
                            .scaleEffect(meScale)
                            .zIndex(isMeSelected ? 1 : 0)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedFriend = isMeSelected ? nil : me
                                }
                            }
                        // Social circles
                        let totalSpots = socialCard.friends.count
                        ForEach(Array(socialCard.friends.enumerated()), id: \.element.id) {
                            index, friend in
                            let isSelected = (selectedFriend?.id == friend.id)
                            let someoneSelected = selectedFriend != nil

                            let angle = Angle(degrees: Double(index) / Double(totalSpots) * 360)
                            let effectiveRadius =
                                isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)

                            let x =
                                center.x
                                + (isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians)))
                            let y =
                                center.y
                                - (isSelected ? 0 : effectiveRadius * CGFloat(cos(angle.radians)))
                            let scale: CGFloat = isSelected ? 3.0 : (someoneSelected ? 0.5 : 1.0)

                            Circle()
                                .fill((friend.color ?? .none).swiftUIColor)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(
                                        selectedFriend?.id == friend.id ? friend.note : friend.name
                                    )
                                    .foregroundColor(.white)
                                    .fontWeight(selectedFriend?.id == friend.id ? .regular : .bold)
                                    .padding(12)
                                )
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.2)  // Shrinks font if needed
                                .padding(20)
                                .clipShape(Circle())
                                .font(
                                    selectedFriend?.id == friend.id
                                        ? .system(size: 6) : .system(size: 24)
                                )
                                .scaleEffect(scale)
                                .position(x: x, y: y)
                                .shadow(color: .black.opacity(0.2), radius: 4)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        if selectedFriend?.id == friend.id {
                                            selectedFriend = nil  // Deselect if tapped again
                                        } else {
                                            selectedFriend = friend
                                        }
                                    }
                                }
                                .zIndex(isSelected ? 1 : 0)

                        }
                    }
                    Text(formattedDate(from: date))
                        .font(.title)
                        .fontWeight(.bold)
                        .zIndex(1)
                        .foregroundColor(.black)
                        .offset(y: 320)  // hacky fix for now
                }

            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var date = Calendar.current.startOfDay(for: Date())
        @State private var socialCard = SocialCard(
            date: "24th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .green, note: "I'm feeling great!"),
                FriendColor(name: "Greg", color: .teal, note: "I'm alright, just a bit tired!"),
            ])
        var dailyMood: DailyMood = DailyMood(
            id: "2025-06-24", mood: .teal, noteContent: "This is a test!", createdAt: .now)

        var body: some View {
            SocialCardView(
                isPreview: true, date: date, socialCard: socialCard, dailyMood: dailyMood)
        }
    }

    return PreviewWrapper()
}
