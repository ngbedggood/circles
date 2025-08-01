//
//  ContentView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var scrollManager: ScrollManager

    @State private var horizontalIndex = 1
    @State private var verticalIndex: Int? = nil
    @State private var isLoggedIn: Bool = true
    @State private var verticalIndices = Array(repeating: 0, count: 7)

    @State private var localDailyMoods: [String: DailyMood] = [:]
    
    @StateObject private var navigationManager = NavigationManager()

    let pastDays = 7

    var datesToDisplay: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        dates.append(today)

        for i in 0..<pastDays - 1 {
            if let pastDate = calendar.date(byAdding: .day, value: -(i + 1), to: today) {
                dates.insert(pastDate, at: 0)
            }
        }
        return dates.sorted()
    }

    var body: some View {
        ZStack {
            if authManager.isInitializing {
                    LoadingView()
                    .transition(.opacity)
            } else if !authManager.isAuthenticated ||
                !authManager.isVerified ||
                !authManager.isProfileComplete {
                ZStack {
                    LoginView(
                        viewModel: LoginViewModel(
                            authManager: authManager
                        )
                    )
                    .transition(.opacity)
                }
            } else {
                ZStack {
                    if firestoreManager.isLoading {
                        LoadingView()
                            .transition(.opacity)
                    } else {
                        switch navigationManager.currentView {
                        case .friends:
                            FriendsView(
                                viewModel: FriendsViewModel(
                                    firestoreManager: firestoreManager,
                                    authManager: authManager
                                )
                            )
                            .transition(.opacity)
                            .environmentObject(navigationManager)
                        case .dayPage:
                            TabView(selection: $horizontalIndex) {
                                ForEach(0..<pastDays, id: \.self) { index in
                                    let date = datesToDisplay[index]
                                    DayPageView(
                                        viewModel: DayPageViewModel(
                                            date: date,
                                            authManager: authManager,
                                            firestoreManager: firestoreManager,
                                            scrollManager: scrollManager
                                        )
                                    )
                                    .environmentObject(navigationManager)
                                }
                            }
                            .transition(.opacity)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .onAppear {
                                horizontalIndex = pastDays - 1
                            }
                            .highPriorityGesture(
                                DragGesture(), isEnabled: scrollManager.isHorizontalScrollDisabled)
                        }
                    }
                }
                .animation(.easeInOut(duration: 1.5), value: firestoreManager.isLoading)
            }
        }
        .ignoresSafeArea(.keyboard)
        .font(.satoshi(.body))
    }

}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            ContentView()
        }
    }
    
    return PreviewWrapper()
}
