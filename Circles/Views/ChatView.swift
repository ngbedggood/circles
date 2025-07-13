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
            //.animation(.easeInOut.speed(0.8), value: viewModel.currentMood)

            VStack {
                HStack {
                    Button {
                        withAnimation {
                            showFriends.toggle()
                            //viewModel.scrollDisabled.toggle()
                        }
                    } label: {
                        Image(systemName: showFriends ? "xmark.circle" : "face.smiling")

                    }
                    .frame(minWidth: 48)
                    .accessibilityIdentifier("showFriendsToggleButtonIdentifier")
                    Spacer()
                    Text("1 JUL 2025")
                        .onTapGesture {
                            //viewModel.authManager.signOut()
                        }
                        .accessibilityIdentifier("signOutDateIdentifier")
                    Spacer()
                    Button {

                    } label: {
                        Image(systemName: "trash.circle")
                            .foregroundColor(.black.opacity(0.75))
                    }
                    .frame(minWidth: 48)
                }
                .frame(width: 310)
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .zIndex(5)
                .foregroundColor(.black.opacity(0.75))

                Spacer()

                Text("FRIENDS CHATS")
                    .fontWeight(.bold)

                Spacer()
            }
        }
        .frame(height: 720)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ChatView()
}
