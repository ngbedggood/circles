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
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(radius: 4)
            .overlay(
                Text(text)
                    .lineLimit(7)
                    .font(font)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(4 / 24)
                    .foregroundColor(.white)
                    .padding(8)
            )
            .zIndex(isSelected ? 1 : 0)
    }
}
