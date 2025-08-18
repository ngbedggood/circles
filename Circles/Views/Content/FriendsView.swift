//
//  FriendsView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 29/06/2025.
//

import SwiftUI

struct FriendsView: View {
    @StateObject var viewModel: FriendsViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @State var expandPendingRequests: Bool = false
    @State var expandFriendsList: Bool = false

    @FocusState var isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.92, green: 0.88, blue: 0.84))
                .shadow(radius: 8)
                .onTapGesture {
                    if isFocused {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                            for: nil)
                    }
                }
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                ZStack {
                    VStack {
                        HStack {
                            Button {
                                withAnimation {
                                    viewModel.updateReminderNotification()
                                    navigationManager.currentView = .dayPage
                                }
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 32))
                            }
                            .frame(minWidth: 48)
                            .accessibilityIdentifier("showFriendsToggleButtonIdentifier")
                            Spacer()
                            Text("(\(UserDefaults.standard.string(forKey: "Username") ?? "No Username"))")
                                .font(.satoshi(.caption, weight: .regular))
                            Button {

                            } label: {
                                Text("Sign\nOut")
                                    .font(.satoshi(.caption, weight: .bold))
                                    .onTapGesture {
                                        Task {
                                            await viewModel.signOut()
                                            navigationManager.currentView = .dayPage
                                        }
                                    }
                                    .accessibilityIdentifier("signOutDateIdentifier")
                            }
                            .frame(minWidth: 48)
                        }
                        .font(.satoshi(.body, weight: .regular))
                        .zIndex(5)
                        .foregroundColor(
                            .black.opacity(0.75))
                        VStack {
                            Text("Profile")
                                .font(.satoshi(.title, weight: 700))
                                .foregroundColor(.black.opacity(0.75))
                            HStack {
                                TextField("New Display Name", text: $viewModel.newDisplayName)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.black.opacity(0.75))
                                    .padding(18)
                                    .focused($isFocused)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        Task {
                                            await viewModel.updateDisplayName()
                                        }
                                    }

                                Button(action: {
                                    Task {
                                        await viewModel.updateDisplayName()
                                    }
                                    isFocused = false
                                }) {
                                    Text("Update")
                                        .font(.satoshi(.caption, weight: 900))
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
                            
                            ReminderView(
                                selectedTime: $viewModel.selectedTime,
                                isReminderOn: $viewModel.isReminderOn
                            )
                                .padding(.top, 8)
                        }

                        Text("Friends")
                            .font(.satoshi(.title2, weight: 600))
                            .foregroundColor(.black.opacity(0.75))
                            .padding(.top, 16)
                        VStack(spacing: 24) {
                            VStack {
                                HStack {
                                    TextField("Search Username", text: $viewModel.searchQuery)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black.opacity(0.75))
                                        .padding(18)
                                        .focused($isFocused)
                                        .submitLabel(.search)
                                        .onSubmit {
                                            Task {
                                                await viewModel.searchUsers()
                                            }
                                        }
                                    //.background(.white)

                                    Button(action: {
                                        Task {
                                            isFocused = false
                                            await viewModel.searchUsers()
                                        }
                                    }) {
                                        Image(systemName: "magnifyingglass.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(
                                                Color(red: 0.75, green: 0.75, blue: 0.75)
                                            )
                                            .padding(.horizontal, 12)
                                    }
                                }
                                if !viewModel.searchResults.isEmpty {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.searchResults) { user in
                                            HStack {
                                                Text(
                                                    "\(user.user.displayName) (\(user.user.username))"
                                                )
                                                .foregroundColor(.gray)
                                                .padding(.leading, 4)
                                                .offset(y: -4)

                                                Spacer()
                                                Button(user.requestSent ? "Sent" : "Add") {
                                                    Task {
                                                        await viewModel.sendRequest(to: user.user)
                                                    }
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .foregroundColor(.white)
                                                .background(
                                                    user.requestSent ? Color.gray : Color.teal
                                                )
                                                .clipShape(Capsule())
                                                .disabled(user.requestSent == true)
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
                                } else if viewModel.hasSearched {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("No users found.")
                                                .foregroundColor(.gray)
                                                .padding(.leading, 4)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                    }
                                    .padding(.bottom, 12)
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .top),
                                            removal: .move(edge: .top)
                                        )
                                        .combined(with: .opacity)
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
                                        .padding(18)
                                    Spacer()
                                    if viewModel.isLoadingPendingRequests {
                                        Image(systemName: "hourglass.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(
                                                Color(red: 0.75, green: 0.75, blue: 0.75)
                                            )
                                            .padding(.horizontal, 12)
                                    } else {
                                        ZStack {
                                            Button(action: {
                                                withAnimation(.snappy) {
                                                    expandPendingRequests.toggle()
                                                }
                                            }) {
                                                Image(systemName: "arrowshape.down.circle.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(
                                                        Color(red: 0.75, green: 0.75, blue: 0.75)
                                                    )
                                                    .padding(.horizontal, 12)
                                                    .rotationEffect(
                                                        .degrees(expandPendingRequests ? 180 : 0)
                                                    )

                                            }
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 15, height: 15)
                                                .overlay(
                                                    Text(
                                                        viewModel.pendingRequestsWithUsers.count > 9
                                                            ? "9+"
                                                            : "\(viewModel.pendingRequestsWithUsers.count)"
                                                    )
                                                    .font(.satoshi(size: 8, weight: .bold))
                                                    .foregroundColor(.white)
                                                )
                                                .offset(x: -15, y: -15)
                                                .opacity(viewModel.pendingRequestsWithUsers.isEmpty ? 0 : 1)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .zIndex(2)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        expandPendingRequests.toggle()
                                    }
                                }

                                if expandPendingRequests {
                                    ScrollView {
                                        VStack(spacing: 12) {
                                            if !viewModel.pendingRequestsWithUsers.isEmpty {
                                                ForEach(viewModel.pendingRequestsWithUsers) {
                                                    item in
                                                    HStack {
                                                        Text(item.user.username)
                                                            .foregroundColor(.gray)
                                                            .padding(.leading, 4)
                                                        Spacer()

                                                        Button("Accept") {
                                                            Task {
                                                                await viewModel.acceptRequest(
                                                                    item.request)
                                                            }
                                                        }
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .foregroundColor(.white)
                                                        .background(Color.teal)
                                                        .clipShape(Capsule())
                                                        .font(.callout)
                                                    }
                                                    .padding(.horizontal, 14)
                                                    .transition(
                                                        .opacity.combined(with: .move(edge: .top)))
                                                }
                                            } else {
                                                HStack {
                                                    Text("No pending requests")
                                                        .foregroundColor(.gray)
                                                        .padding(.leading, 4)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 14)
                                                .transition(
                                                    .opacity.combined(with: .move(edge: .top)))
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
                                    .background(Color.white)
                                }

                            }
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(radius: 4)

                            VStack {
                                HStack {
                                    Text("Friends List")
                                        .foregroundColor(.black.opacity(0.75))
                                        .padding(18)
                                    Spacer()
                                    if viewModel.isLoadingFriendsList {
                                        Image(systemName: "hourglass.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(
                                                Color(red: 0.75, green: 0.75, blue: 0.75)
                                            )
                                            .padding(.horizontal, 12)
                                    } else {
                                        Button(action: {
                                            withAnimation(.snappy) {
                                                expandFriendsList.toggle()
                                            }
                                        }) {
                                            Image(systemName: "arrowshape.down.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(
                                                    Color(red: 0.75, green: 0.75, blue: 0.75)
                                                )
                                                .padding(.horizontal, 12)
                                                .rotationEffect(
                                                    .degrees(expandFriendsList ? 180 : 0))
                                        }
                                    }
                                }
                                .background(Color.white)
                                .zIndex(2)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        expandFriendsList.toggle()
                                    }
                                }
                                if expandFriendsList {
                                    ScrollView {
                                        VStack(spacing: 12) {
                                            ForEach(viewModel.friendsList) { item in
                                                HStack {
                                                    Text("\(item.name) (\(item.username))")
                                                        .foregroundColor(.gray)
                                                        .padding(.leading, 4)

                                                    Spacer()

                                                    Button(action: {
                                                        Task {
                                                            await viewModel.deleteFriend(item.username)
                                                        }
                                                    }) {
                                                        Image(systemName: "xmark.bin.circle.fill")
                                                            .foregroundColor(.red)
                                                            .font(.system(size: 32))
                                                    }
                                                }
                                                .padding(.horizontal, 12)
                                                .transition(
                                                    .opacity.combined(with: .move(edge: .top)))
                                            }
                                            HStack(alignment: .center) {
                                                Text("\(viewModel.friendsList.count)/8")
                                                    .foregroundColor(.gray)
                                                    .font(.satoshi(.caption))
                                                    .padding(.leading, 4)
                                            }
                                            .padding(.horizontal, 12)
                                            .transition(
                                                .opacity.combined(with: .move(edge: .top)))
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
                                    .background(Color.white)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(30)
                            //.padding(.bottom, 16)
                            .shadow(radius: 4)
                        }

                    }
                    .frame(maxWidth: screenWidth)
                    .padding()
                    .task {
                        Task {
                            await viewModel.fetchFriendRequests()
                            await viewModel.fetchFriendList()
                        }
                    }
                }
            }
        }
        .padding(24)
        .toast(
            isShown: $viewModel.showToast,
            type: viewModel.toastStyle,
            title: "Success",
            message: viewModel.toastMessage
        )
        .alert(
            "Looks like you've got a friend!",
            isPresented: $viewModel.showNotificationsRequestPrompt
        ) {
            Button("Allow") {
                UserDefaults.standard.set(true, forKey: "hasPromptedForPush")
                Task {
                    await viewModel.requestNotifications()
                }
            }
            Button("No Thanks", role: .cancel) {
                UserDefaults.standard.set(true, forKey: "hasPromptedForPush")
            }
        } message: {
            Text("Would you like to know when your friends post a mood?")
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var viewModel: FriendsViewModel = FriendsViewModel(
            firestoreManager: FirestoreManager(),
            authManager: AuthManager(firestoreManager: FirestoreManager()),
            notificationManager: NotificationManager()
        )

        @State var showFriends: Bool = true

        var body: some View {
            FriendsView(
                viewModel: viewModel
            )
        }
    }

    return PreviewWrapper()
}
