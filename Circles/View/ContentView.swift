//
//  ContentView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var am: AuthManager

    // Dummy data
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
            date: "21st June 2025",
            friends: [
                FriendColor(name: "Jack", color: .green, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .gray, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .gray, note: "My plant passed away..."),
            ]),
        SocialCard(
            date: "22nd June 2025",
            friends: [
                FriendColor(name: "Jack", color: .green, note: "Today is the day!"),
                FriendColor(name: "John", color: .orange, note: "I'm feeling great!"),
                FriendColor(
                    name: "Mary", color: .gray, note: "I'm feeling a bit lonely right now.."),
            ]),
        SocialCard(
            date: "23rd June 2025",
            friends: [
                FriendColor(name: "Jack", color: .yellow, note: "Something is a bit off"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .green, note: "I'm feeling great!"),
            ]),
        SocialCard(
            date: "24th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "Tessa", color: .green, note: "I'm excited for the weekend!"),
            ]),
        SocialCard(
            date: "25th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "Tessa", color: .green, note: "I'm excited for the weekend!"),
            ]),
        SocialCard(
            date: "26th June 2025",
            friends: [
                FriendColor(name: "Jack", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "John", color: .yellow, note: "I'm feeling great!"),
                FriendColor(name: "Mary", color: .teal, note: "I'm feeling great!"),
                FriendColor(name: "Tessa", color: .green, note: "I'm excited for the weekend!"),
            ]),
    ]

    @State private var horizontalIndex = 0
    @State private var verticalIndex = 0
    @State private var isLoggedIn: Bool = true

    let pastDays = 7

    var datesToDisplay: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())  // Get start of today to ensure consistent dates

        dates.append(today)

        // Add past dates
        for i in 0..<pastDays {
            if let pastDate = calendar.date(byAdding: .day, value: -(i + 1), to: today) {
                dates.insert(pastDate, at: 0)  // Insert at the beginning to keep chronological order
            }
        }
        return dates.sorted()  // Ensure consistent order
    }

    var body: some View {
        ZStack {
            if am.isAuthenticated {
                if am.fm.isLoading == true {
                    LoadingView()
                        .background(
                            RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10)
                        )
                        .padding(20)
                } else {
                    TabView(selection: $horizontalIndex) {
                        ForEach(0..<pastDays, id: \.self) { i in
                            let date = datesToDisplay[i]
                            let dateId = DailyMood.dateId(from: date)
                            let dailyMood = am.fm.pastMoods[dateId]

                            let _ = print(
                                "Before dailyMoodForDate: \(dailyMood?.mood?.rawValue ?? "nil")")

                            VerticalPager(
                                date: date,
                                dailyMood: dailyMood,
                                socialCard: socialCards[i],
                                verticalIndex: $verticalIndex
                            )
                            .tag(i)
                        }
                    }
                    .ignoresSafeArea(.keyboard)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onAppear {
                        horizontalIndex = pastDays - 1
                    }
                    .gesture(verticalIndex == 0 ? DragGesture() : nil)
                    // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                    for: nil)
                            }
                        }
                    }
                }
            } else {
                LoginView()
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10)
                    )
                    .padding(20)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
