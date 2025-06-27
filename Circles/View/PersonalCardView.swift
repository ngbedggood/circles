//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {

    @EnvironmentObject var am: AuthManager
    
    private var cardColor: Color {
        // If the user has selected a mood in this session, use that color.
        if let userSelectedMood = currentMood {
            return userSelectedMood.color
        }
        // Otherwise, use the color from the data passed into the view.
        return dailyMood?.mood?.color ?? .brown.opacity(0.2)
    }
    
    private func saveEntry() {
        guard let userId = am.currentUser?.uid else {
            print("Error: User not logged in. Cannot save note.")
            return
        }
        let newNote = note
        Task {
            do {
                try await am.fm.saveDailyMood(
                    date: date,
                    mood: currentMood ?? MoodColor.none,
                    content: newNote.isEmpty == true ? nil : newNote,
                    forUserID: userId
                )
                print("Daily entry forsaved successfully")
            } catch {
                print(
                    "Error saving daily entry: \(error.localizedDescription)"
                )
            }
        }
    }
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: date)
    }

    @FocusState private var isFocused: Bool

    var date: Date
    var dailyMood: DailyMood?
    @State private var expandedCircleIndex: Int? = nil
    @State private var isVisible = true
    @State private var isFront = Array(repeating: false, count: 5)
    @State private var expanded: Bool = false
    @Binding var verticalIndex: Int
    var isPreview: Bool = false
    @State private var currentMood: MoodColor?
    @State private var note: String = ""
    @State private var isMoodSelectionVisible: Bool = true


    init(date: Date, dailyMood: DailyMood?, verticalIndex: Binding<Int>, isPreview: Bool = false) {
        self.date = date
        self.dailyMood = dailyMood
        self._verticalIndex = verticalIndex
        self.isPreview = isPreview

        // Initialize @State properties directly from the passed-in dailyMood
        // If dailyMood is nil, currentMood will be nil, and note will be ""
        _currentMood = State(initialValue: dailyMood?.mood)
        _note = State(initialValue: dailyMood?.noteContent ?? "")

        // Initially show mood selection if there's no mood set
        _isMoodSelectionVisible = State(initialValue: dailyMood?.mood == nil)
        //_setColor = State(initialValue: dailyMood?.mood?.color ?? .brown.opacity(0.2))
        // Reset expanded state if we're starting fresh with no mood
        _expanded = State(initialValue: dailyMood?.mood != nil)  // If mood exists, start "expanded"

    }

    var body: some View {

        //let _ = print("Final dailyMoodForDate: \(dailyMood?.mood?.rawValue ?? "nil")")

        ZStack {

            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor) // USE THE COMPUTED PROPERTY HERE
                .animation(.easeInOut, value: cardColor)

            VStack {
                Text(formattedDate(from: date))
                    .font(.title)
                    .fontWeight(.bold)
                    .zIndex(1)
                    .foregroundColor(currentMood != nil ? .white : .black)
                    .animation(.easeInOut, value: currentMood)
                    .offset(y: -170)  // hacky fix for now
                    .onTapGesture {
                        am.signOut()
                    }

                Spacer()
                ZStack {
                    if isMoodSelectionVisible {
                        ZStack {
                            if currentMood == nil || currentMood == .gray {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                                    .zIndex(isFront[4] ? 1 : 0)
                                    .scaleEffect(currentMood == .gray ? 20 : 1)
                                    .offset(x: 0, y: expanded ? 240 : 0)
                                    .animation(.easeInOut, value: expanded)
                                    .animation(.easeInOut, value: isFront[4])
                                    .onTapGesture {
                                        currentMood = .gray
                                        isFront[4] = true
                                        saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }
                            if currentMood == nil || currentMood == .orange {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: expanded ? 100 : 80, height: expanded ? 100 : 80)
                                    .zIndex(isFront[3] ? 1 : 0)
                                    .scaleEffect(currentMood == .orange ? 20 : 1)
                                    .offset(x: 0, y: expanded ? 110 : 0)
                                    .animation(.easeInOut, value: expanded)
                                    .animation(.easeInOut, value: isFront[3])
                                    .onTapGesture {
                                        currentMood = .orange
                                        isFront[3] = true
                                        saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }
                            if currentMood == nil || currentMood == .yellow {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 80, height: 80)
                                    .zIndex(isFront[2] ? 1 : 0)
                                    .scaleEffect(currentMood == .yellow ? 20 : 1)
                                    .animation(.easeInOut, value: isFront[2])
                                    .onTapGesture {
                                        currentMood = .yellow
                                        isFront[2] = true
                                        saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }
                            if currentMood == nil || currentMood == .green {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: expanded ? 100 : 80, height: expanded ? 100 : 80)
                                    .zIndex(isFront[1] ? 1 : 0)
                                    .scaleEffect(currentMood == .green ? 20 : 1)
                                    .offset(x: 0, y: expanded ? -110 : 0)
                                    .animation(.easeInOut, value: expanded)
                                    .animation(.easeInOut, value: isFront[1])
                                    .onTapGesture {
                                        currentMood = .green
                                        isFront[1] = true
                                        saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }
                            if currentMood == nil || currentMood == .teal {
                                Circle()
                                    .fill(Color.teal)
                                    .frame(width: expanded ? 120 : 80, height: expanded ? 120 : 80)
                                    .zIndex(isFront[0] ? 1 : 0)
                                    .scaleEffect(currentMood == .teal ? 20 : 1)
                                    .offset(x: 0, y: expanded ? -240 : 0)
                                    .animation(.easeInOut, value: expanded)
                                    .animation(.easeInOut, value: isFront[0])
                                    .onTapGesture {
                                        currentMood = .teal
                                        isFront[0] = true
                                        saveEntry()
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            }
                            if currentMood == nil && isVisible == true {
                                Circle()
                                    .fill(Color.brown.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .animation(.easeInOut, value: expanded)
                                    .onTapGesture {
                                        expanded = true
                                        withAnimation {
                                            isVisible = false
                                        }
                                        verticalIndex = 0
                                    }
                            }
                        }

                    }

                    TextField(
                        "What makes you feel that way today?", text: $note, axis: .vertical
                    )
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .padding(16)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(currentMood != nil ? 1.0 : 0.0)
                    .animation(.easeInOut, value: currentMood)
                    .zIndex(currentMood != nil ? 1.0 : 0.0)
                    .frame(width: 310)
                    .focused($isFocused)
                    .onSubmit {
                        isFocused = false
                    }
                    .offset(y: isFocused ? -90 : 0)
                    .animation(.easeInOut, value: isFocused)
                }

                Spacer()

                ZStack {
                    Text("Select today's mood before seeing your friends below")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .opacity(currentMood == MoodColor.none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: currentMood)
                    Image(systemName: "arrowshape.down.fill")
                        .foregroundStyle(.white)
                        .opacity(currentMood != MoodColor.none ? 1.0 : 0.0)
                        .animation(.easeInOut, value: currentMood)
                }
                .offset(y: 170)
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    saveEntry()
                    
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                        for: nil)
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        var date = Calendar.current.startOfDay(for: Date())
        var dailyMood: DailyMood = DailyMood(
            id: "2025-06-24", mood: .teal, noteContent: "This is a test!", createdAt: .now)
        @State private var verticalIndex = 0

        var body: some View {
            PersonalCardView(
                date: date, dailyMood: dailyMood, verticalIndex: $verticalIndex, isPreview: true)
        }
    }

    return PreviewWrapper()
}
