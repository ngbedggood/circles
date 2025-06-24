//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {
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
                    .offset(y: -200) //hacky fix for now
                
                Spacer()
                
                ZStack {
                    if card.color == nil || card.color == .red {
                        Circle()
                            .fill(Color.red)
                            .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                            .zIndex(isFront[4] ? 1 : 0)
                            .scaleEffect(card.color == .red ? 20 : 1)
                            .offset(x: 0, y: expanded ? 240 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[4])
                            .onTapGesture {
                                card.color = .red
                                isFront[4] = true
                            }
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
                    }
                    if card.color == nil || card.color == .blue {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                            .zIndex(isFront[0] ? 1 : 0)
                            .scaleEffect(card.color == .blue ? 20 : 1)
                            .offset(x: 0, y: expanded ? -240 : 0)
                            .animation(.easeInOut, value: expanded)
                            .animation(.easeInOut, value: isFront[0])
                            .onTapGesture {
                                card.color = .blue
                                isFront[0] = true
                            }
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
                    }
                Spacer()
                ZStack {
                    Text("Select your mood before seeing your friends below")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .opacity(card.color == .none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: card.color)
                    Image(systemName: "arrowshape.down.fill")
                        .foregroundStyle(.white)
                        .opacity(card.color != .none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: card.color)
                }
                .offset(y:200)
                
            }
            .padding(40)
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var card = PersonalCard(date: "24th June 2025", color: nil)
        @State private var verticalIndex = 0

            var body: some View {
                PersonalCardView(isPreview: true, card: $card, verticalIndex: $verticalIndex)
            }
        }

        return PreviewWrapper()
}
