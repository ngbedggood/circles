//
//  TabIndicatorView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 23/08/2025.
//

import SwiftUI

struct TabIndicatorView: View {
    let index: Int
    let numTabs: Int
    var body: some View {
        VStack {
            Spacer()
            HStack {
                ForEach (0..<numTabs) { index in
                    Circle()
                        .fill(index == self.index ? Color.black.opacity(1) : Color.clear)
                        .strokeBorder(Color.black.opacity(0.75), lineWidth: 2)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    TabIndicatorView(index: 4, numTabs: 5)
}
