//
//  DayPageView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 05/07/2025.
//

import SwiftUI

struct DayPageView: View {

    @StateObject var viewModel: DayPageViewModel
    var index: Int = 0

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                PersonalCardView(viewModel: viewModel)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 8)
                    )
                    .padding(24)
                SocialCardView(viewModel: viewModel)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 8)
                    )
                    .padding(24)
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollDisabled(viewModel.scrollDisabled)
    }
}

#Preview {
    struct PreviewWrapper: View {

        var viewModel: DayPageViewModel = DayPageViewModel(
            date: Date(),
            authManager: AuthManager(),
            firestoreManager: FirestoreManager()
        )

        var index: Int = 0

        var body: some View {
            DayPageView(viewModel: viewModel)
        }
    }

    return PreviewWrapper()
}
