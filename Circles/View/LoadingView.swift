//
//  LoadingView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/06/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            Circle()
                .fill(.brown.opacity(0.5))
                .frame(width: 200, height: 200)
                .overlay(
                    Text("Loading your circles...")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                )
        }
    }
}

#Preview {
    LoadingView()
}
