//
//  NoteView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 07/08/2025.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject var scrollManager: ScrollManager
    @ObservedObject var viewModel: DayPageViewModel
    @FocusState.Binding var isFocused: Bool
    let screenWidth: CGFloat
    let screenScale: CGFloat
    var body: some View {
        TextField(
            "What makes you feel that way today?", text: $viewModel.note,
            axis: .vertical
        )
        .font(.satoshi(size: 17*screenScale))
        .foregroundColor(.black)
        .padding(16)
        .background(.white)
        .cornerRadius(30)
        .shadow(radius: 4)
        .opacity(viewModel.isMoodSelectionVisible ? 0.0 : 1.0)
        .zIndex(viewModel.isMoodSelectionVisible ? 0.0 : 1.0)
        .frame(maxWidth: screenWidth)
        .padding()
        .focused($isFocused)
        .onSubmit {
            isFocused = false
        }
        .offset(y: isFocused ? -90 : 0)
        .animation(.easeInOut, value: isFocused)
        .animation(.easeInOut, value: viewModel.isMoodSelectionVisible)
        .onChange(of: isFocused) { _, focused in
            scrollManager.isHorizontalScrollDisabled = focused
            viewModel.isDayVerticalScrollDisabled = focused
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused
    NoteView(
        viewModel: DayPageViewModel(
            date: Date(),
            authManager: AuthManager() as (any AuthManagerProtocol),
            firestoreManager: FirestoreManager(),
            scrollManager: ScrollManager(),
            isEditable: true
        ),
        isFocused: $isFocused,
        screenWidth: 690,
        screenScale: 1.0
        
    )
}
