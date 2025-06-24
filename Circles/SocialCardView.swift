//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {
    
    @State private var selectedFriend: FriendColor? = nil
    let me = FriendColor(name: "Me", color: .gray)
    
    let radius: CGFloat = 100
    var isPreview: Bool = false
    var socialCard: SocialCard
    var personalCard: PersonalCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            VStack {
                Image(systemName: "arrowshape.up.fill")
                    .foregroundStyle(.white)
                    .offset(y:-280)
                
                
                ZStack {
                    
                    let isMeSelected = selectedFriend?.id == me.id
                    let someoneElseSelected = selectedFriend != nil && !isMeSelected
                    let meOffset = isMeSelected ? CGSize.zero : CGSize(width: 0, height: -radius * (someoneElseSelected ? 3.0 : 1.0))
                    let meScale: CGFloat = isMeSelected ? 3.0 : (someoneElseSelected ? 0.5 : 1.0)
                    
                    Circle()
                        .fill(personalCard.color?.swiftUIColor ?? .gray)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("Me")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    )
                    .offset(meOffset)
                    .scaleEffect(meScale)
                    .zIndex(isMeSelected ? 1 : 0)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedFriend = isMeSelected ? nil : me
                        }
                    }
                
                    
                    ForEach(Array(socialCard.friends.enumerated()), id: \.element.id) { index, friend in
                        let isSelected = (selectedFriend?.id == friend.id)
                        let someoneSelected = selectedFriend != nil
                        let totalSpots = socialCard.friends.count + 1
                        
                        let angle = Angle(degrees: Double(index + 1) / Double(totalSpots) * 360)
                        let effectiveRadius = isSelected ? 0 : (someoneSelected ? radius * 1.5 : radius)
                        
                        let x = isSelected ? 0 : effectiveRadius * CGFloat(sin(angle.radians))
                        let y = isSelected ? 0 : -effectiveRadius * CGFloat(cos(angle.radians))
                        let scale: CGFloat = isSelected ? 3.0 : (someoneSelected ? 0.5 : 1.0)

                        ZStack {
                            Circle()
                                .fill((friend.color ?? .none).swiftUIColor)
                                .frame(width: 80, height: 80)
                            Text(friend.name)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .scaleEffect(scale)
                        .offset(x: x, y: y)
                        .onTapGesture {
                        withAnimation(.spring()) {
                            if selectedFriend?.id == friend.id {
                               selectedFriend = nil // Deselect if tapped again
                           } else {
                               selectedFriend = friend
                           }
                        }
                    }
                       .zIndex(isSelected ? 1 : 0)
                    }
                }
                
                Text(personalCard.date)
                    .font(.title)
                    .fontWeight(.bold)
                    .zIndex(1)
                    .foregroundColor(.black)
                    .offset(y: 276) //hacky fix for now
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var socialCard = SocialCard(date: "24th June 2025", friends: [FriendColor(name: "Jack", color: .green), FriendColor(name: "Jill", color: .teal)])
        @State private var personalCard = PersonalCard(date: "24th June 2025", color: .teal, note: "I'm feeling a bit eh today...")

            var body: some View {
                SocialCardView(isPreview: true, socialCard: socialCard, personalCard: personalCard)
            }
        }

        return PreviewWrapper()
}
