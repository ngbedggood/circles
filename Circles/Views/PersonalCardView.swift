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

    @ObservedObject var viewModel: DayPageViewModel

    @State private var isFront: [Bool] = Array(repeating: false, count: 5)
    @State private var showFriends: Bool = false

    @FocusState private var isFocused: Bool

    let moodCircles: [MoodCircle] = [
        .init(
            color: .gray, fill: .gray, offsetY: 240, expandedSize: 120, defaultSize: 80, index: 4),
        .init(
            color: .orange, fill: .orange, offsetY: 110, expandedSize: 100, defaultSize: 80,
            index: 3),
        .init(
            color: .yellow, fill: .yellow, offsetY: 0, expandedSize: 80, defaultSize: 80, index: 2),
        .init(
            color: .green, fill: .green, offsetY: -110, expandedSize: 100, defaultSize: 80, index: 1
        ),
        .init(
            color: .teal, fill: .teal, offsetY: -240, expandedSize: 120, defaultSize: 80, index: 0),
    ]

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 20)
                .fill(
                    viewModel.showFriends
                        ? Color(red: 0.92, green: 0.88, blue: 0.84)
                        : viewModel.currentMood?.color ?? Color(red: 0.92, green: 0.88, blue: 0.84)
                )
                .zIndex(-1)
                .animation(.easeInOut.speed(0.8), value: viewModel.currentMood)

            VStack {
                HStack {
                    Button {
                        withAnimation {
                            viewModel.toggleFriends()
                        }
                    } label: {
                        Image(systemName: showFriends ? "xmark.circle" : "face.smiling")

                    }
                    .frame(minWidth: 48)
                    .accessibilityIdentifier("showFriendsToggleButtonIdentifier")
                    Spacer()
                    Text(viewModel.formattedDate())
                        .onTapGesture {
                            viewModel.authManager.signOut()
                        }
                        .accessibilityIdentifier("signOutDateIdentifier")
                    Spacer()
                    Button {
                        viewModel.deleteEntry()
                    } label: {
                        if !viewModel.showFriends {
                            Image(systemName: "trash.circle")
                                .opacity(viewModel.currentMood == nil ? 0 : 1)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(minWidth: 48)
                }
                .frame(width: 310)
                .padding()
                .font(.title)
                .fontWeight(.bold)
                .zIndex(5)
                .foregroundColor(
                    viewModel.showFriends
                        ? .black.opacity(0.75)
                        : viewModel.currentMood == nil ? .black.opacity(0.75) : .white)

                Spacer()

                if viewModel.showFriends {
                    FriendsView(
                        viewModel: FriendsViewModel(
                            firestoreManager: firestoreManager,
                            authManager: authManager
                        ),
                        showFriends: $showFriends
                    )
                } else {
                    ZStack {

                        ZStack {
                            ForEach(moodCircles, id: \.color) { mood in
                                Circle()
                                    .fill(mood.fill)
                                    .frame(
                                        width: viewModel.expanded
                                            ? mood.expandedSize : mood.defaultSize,
                                        height: viewModel.expanded
                                            ? mood.expandedSize : mood.defaultSize
                                    )
                                    .scaleEffect(viewModel.currentMood == mood.color ? 16 : 1)
                                    .animation(.easeInOut.speed(0.8), value: viewModel.currentMood)
                                    .offset(x: 0, y: viewModel.expanded ? mood.offsetY : 0)
                                    .animation(
                                        .spring(
                                            response: 0.55,
                                            dampingFraction: 0.69,
                                            blendDuration: 0
                                        ), value: viewModel.expanded
                                    )
                                    .opacity(
                                        viewModel.isMoodSelectionVisible
                                            || viewModel.currentMood == mood.color ? 1 : 0
                                    )
                                    .zIndex(isFront[mood.index] ? 6 : -1)
                                    .onTapGesture {
                                        viewModel.currentMood = mood.color
                                        isFront = Array(
                                            repeating: false, count: isFront.count)
                                        isFront[mood.index] = true  // Keep last selected colour at front
                                        print(
                                            "Mood index is: \(mood.index) and isFront is: \(isFront[mood.index])"
                                        )
                                        viewModel.saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }

                            if viewModel.currentMood == nil && viewModel.isVisible {
                                Circle()
                                    .fill(Color.brown.opacity(0.001))
                                    .frame(width: 80, height: 80)
                                    .zIndex(viewModel.isMoodSelectionVisible ? 10 : 0)
                                    .onTapGesture {
                                        viewModel.isVisible = false
                                        viewModel.expanded = true
                                    }
                            }
                        }
                        .opacity(viewModel.isMoodSelectionVisible ? 1.0 : 0.0)
                        .animation(.easeInOut, value: viewModel.isMoodSelectionVisible)

                        TextField(
                            "What makes you feel that way today?", text: $viewModel.note,
                            axis: .vertical
                        )
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .padding(16)
                        .background(.white)
                        .cornerRadius(30)
                        .shadow(radius: 4)
                        .opacity(viewModel.isMoodSelectionVisible ? 0.0 : 1.0)
                        .zIndex(viewModel.isMoodSelectionVisible ? 0.0 : 1.0)
                        .frame(width: 310)
                        .focused($isFocused)
                        .onSubmit {
                            isFocused = false
                        }
                        .offset(y: isFocused ? -90 : 0)
                        .animation(.easeInOut, value: isFocused)
                        .animation(.easeInOut, value: viewModel.isMoodSelectionVisible)
                    }

                    Spacer()

                    ZStack {
                        Text("Select today's mood before seeing your friends below")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .opacity(viewModel.currentMood == nil ? 1.0 : 0.0)
                        Image(systemName: "arrowshape.down.fill")
                            .foregroundStyle(.white)
                            .opacity(viewModel.currentMood != nil ? 1.0 : 0.0)
                    }
                    .padding()
                    .animation(.easeInOut, value: viewModel.currentMood)
                }
            }
        }
        .frame(height: 720)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
        .toolbar {
            if isFocused {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        viewModel.saveEntry()
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                            for: nil)
                    }
                }
            }
        }
        .task {
            viewModel.setup()
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
            authManager: AuthManager(),
            firestoreManager: FirestoreManager(),
            scrollManager: ScrollManager()
        )

        var disableScroll: Bool = false

        var body: some View {
            PersonalCardView(
                viewModel: viewModel
            )
        }
    }

    return PreviewWrapper()
}
