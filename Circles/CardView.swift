//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct CardView: View {
    let date: Date
    @State var tapped: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))
                .padding(20)
            VStack {
                Text(date.formatted(date: .abbreviated, time:.omitted))
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 100, height: 100)
                        .offset(x: 0, y: tapped ? 240 : 0)
                        .animation(.easeInOut, value: tapped)
                    
                   Circle()
                        .fill(Color.orange)
                        .frame(width: 100, height: 100)
                        .offset(x: 0, y: tapped ? 120 : 0)
                        .animation(.easeInOut, value: tapped)
                               
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            tapped = false
                        }
                               
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                        .offset(x: 0, y: tapped ? -120 : 0)
                        .animation(.easeInOut, value: tapped)
                               
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                        .offset(x: 0, y: tapped ? -240 : 0)
                        .animation(.easeInOut, value: tapped)
                        .onTapGesture {
                            tapped = true
                    }
                }
                Spacer()
            }
            .padding(40)
        }
    }
}

#Preview {
    CardView(date: Date())
}
