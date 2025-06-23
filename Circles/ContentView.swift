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
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.width < -threshold {
                    dayOffset += 1
                } else if value.translation.width > threshold {
                    dayOffset -= 1
                }
            }

        let displayDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!

        CardView(date: displayDate)
            .offset(x: dragOffset)
            .animation(.easeOut, value: dragOffset)
            .gesture(dragGesture)
            .frame(height: 740)
            .padding(40)
        
    }
}

#Preview {
    ContentView()
}
