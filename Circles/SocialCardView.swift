//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {
    
    let radius: CGFloat = 100
    var isPreview: Bool = false
    var card: SocialCard
    var selfColor: CardColor
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            
            ZStack {
                Circle()
                    .fill(selfColor.swiftUIColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("Me")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
                .offset(x: 0, y: -radius)
                .zIndex(1)
                
                ForEach(Array(card.friends.enumerated()), id: \.element.id) { index, friend in
                    let totalSpots = card.friends.count + 1
                    let angle = Angle(degrees: Double(index + 1) / Double(totalSpots) * 360)
                    let x = radius * CGFloat(sin(angle.radians))
                    let y = -radius * CGFloat(cos(angle.radians))

                    ZStack {
                        Circle()
                            .fill((friend.color ?? .none).swiftUIColor)
                            .frame(width: 80, height: 80)
                        Text(friend.name)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .offset(x: x, y: y)
                }
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var card = SocialCard(date: "24th June 2025", friends: [FriendColor(name: "Jack", color: .green), FriendColor(name: "Jill", color: .blue)])

            var body: some View {
                SocialCardView(isPreview: true, card: card, selfColor: .none)
            }
        }

        return PreviewWrapper()
}
