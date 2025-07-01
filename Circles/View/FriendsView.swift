//
//  FriendsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import SwiftUI

struct FriendsView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @Binding var showFriends: Bool
    
    var isPreview: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.brown.opacity(0.2))
                .zIndex(-1)
            
            VStack {
                
                HStack {
                    Button {
                        showFriends.toggle()
                    } label: {
                        Image(systemName: "face.smiling")

                    }
                    TextField("Search username", text: $viewModel.searchQuery)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(height: 24)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .padding(16)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(4)
                    Button(action: {
                        viewModel.searchUsers()
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 52))
                    }
                    .padding(4)
                }

                List {
                    Section(header: Text("Search Results")) {
                        ForEach(viewModel.searchResults) { user in
                            HStack {
                                Text(user.displayName)
                                Spacer()
                                Button("Add") {
                                    viewModel.sendRequest(to: user)
                                }
                            }
                        }
                    }

                    Section(header: Text("Pending Requests")) {
                        ForEach(viewModel.pendingRequestsWithUsers) { item in
                            HStack {
                                Text(item.user.username)
                                Spacer()
                                Button("Accept") {
                                    viewModel.acceptRequest(item.request)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("My Friends")) {
                    
                    }
                }
            }
            .frame(width: 320)
            .rotationEffect(isPreview ? .zero : .degrees(-90))
            .onAppear {
                viewModel.fetchFriendRequests()
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var viewModel: FriendsViewModel = FriendsViewModel(
            firestoreManager: FirestoreManager(),
            authManager: AuthManager()
        )
        
        @State var showFriends: Bool = true

        var body: some View {
            FriendsView(
                viewModel: viewModel,
                showFriends: $showFriends,
                isPreview: true
            )
        }
    }

    return PreviewWrapper()
}
