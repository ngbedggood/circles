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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                .zIndex(-1)

            VStack(spacing: 24) {

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
                    Text(viewModel.formattedDate())
                    Spacer()
                    Button {
                    } label: {
                    }
                    .frame(minWidth: 48)
                }
                .frame(width: 310)
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .zIndex(5)
                .foregroundColor(.black.opacity(0.75))
                
                    VStack {
                        HStack() {
                            TextField("Search Username", text: $viewModel.searchQuery)
                            //.frame(height: 48)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .font(.body)
                                .padding(18)
                            //.background(.white)
                            
                            Button(action: {
                                viewModel.searchUsers()
                            }) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                            }
                        }
                        if !viewModel.searchResults.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(viewModel.searchResults) { user in
                                    HStack {
                                        Text(user.displayName)
                                            .foregroundColor(.black)
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Button("Add") {
                                            viewModel.sendRequest(to: user)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .foregroundColor(.white)
                                        .background(Color.teal)
                                        .clipShape(Capsule())
                                        .font(.callout)
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                            .padding(.bottom, 12)
                            .transition(.scale)
                            .animation(.easeInOut, value: viewModel.searchResults)
                        }
                        
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                

                    VStack {
                        HStack() {
                            Text("Pending Requests")
                                .foregroundColor(.gray)
                                .font(.body)
                                .padding(18)
                            Spacer()
                            if viewModel.isLoadingPendingRequests {
                                Image(systemName: "hourglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                            }
                        }
                        if !viewModel.isLoadingPendingRequests {
                            if !viewModel.pendingRequestsWithUsers.isEmpty {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.pendingRequestsWithUsers) { item in
                                        HStack {
                                            Text(item.user.username)
                                                .foregroundColor(.black)
                                                .font(.body)
                                            
                                            Spacer()
                                            
                                            Button("Accept") {
                                                viewModel.acceptRequest(item.request)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .foregroundColor(.white)
                                            .background(Color.teal)
                                            .clipShape(Capsule())
                                            .font(.callout)
                                        }
                                        .padding(.horizontal, 14)
                                    }
                                }
                                .padding(.bottom, 12)
                                .background(Color.white)
                                .cornerRadius(30)
                                //.padding(.horizontal)
                                .transition(.scale)
                                .animation(.easeInOut, value: viewModel.isLoadingPendingRequests)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)

                    VStack {
                        HStack() {
                            Text("Friends List")
                                .foregroundColor(.gray)
                                .font(.body)
                                .padding(18)
                            Spacer()
                            if viewModel.isLoadingFriendsList {
                                Image(systemName: "hourglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .scaleEffect(viewModel.isLoadingFriendsList ? 1 : 0)
                                    .animation(.easeInOut, value: viewModel.isLoadingFriendsList)
                            }
                        }
                            if !viewModel.isLoadingFriendsList {
                                if !viewModel.friendsList.isEmpty {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.friendsList) { item in
                                            HStack {
                                                Text(item.name)
                                                    .foregroundColor(.black)
                                                    .font(.body)
                                                
                                                Spacer()
                                                
                                                Button("Profile?") {
                                                    
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .foregroundColor(.white)
                                                .background(Color.teal)
                                                .clipShape(Capsule())
                                                .font(.callout)
                                            }
                                            .padding(.horizontal, 14)
                                        }
                                    }
                                    .padding(.bottom, 12)
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    //.padding(.horizontal)
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: viewModel.friendsList)
                                }
                            }
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.bottom, 16)
                    .shadow(radius: 4)
    
                Spacer()
            }
            .frame(width: 310)
            .task {
                viewModel.fetchFriendRequests()
                viewModel.fetchFriendList()
            }
            .onChange(of: showFriends) {
                if showFriends {
                    viewModel.fetchFriendRequests()
                    viewModel.fetchFriendList()
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var viewModel: FriendsViewModel = FriendsViewModel(
            firestoreManager: FirestoreManager(),
            authManager: AuthManager(),
            date: Date()
        )

        @State var showFriends: Bool = true

        var body: some View {
            FriendsView(
                viewModel: viewModel,
                showFriends: $showFriends
            )
        }
    }

    return PreviewWrapper()
}
