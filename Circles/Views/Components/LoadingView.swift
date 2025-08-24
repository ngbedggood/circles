//
//  LoadingView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/06/2025.
//

import SwiftUI

struct LoadingView: View {
    let delayInSeconds: Int = 6
    @State private var showLoading: Bool = false
    var body: some View {
        ZStack {
            AppIcon()
            LoadingIcon()
                .offset(y: 240)
                .opacity(showLoading ? 1 : 0)
        }
        .background(.backgroundTint)
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delayInSeconds) * 1_000_000_000) // 6 seconds
                withAnimation {
                    showLoading = true
                }
            }
        }
    }
}

#Preview {
    LoadingView()
}
