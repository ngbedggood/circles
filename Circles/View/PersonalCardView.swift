//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {

    @EnvironmentObject var am: AuthManager

    // Computed value
    private var cardColor: Color {
        if let userSelectedMood = currentMood {
            return userSelectedMood.color
        }
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
    
    let moodCircles: [MoodCircle] = [
        .init(color: .gray, fill: .gray, offsetY: 240, expandedSize: 120, defaultSize: 80, index: 4),
        .init(color: .orange, fill: .orange, offsetY: 110, expandedSize: 100, defaultSize: 80, index: 3),
        .init(color: .yellow, fill: .yellow, offsetY: 0, expandedSize: 80, defaultSize: 80, index: 2),
        .init(color: .green, fill: .green, offsetY: -110, expandedSize: 100, defaultSize: 80, index: 1),
        .init(color: .teal, fill: .teal, offsetY: -240, expandedSize: 120, defaultSize: 80, index: 0),
    ]

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

        _currentMood = State(initialValue: dailyMood?.mood)
        _note = State(initialValue: dailyMood?.noteContent ?? "")
        _isMoodSelectionVisible = State(initialValue: dailyMood?.mood == nil)
        _expanded = State(initialValue: dailyMood?.mood != nil)  // If mood exists, start "expanded"

    }

    var body: some View {

        //let _ = print("Final dailyMoodForDate: \(dailyMood?.mood?.rawValue ?? "nil")")

        ZStack {

            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)  // USE THE COMPUTED PROPERTY HERE
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
                            ForEach(moodCircles, id: \.color) { mood in
                                if currentMood == nil || currentMood == mood.color {
                                    Circle()
                                        .fill(mood.fill)
                                        .frame(width: expanded ? mood.expandedSize : mood.defaultSize,
                                               height: expanded ? mood.expandedSize : mood.defaultSize)
                                        .zIndex(isFront[mood.index] ? 1 : 0)
                                        .scaleEffect(currentMood == mood.color ? 20 : 1)
                                        .offset(x: 0, y: expanded ? mood.offsetY : 0)
                                        .animation(.easeInOut, value: expanded)
                                        .animation(.easeInOut, value: isFront[mood.index])
                                        .onTapGesture {
                                            currentMood = mood.color
                                            isFront[mood.index] = true
                                            saveEntry()
                                        }
                                        .shadow(color: .black.opacity(0.2), radius: 4)
                                }
                            }

                            if currentMood == nil && isVisible {
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
