//
//  EmoteSelectionView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 18/08/2025.
//

import SwiftUI

struct EmoteSelectionView: View {
    let showEmotePicker: Bool
    @Binding var selectedEmote: String
    
    
    let onSelectEmote: (String) -> Void
    
    var body: some View {
        let emotes = ["❤️","🙌","🤗","😤","😢","🦧","+"]
        let middleIndex = emotes.count / 2
        HStack(spacing: 0){
            ForEach(emotes.indices, id: \.self) { index in
                let emote = emotes[index]
                Button(action: {
                    if selectedEmote == emote {
                        onSelectEmote("")
                    } else {
                        onSelectEmote(emote)
                    }
                }) {
                    Text("\(emote)")
                        .font(.title)
                        .scaledToFit()
                        .shadow(color: .white, radius: selectedEmote == emote ? 6 : 0)
                        .shadow(color: .white, radius: selectedEmote == emote ? 3 : 0)
                        .shadow(color: .white, radius: selectedEmote == emote ? 1 : 0)
                }
                .frame(width: showEmotePicker ? 40 : 0, height: showEmotePicker ? 40: 0)
                .offset(
                    x: showEmotePicker
                        ? 0
                        : CGFloat(index - middleIndex) * -10 // collapse to center
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showEmotePicker)
                
            }
        }
        .padding(4)
        .background(
            Color(red: 0.84, green: 0.80, blue: 0.76),
            in: Capsule()
        )
        .clipShape(Capsule())
        .opacity(showEmotePicker ? 1 : 0)
        .shadow(radius: 8)
        .zIndex(6)
    }
}

#Preview {
    @Previewable @State var selectedEmote: String = "🦧"
    @Previewable @State var showEmotePicker: Bool = true
    Button("Toggle") {
        withAnimation {
            showEmotePicker.toggle()
        }
    }
    EmoteSelectionView(showEmotePicker: showEmotePicker, selectedEmote: $selectedEmote, onSelectEmote:{_ in })
}
