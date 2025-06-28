//
//  CardView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import SwiftUI

struct PersonalCardView: View {

    @EnvironmentObject var am: AuthManager

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
                print("Daily entry for \(date) saved successfully")
            } catch {
                print(
                    "Error saving daily entry: \(error.localizedDescription)"
                )
            }
        }

        //expanded = false
        isMoodSelectionVisible = false
        print("SAVE = isMoodSelectionVisible: \(isMoodSelectionVisible) - expanded: \(expanded) - isVisible: \(isVisible) - currentMood: \(currentMood?.rawValue ?? "none")")
    }
    
    private func deleteEntry() {
        guard let userId = am.currentUser?.uid else {
            print("Error: User not logged in. Cannot delete note.")
            return
        }
        Task {
            do {
                try await am.fm.deleteDailyMood(date: date, forUserId: userId)
                print("Daily entry for \(date) deleted successfully")
            } catch {
                print(
                    "Error deleting daily entry: \(error.localizedDescription)"
                )
            }
        }
        isMoodSelectionVisible = true
        currentMood = nil
        expanded = false
        isVisible = true
        print("DELETE = isMoodSelectionVisible: \(isMoodSelectionVisible) - expanded: \(expanded) - isVisible: \(isVisible) - currentMood: \(currentMood?.rawValue ?? "none")")
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
                .fill(dailyMood?.mood?.color ?? .brown.opacity(0.2))
                .zIndex(-1)
                .animation(.easeInOut.speed(0.8), value: dailyMood?.mood)

            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            
                    }
                    Spacer()
                    Text(formattedDate(from: date))
                        .onTapGesture {
                            am.signOut()
                        }
                    Spacer()
                    Button{
                        deleteEntry()
                    } label: {
                        Image(systemName: "minus.circle")
                            .opacity(currentMood == nil ? 0 : 1)
                    }
                }
                .frame(width: 320)
                .font(.title)
                .fontWeight(.bold)
                .offset(y: -170)  // hacky fix for now
                .zIndex(5)
                .foregroundColor(currentMood == nil ? .black.opacity(0.8) : .white)
                //.animation(.easeInOut, value: currentMood)

                Spacer()
                ZStack {
                    
                        ZStack {
                            ForEach(moodCircles, id: \.color) { mood in
                                    Circle()
                                        .fill(mood.fill)
                                        .frame(width: expanded ? mood.expandedSize : mood.defaultSize,
                                               height: expanded ? mood.expandedSize : mood.defaultSize)
                                        .scaleEffect(currentMood == mood.color ? 16 : 1)
                                        .animation(.easeInOut.speed(0.8), value: currentMood)
                                        .offset(x: 0, y: expanded ? mood.offsetY : 0)
                                        .animation(.spring(
                                            response: 0.55,
                                            dampingFraction: 0.69,
                                            blendDuration: 0
                                        ), value: expanded)
                                        .opacity(isMoodSelectionVisible || currentMood == mood.color ? 1 : 0)
                                        .zIndex(isFront[mood.index] ? 6 : -1)
                                        .onTapGesture {
                                            currentMood = mood.color
                                            isFront = Array(repeating: false, count: isFront.count)
                                            isFront[mood.index] = true // Keep last selected colour at front
                                            expanded = false
                                            saveEntry()
                                        }
                                        .shadow(color: .black.opacity(0.2), radius: 4)
                            }

                            if currentMood == nil && isVisible {
                                Circle()
                                    .fill(Color.brown.opacity(0.001))
                                    .frame(width: 80, height: 80)
                                    .zIndex(isMoodSelectionVisible ? 10 : 0)
                                    .onTapGesture {
                                        isVisible = false
                                        expanded = true
                                        verticalIndex = 0
                                    }
                            }
                        }
                        .opacity(isMoodSelectionVisible ? 1.0 : 0.0)
                        .animation(.easeInOut, value: isMoodSelectionVisible)

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
                    .opacity(isMoodSelectionVisible ? 0.0 : 1.0)
                    .zIndex(isMoodSelectionVisible ? 0.0 : 1.0)
                    .frame(width: 310)
                    .focused($isFocused)
                    .onSubmit {
                        isFocused = false
                    }
                    .offset(y: isFocused ? -90 : 0)
                    .animation(.easeInOut, value: isFocused)
                    .animation(.easeInOut, value: isMoodSelectionVisible)
                }

                Spacer()

                ZStack {
                    Text("Select today's mood before seeing your friends below")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .opacity(currentMood == nil ? 1.0 : 0.0)
                    Image(systemName: "arrowshape.down.fill")
                        .foregroundStyle(.white)
                        .opacity(currentMood != nil ? 1.0 : 0.0)
                }
                .animation(.easeInOut, value: currentMood)
                .offset(y: 170)
            }
            .rotationEffect(isPreview ? .zero : .degrees(-90))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        // Weird way to be able to dismiss keyboard when using axis: .vertical modifier
        .toolbar {
            if isFocused {
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
