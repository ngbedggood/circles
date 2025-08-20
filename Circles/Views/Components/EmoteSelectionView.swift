//
//  EmoteSelectionView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 18/08/2025.
//

import SwiftUI

struct EmoteSelectionView: View {
    @Binding var showEmotePicker: Bool
    @Binding var selectedEmote: String?
    
    let onSelectEmote: (String) -> Void
    
    var body: some View {
        let emotes = ["❤️","🙌","🤗","😤","😢","🦧","+"]
        let middleIndex = emotes.count / 2
        HStack(spacing: 0){
            ForEach(emotes.indices, id: \.self) { index in
                let emote = emotes[index]
                Button(action: {
                    onSelectEmote(emote)
                    withAnimation {
                        showEmotePicker = false
                    }
                }) {
                    Text("\(emote)")
                        .font(.title)
                        .scaledToFit()
                }
                .frame(width: showEmotePicker ? 40 : 0, height: showEmotePicker ? 40: 0)
                .offset(
                    x: showEmotePicker
                        ? 0
                        : CGFloat(index - middleIndex) * -10 // collapse to center
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showEmotePicker)
                //.border(.red, width: 1)
            }
        }
        .padding(4)
        .background(
            Color(red: 0.84, green: 0.84, blue: 0.84),
            in: Capsule()
        )
        .clipShape(Capsule())
        .opacity(showEmotePicker ? 1 : 0)
        .shadow(radius: 8)
        .zIndex(6)
    }
}

#Preview {
    @Previewable @State var showEmotePicker: Bool = true
    @Previewable @State var selectedEmote: String? = "🦧"
    EmoteSelectionView(showEmotePicker: $showEmotePicker, selectedEmote: $selectedEmote, onSelectEmote:{_ in })
}
