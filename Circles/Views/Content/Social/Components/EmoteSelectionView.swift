//
//  EmoteSelectionView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 18/08/2025.
//

import SwiftUI
import UIKit

private let defaultEmotes = ["❤️","🙌","🤗","😤","😢","🦧","➕"]

struct EmoteSelectionView: View {
    let showEmotePicker: Bool
    @Binding var selectedEmote: String
    
    let onSelectEmote: (String) -> Void
    
    // persisted storage (Data blob in UserDefaults via AppStorage)
    @AppStorage("savedEmotes") private var savedEmotesData: Data = Data()
    @State private var emotes: [String] = []
    
    @State private var showEmojiKeyboard = false
    @State private var emojiInput: String = ""
    
    var body: some View {
        
        let middleIndex = emotes.count / 2
        
        HStack(spacing: 0){
            ForEach(emotes.indices, id: \.self) { index in
                let emote = emotes[index]
                Button(action: {
                    if emote == "➕" {
                        showEmojiKeyboard = true
                    } else {
                        if selectedEmote == emote {
                            onSelectEmote("")
                        } else {
                            onSelectEmote(emote)
                        }
                    }
                }) {
                    Text(emote)
                        .font(.title)
                        .foregroundColor(.fakeBlack)
                        .scaledToFit()
                        .scaleEffect(selectedEmote == emote ? 1.3 : 0.95)
                }
                .frame(width: 40, height: 40) // stable layout
               
//               .offset(
//                    x: showEmotePicker
//                        ? 0
//                        : CGFloat(index - middleIndex) * -10 // collapse to center
//                )
                
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
        .opacity(showEmotePicker ? 1 : 0)
        .scaleEffect(showEmotePicker ? 1 : 0.2)
        .animation(.spring(), value: showEmotePicker)
        .clipShape(Capsule())
        //.opacity(showEmotePicker ? 1 : 0)
        .zIndex(6)
        // Hidden textfield that triggers the emoji keyboard
        .overlay(
            EmojiTextField(text: $emojiInput, isFirstResponder: $showEmojiKeyboard)
                .frame(width: 0, height: 0)
                .opacity(0)
        )
        .onChange(of: emojiInput) { newValue in
            guard let lastChar = newValue.last else { return }
            DispatchQueue.main.async {
                insertEmote(String(lastChar))
                emojiInput = "" // reset so next emoji is captured
                showEmojiKeyboard = false // dismiss keyboard
            }
        }
        .onAppear {
            loadEmotesFromStorage()
        }
    }
    
    private func insertEmote(_ new: String) {
        if let plusIndex = emotes.firstIndex(of: "➕") {
            emotes.insert(new, at: 0)
            if emotes.count > 6 {
                emotes.remove(at: plusIndex)
            }
            saveEmotesToStorage()
        }
    }
    
    private func saveEmotesToStorage() {
        if let encoded = try? JSONEncoder().encode(emotes) {
            savedEmotesData = encoded
        }
    }
    
    // load from savedEmotesData (AppStorage)
        private func loadEmotesFromStorage() {
            if savedEmotesData.count > 0 {
                if let decoded = try? JSONDecoder().decode([String].self, from: savedEmotesData) {
                    emotes = decoded
                    return
                }
            }
            // fallback to defaults
            emotes = defaultEmotes
            saveEmotesToStorage()
        }
}

class UIEmojiTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = true
        tintColor = .clear // no cursor
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // prevent recursion
                return mode
            }
        }
        return nil
    }
}

// MARK: - SwiftUI wrapper
struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool

    func makeUIView(context: Context) -> UIEmojiTextField {
        let textField = UIEmojiTextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }

    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        if isFirstResponder && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            if !string.isEmpty {
                text = string
            }
            return false
        }
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
