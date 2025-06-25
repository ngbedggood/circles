//
//  VerticalPager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct VerticalPager: View {

    @Binding var personalCard: PersonalCard
    var socialCard: SocialCard
    @Binding var verticalIndex: Int
    
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $verticalIndex) {
                PersonalCardView(card: $personalCard, verticalIndex: $verticalIndex)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
                    .padding(20)
                    .tag(0)
                if personalCard.color != nil {
                    SocialCardView(socialCard: socialCard, personalCard: personalCard)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
                        .padding(20)
                        .tag(1)
                }
            }
            
            .rotationEffect(.degrees(90)) // make tabview scroll vertical
            .frame(width: geo.size.height, height: geo.size.width) // swap width/height
            .offset(x: (geo.size.width - geo.size.height) / 2,
                    y: (geo.size.height - geo.size.width) / 2)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var personalCard = PersonalCard(date: "24th June 2025", color: nil, note: "Hello World.")
        @State private var socialCard = SocialCard(date: "24th June 2025", friends: [FriendColor(name: "Jack", color: .green, note: "I'm feeling great!")])
        @State private var verticalIndex = 0
        
            var body: some View {
                VerticalPager(personalCard: $personalCard, socialCard: socialCard, verticalIndex: $verticalIndex)
            }
        }

        return PreviewWrapper()
}
