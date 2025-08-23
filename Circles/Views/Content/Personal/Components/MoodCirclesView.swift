//
//  MoodCirclesView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 07/08/2025.
//

import SwiftUI

struct MoodCirclesView: View {
    @ObservedObject var viewModel: DayPageViewModel
    var moodCircles: [MoodCircle]
    var screenScale: CGFloat
    @Binding var isFront: [Bool]
    var body: some View {
        ZStack {
            ForEach(moodCircles, id: \.color) { mood in
                let width =
                    (viewModel.expanded
                        ? mood.expandedSize : mood.defaultSize) * screenScale
                let height =
                    (viewModel.expanded
                        ? mood.expandedSize : mood.defaultSize) * screenScale
                let offsetY =
                    (viewModel.expanded ? mood.offsetY : 0) * screenScale
                Circle()
                    .fill(mood.color.color)
                    .frame(width: width, height: height)
                    .scaleEffect(viewModel.currentMood == mood.color ? 16 : 1)
                    .animation(
                        .easeInOut.speed(0.8), value: viewModel.currentMood
                    )
                    .offset(x: 0, y: offsetY)
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
                        Task {
                            await viewModel.saveEntry(isButtonSubmit: false)
                        }
                    }
                    .shadow(
                        color: viewModel.expanded && viewModel.currentMood == mood.color ? .black.opacity(0.33) : .black.opacity(0.1),
                        radius: viewModel.currentMood == nil ? 4 : 8
                    )
            }

            if viewModel.currentMood == nil && viewModel.isVisible {
                Circle()
                    .fill(Color.brown.opacity(0.001))
                    .frame(width: 80 * screenScale, height: 80 * screenScale)
                    .zIndex(viewModel.isMoodSelectionVisible ? 10 : 0)
                    .onTapGesture {
                        viewModel.isVisible = false
                        viewModel.expanded = true
                    }
            }
        }
        .opacity(viewModel.isMoodSelectionVisible ? 1.0 : 0.0)
        .animation(.easeInOut, value: viewModel.isMoodSelectionVisible)
    }
}

#Preview {
    @Previewable @State var isFront: [Bool] = Array(repeating: false, count: 5)
    MoodCirclesView(
        viewModel: DayPageViewModel(
            date: Date(),
            authManager: AuthManager(firestoreManager: FirestoreManager()) as (any AuthManagerProtocol),
            firestoreManager: FirestoreManager(),
            notificationManager: NotificationManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        ),
        moodCircles: [],
        screenScale: 1,
        isFront: $isFront
    )
}
