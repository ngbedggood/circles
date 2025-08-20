//
//  CircleReactionsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 19/08/2025.
//

import SwiftUI

struct CircleReactionsView: View {
    var reactions: [Reaction]
    var visibleReactions: Set<String> = []
//    var isSelected: Bool
    
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
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: visibleReactions)
                    .shadow(color: .white, radius: 8)
            }
        }
//        .onChange(of: isSelected) { _, newValue in
//            if newValue {
//                for (idx, emote) in reactions.enumerated() {
//                    let delay = Double(idx) * 0.15
//                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                        if let id = emote.id {
//                            visibleReactions.insert(id)
//                        }
//                    }
//                }
//            } else {
//                visibleReactions.removeAll()
//            }
//        }
//        .onChange(of: reactions) { _, newReactions in
//            if isSelected {
//                let newIDs = Set(newReactions.compactMap { $0.id })
//
//                // Handle new reactions
//                for (idx, emote) in newReactions.enumerated() {
//                    if let id = emote.id, !visibleReactions.contains(id) {
//                        let delay = Double(idx) * 0.15
//                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                            visibleReactions.insert(id)
//                        }
//                    }
//                }
//
//                // Handle removed reactions
//                let removed = visibleReactions.subtracting(newIDs)
//                for (idx, id) in removed.enumerated() {
//                    let delay = Double(idx) * 0.1
//                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                        visibleReactions.remove(id)
//                    }
//                }
//            } else {
//                visibleReactions.removeAll()
//            }
//        }
        .zIndex(5)
    }
}

#Preview {
    CircleReactionsView(reactions: [], visibleReactions: [])
}
