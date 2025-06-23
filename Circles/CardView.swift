//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct CardView: View {
    @Binding var card: CardData

    let colors: [Color] = [.blue, .green, .yellow, .orange, .red]
    @State private var expandedCircleIndex: Int? = nil
    @State private var isVisible = true
    @State private var isFront = Array(repeating: false, count: 5)
    @State private var tapped: Bool = false
    @State private var selected: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
            
            VStack {
                Text(card.date)
                    .font(.title)
                    .fontWeight(.bold)
                    .zIndex(1)
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 100, height: 100)
                        .zIndex(isFront[4] ? 1 : 0)
                        .scaleEffect(expandedCircleIndex == 4 ? 20 : 1)
                        .offset(x: 0, y: tapped ? 240 : 0)
                        .animation(.easeInOut, value: tapped)
                        .onTapGesture {
                            expandedCircleIndex = 4
                            isFront[4] = true
                        }
                   Circle()
                        .fill(Color.orange)
                        .frame(width: 100, height: 100)
                        .zIndex(isFront[3] ? 1 : 0)
                        .scaleEffect(expandedCircleIndex == 3 ? 20 : 1)
                        .offset(x: 0, y: tapped ? 120 : 0)
                        .animation(.easeInOut, value: tapped)
                        .onTapGesture {
                            expandedCircleIndex = 3
                            isFront[3] = true
                        }
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 100, height: 100)
                        .zIndex(isFront[2] ? 1 : 0)
                        .scaleEffect(expandedCircleIndex == 2 ? 20 : 1)
                        .onTapGesture {
                            expandedCircleIndex = 2
                            isFront[2] = true
                        }
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                        .zIndex(isFront[1] ? 1 : 0)
                        .scaleEffect(expandedCircleIndex == 1 ? 20 : 1)
                        .offset(x: 0, y: tapped ? -120 : 0)
                        .animation(.easeInOut, value: tapped)
                        .onTapGesture {
                            expandedCircleIndex = 1
                            isFront[1] = true
                        }
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                        .zIndex(isFront[0] ? 1 : 0)
                        .scaleEffect(expandedCircleIndex == 0 ? 20 : 1)
                        .offset(x: 0, y: tapped ? -240 : 0)
                        .animation(.easeInOut, value: tapped)
                        .onTapGesture {
                            expandedCircleIndex = 0
                            isFront[0] = true
                        }
                    if isVisible {
                        Circle()
                            .fill(Color.brown.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut, value: tapped)
                            .onTapGesture {
                                tapped = true
                                withAnimation {
                                    isVisible = false
                                }
                            }
                    }
                }
                Spacer()
            }
            .padding(40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    struct PreviewWrapper: View {
            @State private var card = CardData(date: "24th June 2025", completed: false)

            var body: some View {
                CardView(card: $card)
            }
        }

        return PreviewWrapper()
}
