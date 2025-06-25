//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {

    @EnvironmentObject var am: AuthManager

    private func hideKeyboard() {
        print("Attempting to hide keyboard...")
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @FocusState private var isFocused: Bool

    var isPreview: Bool = false
    @Binding var card: PersonalCard

    @State private var expandedCircleIndex: Int? = nil
    @State private var isVisible = true
    @State private var isFront = Array(repeating: false, count: 5)
    @State private var expanded: Bool = false
    @Binding var verticalIndex: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))

            VStack {
                Text(card.date)
                    .font(.title)
                    .fontWeight(.bold)
                    .zIndex(1)
                    .foregroundColor(card.color == nil ? .black : .white)
                    .animation(.easeInOut, value: card.color)
                    .offset(y: -170)  //hacky fix for now
                    .onTapGesture {
                        am.signOut()
                    }

                Spacer()

                ZStack {
                    if card.color == nil || card.color == .gray {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                            .zIndex(isFront[4] ? 1 : 0)
                            .scaleEffect(card.color == .gray ? 20 : 1)
                            .offset(x: 0, y: expanded ? 240 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[4])
                            .onTapGesture {
                                card.color = .gray
                                isFront[4] = true
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    if card.color == nil || card.color == .orange {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: expanded ? 100 : 80, height: expanded ? 100 : 80)
                            .zIndex(isFront[3] ? 1 : 0)
                            .scaleEffect(card.color == .orange ? 20 : 1)
                            .offset(x: 0, y: expanded ? 110 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[3])
                            .onTapGesture {
                                card.color = .orange
                                isFront[3] = true
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    if card.color == nil || card.color == .yellow {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 80, height: 80)
                            .zIndex(isFront[2] ? 1 : 0)
                            .scaleEffect(card.color == .yellow ? 20 : 1)
                            .animation(.easeInOut, value: isFront[2])
                            .onTapGesture {
                                card.color = .yellow
                                isFront[2] = true
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    if card.color == nil || card.color == .green {
                        Circle()
                            .fill(Color.green)
                            .frame(width: expanded ? 100 : 80, height: expanded ? 100 : 80)
                            .zIndex(isFront[1] ? 1 : 0)
                            .scaleEffect(card.color == .green ? 20 : 1)
                            .offset(x: 0, y: expanded ? -110 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[1])
                            .onTapGesture {
                                card.color = .green
                                isFront[1] = true
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    if card.color == nil || card.color == .teal {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                            .zIndex(isFront[0] ? 1 : 0)
                            .scaleEffect(card.color == .teal ? 20 : 1)
                            .offset(x: 0, y: expanded ? -240 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[0])
                            .onTapGesture {
                                card.color = .teal
                                isFront[0] = true
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4)
                    }
                    if card.color == nil && isVisible == true {
                        Circle()
                            .fill(Color.brown.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .animation(.easeInOut, value: expanded)
                            .onTapGesture {
                                expanded = true
                                withAnimation {
                                    isVisible = false
                                }
                                verticalIndex = 0
                            }
                    }

                    TextField(
                        "What makes you feel that way today?", text: $card.note, axis: .vertical
                    )
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(card.color != .none ? 1.0 : 0.0)
                    .animation(.easeInOut, value: card.color)
                    .zIndex(card.color == .none ? 0 : 1)
                    .frame(width: 310)
                    .focused($isFocused)
                    .onSubmit {
                        print("Done button on keyboard tapped!")
                        isFocused = false
                    }
                    // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                    for: nil)
                            }
                        }
                    }
                    .offset(y: isFocused ? -90 : 0)
                    .animation(.easeInOut, value: isFocused)

                }

                Spacer()

                ZStack {
                    Text("Select today's mood before seeing your friends below")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .opacity(card.color == .none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: card.color)
                    Image(systemName: "arrowshape.down.fill")
                        .foregroundStyle(.white)
                        .opacity(card.color != .none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: card.color)
                }
                .offset(y: 170)
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {  // Still useful for general tap-to-dismiss
            self.hideKeyboard()
        }

    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var card = PersonalCard(
            date: "24th June 2025", color: nil, note: "I'm feelin great!!!")
        @State private var verticalIndex = 0

        var body: some View {
            PersonalCardView(isPreview: true, card: $card, verticalIndex: $verticalIndex)
        }
    }

    return PreviewWrapper()
}
