//
//  StreakView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 28/08/2025.
//

import SwiftUI

struct StreakView: View {
    
    let streakCount: Int
    let isSelected: Bool
    
    var body: some View {
            Text("\(streakCount) 🔥")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.fakeBlack)
                .padding(.horizontal, 4)
                .frame(height: 20)
                .background(
                    Capsule()
                        .fill(Color.white)
                )
                //.shadow(radius: 1)
                .offset(x: 30, y: 30)
                .scaleEffect(isSelected ? 0 : 1)
    }
}

#Preview {
    StreakView(streakCount: 69, isSelected: false)
}
