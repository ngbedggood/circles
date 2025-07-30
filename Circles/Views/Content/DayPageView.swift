//
//  DayPageView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import SwiftUI

struct DayPageView: View {
    @EnvironmentObject var scrollManager: ScrollManager
    @StateObject var viewModel: DayPageViewModel
    var index: Int = 0

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    PersonalCardView(viewModel: viewModel)
                        .frame(height: screenHeight)
                    SocialCardView(viewModel: viewModel)
                        .frame(height: screenHeight)
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollDisabled(viewModel.isDayVerticalScrollDisabled)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {

        var viewModel: DayPageViewModel = DayPageViewModel(
            date: Date(),
            authManager: AuthManager(),
            firestoreManager: FirestoreManager(),
            scrollManager: ScrollManager()
        )

        var index: Int = 0

        var body: some View {
            DayPageView(viewModel: viewModel)
        }
    }

    return PreviewWrapper()
}
