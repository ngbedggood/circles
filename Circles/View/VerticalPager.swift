//
//  VerticalPager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/06/2025.
//

import SwiftUI

struct VerticalPager: View {
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager

    var date: Date
    var dailyMood: DailyMood?
    var socialCard: SocialCard
    @Binding var verticalIndex: Int
    
    @State private var isViewModelInitialized = false

    var body: some View {
        GeometryReader { geo in
            TabView(selection: $verticalIndex) {
                PersonalCardView(
                    viewModel: PersonalCardViewModel(
                        date: date,
                        dailyMood: dailyMood,
                        authManager: authManager,
                        firestoreManager: firestoreManager
                    ),
                    verticalIndex: $verticalIndex
                )
                .background(
                    RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10)
                )
                .padding(20)
                .tag(0)
                if dailyMood != nil {
                    SocialCardView(
                        viewModel: SocialCardViewModel(
                            date: date,
                            dailyMood: dailyMood,
                            socialCard: socialCard,
                            authManager: authManager,
                            firestoreManager: firestoreManager
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10)
                    )
                    .padding(20)
                    .tag(1)
                }
            }

            .rotationEffect(.degrees(90))  // make tabview scroll vertical
            .frame(width: geo.size.height, height: geo.size.width)  // swap width/height
            .offset(
                x: (geo.size.width - geo.size.height) / 2,
                y: (geo.size.height - geo.size.width) / 2
            )
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var dailyMood: DailyMood = DailyMood(
            id: "2025-06-24", mood: .teal, noteContent: "This is a test!", createdAt: .now)
        @State private var socialCard = SocialCard(
            date: "24th June 2025",
            friends: [FriendColor(name: "Jack", color: .green, note: "I'm feeling great!")])
        @State private var verticalIndex = 0
        var date = Calendar.current.startOfDay(for: Date())

        var body: some View {
            VerticalPager(
                date: date,
                dailyMood: dailyMood,
                socialCard: socialCard,
                verticalIndex: $verticalIndex)
        }
    }

    return PreviewWrapper()
}
