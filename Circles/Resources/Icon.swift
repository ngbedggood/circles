//
//  SwiftUIView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 24/06/2025.
//

import SwiftUI

struct Icon: View {
    let scale = 0.8
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white)
            Circle()
                .fill(.gray)
                .frame(width: 100, height: 100)
                .offset(x: 0, y: 0)
                .scaleEffect(1.2 * scale)
            Circle()
                .fill(.orange)
                .frame(width: 100, height: 100)
                .offset(x: 10, y: -10)
                .scaleEffect(1.1 * scale)
            Circle()
                .fill(.yellow)
                .frame(width: 100, height: 100)
                .offset(x: 20, y: -20)
                .scaleEffect(scale)
            Circle()
                .fill(.green)
                .frame(width: 100, height: 100)
                .offset(x: 30, y: -30)
                .scaleEffect(0.9 * scale)
            Circle()
                .fill(.teal)
                .overlay(
                    Image(systemName: "face.smiling")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                )
                .frame(width: 100, height: 100)
                .offset(x: 40, y: -40)
                .scaleEffect(0.8 * scale)
            
            Text("Circles")
                .font(.satoshi(size: 24, weight: .bold))
                .offset(y: 80)
        }

    }
}

#Preview {
    Icon()
}
