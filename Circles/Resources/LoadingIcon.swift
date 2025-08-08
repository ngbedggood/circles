//
//  SwiftUIView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 24/06/2025.
//

import SwiftUI

struct LoadingIcon: View {
    @State private var currentIndex = 0
    let colors: [Color] = [.gray, .orange, .yellow, .green, .teal]
    let dotSize: CGFloat = 10
    let spacing: CGFloat = 10
    let animationDuration = 0.5
    let moveDistance: CGFloat = 15
    let pauseDuration: Double = 1.0

    var body: some View {
        ZStack {
            HStack(spacing: spacing) {
                ForEach(colors.indices, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: currentIndex == index ? -moveDistance : 0)
                        .animation(.easeInOut(duration: animationDuration), value: currentIndex)
                }
            }

            Text("Loading...")
                .font(.satoshi(.caption, weight: .regular))
                .offset(y: 24)
        }
        .onAppear {
            Task {
                await startAnimating()
            }
            
        }
    }

    func startAnimating() async {
        while true {
                    // "Wave" through each of the dots
                    for i in colors.indices {
                        currentIndex = i
                        try? await Task.sleep(for: .seconds(animationDuration))
                    }
                    currentIndex = -1
                    try? await Task.sleep(for: .seconds(pauseDuration))
                    try? await Task.sleep(for: .seconds(animationDuration))
                }
    }
}

#Preview {
    LoadingIcon()
}
