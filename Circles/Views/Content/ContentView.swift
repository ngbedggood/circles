//
//  ContentView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var scrollManager: ScrollManager
    @EnvironmentObject var notificationManager: NotificationManager

    @StateObject private var dayPageViewModels: DayPageViewModelsHolder

    @State private var horizontalIndex = 1
    @State private var verticalIndex: Int? = nil
    @State private var isLoggedIn: Bool = true
    @State private var verticalIndices = Array(repeating: 0, count: 7)
    @State private var shake: CGFloat = 0

    @StateObject private var navigationManager = NavigationManager()

    let pastDays = 7
    
    init() {
        // Note: We can't access EnvironmentObjects in init, so we'll initialize in onAppear
        self._dayPageViewModels = StateObject(wrappedValue: DayPageViewModelsHolder(pastDays: 7))
    }

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
            } else if !authManager.isAuthenticated || !authManager.isVerified
                || !authManager.isProfileComplete
            {
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
                    if !firestoreManager.isLoading {
                        switch navigationManager.currentView {
                            case .friends:
                                FriendsView(
                                    viewModel: FriendsViewModel(
                                        firestoreManager: firestoreManager,
                                        authManager: authManager,
                                        notificationManager: notificationManager
                                    )
                                )
                                .transition(.opacity)
                                .environmentObject(navigationManager)
                            case .dayPage:
                                if !firestoreManager.isLoading {
                                    TabView(selection: $horizontalIndex) {
                                        ForEach(Array(dayPageViewModels.models.enumerated()), id: \.offset) { index, viewModel in
                                            DayPageView(viewModel: viewModel)
                                                .environmentObject(navigationManager)
                                                .tag(index)
                                        }
                                    }
                                    .transition(.opacity)
                                    .tabViewStyle(.page(indexDisplayMode: .never))
                                    .onAppear {
                                        horizontalIndex = pastDays - 1
                                        if dayPageViewModels.models.isEmpty {
                                            dayPageViewModels.initializeModels(
                                                pastDays: pastDays,
                                                authManager: authManager,
                                                firestoreManager: firestoreManager,
                                                notificationManager: notificationManager,
                                                scrollManager: scrollManager
                                            )
                                        }
                                    }
                                    .onAppear {
                                        jiggle()
                                    }
                                    .highPriorityGesture(
                                        DragGesture(),
                                        isEnabled: scrollManager.isHorizontalScrollDisabled)
                                }
                        }
                    }
                }
                .animation(.easeInOut(duration: 1.5), value: firestoreManager.isLoading)
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                dayPageViewModels.purgeModels()
            }
        }
        .ignoresSafeArea(.keyboard)
//        .edgesIgnoringSafeArea(.top)
//        .edgesIgnoringSafeArea(.bottom)
        .font(.satoshi(.body))
        .offset(x: shake)
        .background(Color.backgroundTint)
    }
    
    private func jiggle() {
        if UserDefaults.standard.bool(forKey: "hasJiggled") {
            print("Has jiggled ;)")
            return
        }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 0.1)) {
                shake = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shake = 20
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    shake = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shake = 20
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    shake = 0
                }
            }
        }
        UserDefaults.standard.set(true, forKey: "hasJiggled")
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
