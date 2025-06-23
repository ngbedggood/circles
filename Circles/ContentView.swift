//
//  ContentView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var dayOffset: Int = 0  // Number of days from today
    
    let date = Date()

    //Dummy data
    @State private var cards = [
        CardData(date: "20th June 2025", color: nil),
        CardData(date: "21st June 2025", color: nil),
        CardData(date: "22nd June 2025", color: nil),
        CardData(date: "23rd June 2025", color: nil),
        CardData(date: "24th June 2025", color: nil),
    ]
    
    @State private var selection = 0
    
    var body: some View {
        
        TabView(selection: $selection) {
            ForEach(cards.indices, id: \.self) { index in
                    CardView(card: $cards[index])
                        .frame(height: 740)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
                        .padding(40)
                        .tag(index)
                }
            }
        .tabViewStyle(.page(indexDisplayMode: .never)) //snap pages
        .onAppear {
            selection = cards.count - 1
        }
    }
}

#Preview {
    ContentView()
}
