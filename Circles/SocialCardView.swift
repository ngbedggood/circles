//
//  SocialCardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct SocialCardView: View {
    var isPreview: Bool = false
    var card: SocialCard
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            
            VStack {
                Spacer()
                ForEach(card.friends, id: \.id) { friend in
                    ZStack {
                        Circle()
                            .fill((friend.color ?? .none).swiftUIColor)
                            .frame(width: 100, height: 100)
                        Text(friend.name)
                    }
                }
                Spacer()
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var card = SocialCard(date: "24th June 2025", friends: [FriendColor(name: "Jack", color: .green), FriendColor(name: "Jill", color: .blue)])

            var body: some View {
                SocialCardView(isPreview: true, card: card)
            }
        }

        return PreviewWrapper()
}
