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
        PersonalCard(date: "20th June 2025", color: nil, note: ""),
        PersonalCard(date: "21st June 2025", color: nil, note: ""),
        PersonalCard(date: "22nd June 2025", color: nil, note: ""),
        PersonalCard(date: "23rd June 2025", color: nil, note: ""),
        PersonalCard(date: "24th June 2025", color: nil, note: ""),
    ]

    // Dummy Data
    var socialCards = [
        SocialCard(
            date: "20th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .yellow, note: "I'm alright!"),
            ]),
        SocialCard(
            date: "20th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .green, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .gray, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .gray, note: "My plant passed away..."),
            ]),
        SocialCard(
            date: "20th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .green, note: "Today is the day!"),
                FriendColor(name: "John", color: .orange, note: "I'm feeling great!"),
                FriendColor(
                    name: "Mary", color: .gray, note: "I'm feeling a bit lonely right now.."),
            ]),
        SocialCard(
            date: "20th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .yellow, note: "Something is a bit off"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .green, note: "I'm feeling great!"),
            ]),
        SocialCard(
            date: "20th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "Tessa", color: .green, note: "I'm excited for the weekend!"),
            ]),
    ]

    @State private var horizontalIndex = 0
    @State private var verticalIndex = 0

    var body: some View {
        ZStack {
            TabView(selection: $horizontalIndex) {
                ForEach(personalCards.indices, id: \.self) { index in
                    VerticalPager(
                        personalCard: $personalCards[index], socialCard: socialCards[index],
                        verticalIndex: $verticalIndex
                    )
                    .tag(index)
                }
            }
            .ignoresSafeArea(.keyboard)
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
