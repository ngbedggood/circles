//
//  DayPageView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import SwiftUI

struct VerticalOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DayPageView: View {
    @EnvironmentObject var scrollManager: ScrollManager
    @StateObject var viewModel: DayPageViewModel
    @Binding var verticalOffset: CGFloat
    var index: Int = 0

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        PersonalCardView(
                            viewModel: viewModel,
                            onDown: {
                                withAnimation {
                                    proxy.scrollTo("social", anchor: .top)
                                }
                            }
                        )
                            .frame(height: screenHeight)
                            .id("personal")
                        SocialCardView(
                            viewModel: viewModel,
                            onUp: {
                                withAnimation {
                                    proxy.scrollTo("personal", anchor: .top)
                                }
                            }
                        )
                        .frame(height: screenHeight)
                        .id("social")
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: VerticalOffsetPreferenceKey.self,
                                            value: geo.frame(in: .global).minY)
                        }
                    )
                }
                .onPreferenceChange(VerticalOffsetPreferenceKey.self) { value in
                    verticalOffset = value
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollDisabled(viewModel.isDayVerticalScrollDisabled)
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .toast(
            isShown: $viewModel.showToast,
            type: viewModel.toastStyle,
            title: "Success",
            message: viewModel.toastMessage
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        
        @State var verticalOffset: CGFloat = 0

        var viewModel: DayPageViewModel = DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()),
            firestoreManager: FirestoreManager(),
            streakManager: StreakManager(
                authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
                firestoreManager: FirestoreManager()),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        )

        var body: some View {
            DayPageView(viewModel: viewModel, verticalOffset: $verticalOffset)
        }
    }

    return PreviewWrapper()
}
