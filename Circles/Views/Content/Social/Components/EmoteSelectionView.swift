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
                    if emote == "+" {
                        print("Additional emote selecting is WIP!")
                    } else {
                        if selectedEmote == emote {
                            onSelectEmote("")
                        } else {
                            onSelectEmote(emote)
                        }
                    }
                }) {
                    Text("\(emote)")
                        .font(.title)
                        .scaledToFit()
                        .scaleEffect(selectedEmote == emote ? 1.3 : 0.95)
//                        .shadow(color: .black, radius: selectedEmote == emote ? 6 : 0)
//                        .shadow(color: .black, radius: selectedEmote == emote ? 3 : 0)
//                        .shadow(color: .black, radius: selectedEmote == emote ? 1 : 0)
                }
                .frame(width: showEmotePicker ? 40 : 1, height: showEmotePicker ? 40: 1)
                .offset(
                    x: showEmotePicker
                        ? 0
                        : CGFloat(index - middleIndex) * -10 // collapse to center
                )
                .foregroundColor(.black)
                
            }
        }
        .padding(4)
        .background(
            Capsule()
                .strokeBorder(
                    .fakeBlack,
                    style: StrokeStyle(lineWidth: 2)
                    // [dash length, gap length]
                )
        )
        .clipShape(Capsule())
        .opacity(showEmotePicker ? 1 : 0)
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
