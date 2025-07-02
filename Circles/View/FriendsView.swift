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
    let date: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.brown.opacity(0.2))
                .zIndex(-1)
            
            VStack {
                
                HStack {
                    Button {
                        withAnimation {
                            showFriends.toggle()
                        }
                    } label: {
                        Image(systemName: showFriends ? "chevron.compact.down" : "face.smiling")

                    }
                    .frame(minWidth: 48)
                    Spacer()
                    Text(date)
                    Spacer()
                    Button {
                    } label: {
                    }
                    .frame(minWidth: 48)
                }
                .frame(width: 320)
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .zIndex(5)
                .foregroundColor(.black.opacity(0.8))
                HStack {
                    TextField("Search Username", text: $viewModel.searchQuery)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .padding(16)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white, lineWidth: 0)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    Button(action: {
                        viewModel.searchUsers()
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    }
                }

                List {
                    VStack(alignment: .leading) {
                        Text("Search Results")
                            .font(.system(size: 16))
                            .padding(4)
                            .foregroundColor(.gray)
                        ForEach(viewModel.searchResults) { user in
                            HStack {
                                Text(user.displayName)
                                Spacer()
                                Button("Add") {
                                    viewModel.sendRequest(to: user)
                                }
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], 8)
                                .foregroundColor(.white)
                                .buttonStyle(.plain)
                                .background(.teal)
                                .clipShape(Capsule())
                            }
                            .listRowSeparator(.hidden)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Pending Requests")
                            .font(.system(size: 16))
                            .padding(4)
                            .foregroundColor(.gray)
                        ForEach(viewModel.pendingRequestsWithUsers) { item in
                            HStack {
                                Text(item.user.username)
                                Spacer()
                                Button("Accept") {
                                    viewModel.acceptRequest(item.request)
                                }
                                .padding([.top, .bottom], 4)
                                .padding([.leading, .trailing], 8)
                                .foregroundColor(.white)
                                .buttonStyle(.plain)
                                .background(.teal)
                                .clipShape(Capsule())
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Friends List")
                            .font(.system(size: 16))
                            .padding(4)
                            .foregroundColor(.gray)
                        /*ForEach(viewModel.friendsList) { item in
                            HStack {
                                Text(item.user.username)
                            }
                            .listRowSeparator(.hidden)
                        }*/
                    }
                }
                .padding(.top, 4)
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                Spacer()
                    .padding(.top, 8)
            }
            .frame(width: 320)
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
        
        let date: String = "1 Jul 2025"

        var body: some View {
            FriendsView(
                viewModel: viewModel,
                showFriends: $showFriends,
                date: date
            )
        }
    }

    return PreviewWrapper()
}
