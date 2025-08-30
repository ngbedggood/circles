//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var scrollManager: ScrollManager
    @EnvironmentObject var navigationManager: NavigationManager

    @ObservedObject var viewModel: DayPageViewModel

    @State private var isFront: [Bool] = Array(repeating: false, count: 5)
    @State private var showFriends: Bool = false

    @FocusState private var isFocused: Bool
    
    // Callback to navigate DayPageView with buttons
    var onDown: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let baseWidth: CGFloat = 880
            let screenScale = min(1, screenHeight / baseWidth)
                VStack {
                    ZStack {
                        BackgroundCardView(
                            viewModel: viewModel,
                            isFocused: isFocused
                        )
                        VStack {
                            TopBarView(
                                viewModel: viewModel,
                                isFocused: $isFocused
                            )
                            .onAppear {
                                Task {
                                    await viewModel.checkForAlerts()
                                }
                                
                            }

                            Spacer()

                            ZStack {
                                if viewModel.isEditable {
                                    MoodCirclesView(
                                        viewModel: viewModel,
                                        moodCircles: moodCircles,
                                        screenScale: screenScale,
                                        isFront: $isFront
                                    )
                                    NoteView(
                                        viewModel: viewModel,
                                        isFocused: $isFocused,
                                        screenWidth: screenWidth,
                                        screenScale: screenScale * 1.18
                                    )
                                } else {
                                    Text(viewModel.note.isEmpty ? "No note was left." :"\"\(viewModel.note)\"")
                                        .foregroundColor(viewModel.dailyMood == nil ? .black : .white)
                                        .font(.satoshi(size: 20, weight: .regular))
                                        .multilineTextAlignment(.center)
                                        .padding(24)
                                }
                            }

                            Spacer()
                            
                            
                                ZStack {
                                    if viewModel.currentMood == nil && viewModel.isEditable {
                                        Text("Select today's mood before seeing your friends below")
                                            .font(.satoshi(.caption))
                                            .foregroundStyle(.gray)
                                            .opacity(viewModel.currentMood == nil ? 1.0 : 0.0)
                                    } else {
                                        if viewModel.currentMood == nil {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.fakeBlack)
                                                .font(.system(size: 24))
                                        } else {
                                            Button {
                                                onDown()
                                            } label: {
                                                Image(systemName: "arrowshape.down.fill")
                                                    .foregroundStyle(.backgroundTint)
                                                    .frame(width: 80, height: 80)
                                                    .offset(y:30)
                                            }
                                            
                                        }
                                    }
                                
                                }
                                .animation(.easeInOut, value: viewModel.currentMood)
                                .padding()
                        
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(24)
                    }

                    // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
                    .toolbar {
                        if isFocused {
                            ToolbarItem(placement: .keyboard) {
                                Button("Done") {
                                    Task {
                                        await viewModel.saveEntry(isButtonSubmit: true)
                                    }
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                        for: nil)
                                }
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State static var previewMood: DailyMood? = DailyMood(
            id: "2025-07-01",
            mood: .green,
            noteContent: "Feeling good!",
            createdAt: Date()
        )

        var viewModel: DayPageViewModel = DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()),
            firestoreManager: FirestoreManager(),
            streakManager: StreakManager(
                authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
                firestoreManager: FirestoreManager()),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        )

        var disableScroll: Bool = false

        var body: some View {
            PersonalCardView(
                viewModel: viewModel,
                onDown: {}
            )
        }
    }

    return PreviewWrapper()
}
