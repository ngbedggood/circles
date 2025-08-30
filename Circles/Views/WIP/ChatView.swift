//
//  ChatView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 13/07/2025.
//

import SwiftUI

struct ChatView: View {
    
    @State private var showFriends: Bool = false
    
    var body: some View {
        ZStack {

            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(red: 0.92, green: 0.88, blue: 0.84)
                )
                .zIndex(-1)
                .shadow(radius: 8)

            VStack {
                HStack {
                    Button {
                        withAnimation {
                        }
                    } label: {
                        Image(systemName: showFriends ? "xmark.circle" : "face.smiling")

                    }
                    .frame(minWidth: 48)
                    .accessibilityIdentifier("showFriendsToggleButtonIdentifier")
                    Spacer()
                    Text("1 Jul 2025")
                        .font(.satoshi(.title))
                        .onTapGesture {
                        }
                        .accessibilityIdentifier("signOutDateIdentifier")
                    Spacer()
                    Button {

                    } label: {
                        Image(systemName: "trash.circle")
                            .foregroundColor(.fakeBlack)
                    }
                    .frame(minWidth: 48)
                }
                .frame(width: 310)
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .zIndex(5)
                .foregroundColor(.fakeBlack)

                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {

                        Text("abcdefghijklmnopqrstuvwxyz")
                            .font(.satoshi(.body, weight: .medium))
                        Text("abcdefghijklmnopqrstuvwxyz")
                        Text("Large Title").font(.largeTitle)
                        Text("Title").font(.title)
                        Text("Title2").font(.title2) // available iOS 14
                        Text("Title3").font(.title3) // available iOS 14

                        Divider()

                        Text("Headline").font(.headline)
                        Text("Subheadline").font(.subheadline)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Body").font(.body)  // --> default font
                        Text("Callout").font(.callout)
                        Text("Footnote").font(.footnote)
                        Text("Caption").font(.caption)
                        Text("Caption2").font(.caption2) // available iOS 14
                    }
                }
                .padding()

                Spacer()
            }
        }
        .padding(24)
        
    }
}

#Preview {
    ChatView()
}
