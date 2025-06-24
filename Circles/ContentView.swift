//
//  ContentView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct ContentView: View {
    
    let date = Date()

    //Dummy data
    @State private var personalCards = [
        PersonalCard(date: "20th June 2025", color: nil),
        PersonalCard(date: "21st June 2025", color: nil),
        PersonalCard(date: "22nd June 2025", color: nil),
        PersonalCard(date: "23rd June 2025", color: nil),
        PersonalCard(date: "24th June 2025", color: nil),
    ]
    var socialCards = [
        SocialCard(date: "20th June 2025", friends: [FriendColor(name: "Jack", color: .blue), FriendColor(name: "John", color: .yellow), FriendColor(name: "Mary", color: .yellow)]),
        SocialCard(date: "20th June 2025", friends: [FriendColor(name: "Jack", color: .green), FriendColor(name: "John", color: .red), FriendColor(name: "Mary", color: .red)]),
        SocialCard(date: "20th June 2025", friends: [FriendColor(name: "Jack", color: .green), FriendColor(name: "John", color: .orange), FriendColor(name: "Mary", color: .red)]),
        SocialCard(date: "20th June 2025", friends: [FriendColor(name: "Jack", color: .yellow), FriendColor(name: "John", color: .yellow), FriendColor(name: "Mary", color: .green)]),
        SocialCard(date: "20th June 2025", friends: [FriendColor(name: "Jack", color: .blue), FriendColor(name: "John", color: .yellow), FriendColor(name: "Mary", color: .blue), FriendColor(name: "Tessa", color: .green)]),
    ]
    
    @State private var horizontalIndex = 0
    @State private var verticalIndex = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $horizontalIndex) {
                ForEach(personalCards.indices, id: \.self) { index in
                    VerticalPager(personalCard: $personalCards[index], socialCard: socialCards[index], verticalIndex: $verticalIndex)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                horizontalIndex = personalCards.count - 1
            }
            .gesture(verticalIndex == 0 ? DragGesture() : nil)
        }
    }
}

#Preview {
    ContentView()
}
