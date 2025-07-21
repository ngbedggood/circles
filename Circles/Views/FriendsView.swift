//
//  FriendsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import SwiftUI

struct FriendsView: View {
    @StateObject var viewModel: FriendsViewModel
    @Binding var showFriends: Bool

    @State var expandPendingRequests: Bool = false
    @State var expandFriendsList: Bool = false
    
    @FocusState var isFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Profile")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black.opacity(0.75))
                    HStack {
                        TextField("New Display Name", text: $viewModel.newDisplayName)
                            //.frame(height: 48)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black.opacity(0.75))
                            .font(.body)
                            .padding(18)
                            .focused($isFocused)
                        //.background(.white)s

                        Button(action: {
                            viewModel.updateDisplayName()
                            isFocused = false
                        }) {
                            Text("Update")
                                .font(.system(size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color(red: 0.75, green: 0.75, blue: 0.75))
                                )
                                .padding(.horizontal, 12)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
                }

                Text("Friends")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.top, 16)
                VStack(spacing: 24) {
                    VStack {
                        HStack {
                            TextField("Search Username", text: $viewModel.searchQuery)
                                //.frame(height: 48)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.black.opacity(0.75))
                                .font(.body)
                                .padding(18)
                                .focused($isFocused)
                            //.background(.white)

                            Button(action: {
                                viewModel.searchUsers()
                                isFocused = false
                            }) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                    .padding(.horizontal, 12)
                            }
                        }
                        if !viewModel.searchResults.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(viewModel.searchResults) { user in
                                    HStack {
                                        Text("\(user.displayName) (\(user.username))")
                                            .foregroundColor(.gray)
                                            .font(.body)
                                            .padding(.leading, 4)

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
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(.bottom, 12)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .top),
                                    removal: .move(edge: .top)
                                )
                                .combined(with: .scale)
                            )
                        }

                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)

                    VStack {
                        HStack {
                            Text("Pending Requests")
                                .foregroundColor(.black.opacity(0.75))
                                .font(.body)
                                .padding(18)
                            Spacer()
                            if viewModel.isLoadingPendingRequests {
                                Image(systemName: "hourglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                    .padding(.horizontal, 12)
                            } else {
                                Button(action: {
                                    withAnimation(.snappy) {
                                        expandPendingRequests.toggle()
                                    }
                                }) {
                                    Image(systemName: "arrowshape.down.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                        .padding(.horizontal, 12)
                                        .rotationEffect(.degrees(expandPendingRequests ? 180 : 0))
                                }
                            }
                        }
                        .background(Color.white)
                        .zIndex(2)

                        if expandPendingRequests {
                            ScrollView {
                                VStack(spacing: 12) {
                                    if !viewModel.pendingRequestsWithUsers.isEmpty {
                                        ForEach(viewModel.pendingRequestsWithUsers) { item in
                                            HStack {
                                                Text(item.user.username)
                                                    .foregroundColor(.gray)
                                                    .font(.body)
                                                    .padding(.leading, 4)
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
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                        }
                                    } else {
                                        HStack {
                                            Text("No pending requests")
                                                .foregroundColor(.gray)
                                                .font(.body)
                                                .padding(.leading, 4)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                                .padding(.bottom, 12)
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .top),
                                        removal: .move(edge: .top)
                                    )
                                    .combined(with: .opacity)
                                )
                                .zIndex(0)
                            }
                            //.frame(maxHeight: 170)
                            .background(Color.white)
                            .cornerRadius(30)
                        }

                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)

                    VStack {
                        HStack {
                            Text("Friends List")
                                .foregroundColor(.black.opacity(0.75))
                                .font(.body)
                                .padding(18)
                            Spacer()
                            if viewModel.isLoadingFriendsList {
                                Image(systemName: "hourglass.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                    .padding(.horizontal, 12)
                            } else {
                                Button(action: {
                                    withAnimation(.snappy) {
                                        expandFriendsList.toggle()
                                    }
                                }) {
                                    Image(systemName: "arrowshape.down.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                                        .padding(.horizontal, 12)
                                        .rotationEffect(.degrees(expandFriendsList ? 180 : 0))
                                }
                            }
                        }
                        .background(Color.white)
                        .zIndex(2)
                        if expandFriendsList {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.friendsList) { item in
                                        HStack {
                                            Text("\(item.name) (\(item.username))")
                                                .foregroundColor(.gray)
                                                .font(.body)
                                                .padding(.leading, 4)

                                            Spacer()
                                            
                                            Button(action: {
                                                viewModel.deleteFriend(item.username)
                                                //viewModel.fetchFriendList()
                                            }) {
                                                Image(systemName: "xmark.bin.circle.fill")
                                                    //.padding(.horizontal, 12)
                                                    //.padding(.vertical, 6)
                                                    .foregroundColor(.red)
                                                    //.background(Color.teal)
                                                    .font(.system(size: 32))
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                                .padding(.bottom, 12)
                                .transition(
                                    .asymmetric(
                                        insertion: .move(edge: .top),
                                        removal: .move(edge: .top)
                                    )
                                    .combined(with: .opacity)
                                )
                                .zIndex(0)
                            }
                            //.frame(minHeight: 100)
                            .background(Color.white)
                            .cornerRadius(30)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.bottom, 16)
                    .shadow(radius: 4)
                }

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
        .toast(
            isShown: $viewModel.showToast,
            type: viewModel.toastStyle,
            title: "Success",
            message: viewModel.toastMessage
        )
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
                showFriends: $showFriends
            )
        }
    }

    return PreviewWrapper()
}
