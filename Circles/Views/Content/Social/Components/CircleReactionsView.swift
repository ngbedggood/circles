//
//  CircleReactionsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI
import FirebaseAuth

struct CircleReactionsView: View {
    var reactions: [Reaction]
    let color: Color
    let uid = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        ZStack {
            ForEach(Array(reactions.enumerated()), id: \.element.id) { idx, emote in
                let angle = Double(idx) / Double(max(reactions.count - 1, 1)) * 45
                let reactAngle = Angle(degrees: angle)
                let xOffset = sin(reactAngle.radians) * 120
                let yOffset = -cos(reactAngle.radians) * 120
                
                Text(emote.reaction)
                    .font(.system(size: 28))
                    .scaleEffect(emote.fromUID == uid ? 1.4 : 1)
//                    .background(
//                        Circle()
//                            .fill(color)
//                            .frame(width: 48, height: 48)
//                    )
                    .offset(x: xOffset, y: yOffset)
                    .transition(.scale.combined(with: .opacity))
                    .shadow(color: .white, radius: 6)
                    .shadow(color: color, radius: 3)
                    .shadow(color: .white, radius: 1)

            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: reactions.count)
    }
}

#Preview {
    CircleReactionsView(reactions: [], color: .gray)
}
