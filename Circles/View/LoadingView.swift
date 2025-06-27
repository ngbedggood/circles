//
//  LoadingView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 26/06/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill((Color.brown).opacity(0.2))

            Text("Loading your cirles...")
        }
    }
}

#Preview {
    LoadingView()
}
