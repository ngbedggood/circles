//
//  CircleReactionsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct CircleReactionsView: View {
    var reactions: [Reaction]
    var visibleReactions: Set<String>

    var body: some View {
        ZStack {
            ForEach(Array(reactions.enumerated()), id: \.element.id) { idx, emote in
                let angle = Double(idx) / Double(max(reactions.count - 1, 1)) * 45
                let reactAngle = Angle(degrees: angle)
                let xOffset = sin(reactAngle.radians) * 120
                let yOffset = -cos(reactAngle.radians) * 120
                let isVisible = visibleReactions.contains(emote.id ?? "")
                
                Text(emote.reaction)
                    .font(.system(size: 28))
                    .offset(x: xOffset, y: yOffset)
                    .scaleEffect(isVisible ? 1 : 0.1)
                    .opacity(isVisible ? 1 : 0)
                    .transition(.scale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: visibleReactions)
                    .shadow(color: .white, radius: 8)
            }
        }
        .zIndex(5)
    }
}

#Preview {
    CircleReactionsView(reactions: [], visibleReactions: [])
}
