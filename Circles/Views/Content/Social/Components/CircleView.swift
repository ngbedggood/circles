//
//  CircleView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 20/08/2025.
//

import SwiftUI

struct CircleView: View {
    let color: Color
    let text: String
    let font: Font
    let size: CGFloat
    let padding: CGFloat
    let isSelected: Bool
    let hasReacted: Bool
    let timeAgo: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .shadow(radius: 4)
                .overlay(
                    Text(text)
                        .lineLimit(7)
                        .font(font)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(2 / 20)
                        .foregroundColor(.white)
                        .padding(padding)
                )
                .zIndex(isSelected ? 1 : 0)
            Text("Hold down to\nadd an emote")
                .font(.satoshi(size: 10))
                .foregroundColor(.white)
                .opacity(isSelected && !hasReacted ? 1 : 0)
                .offset(y: 90)
                .zIndex(2)
            Text(timeAgo)
                .font(.satoshi(size: 10))
                .foregroundColor(.white)
                .opacity(isSelected && hasReacted ? 1 : 0)
                .offset(y: 90)
                .zIndex(2)
        }
    }
}
