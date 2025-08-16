//
//  ReminderView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 16/08/2025.
//

import SwiftUI

struct ReminderView: View {
    
    @Binding var selectedTime: Date
    @Binding var isReminderOn: Bool
    
    var body: some View {
        HStack{
            DatePicker(
                "Set Notification:",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .fixedSize()
            Toggle("", isOn: $isReminderOn)
                .fixedSize()
        }
    }
}

#Preview {
    @Previewable @State var selectedTime: Date = Date()
    @Previewable @State var isReminderOn: Bool = false
    
    let viewModel = DayPageViewModel(date: Date(), authManager: AuthManager(firestoreManager: FirestoreManager()), firestoreManager: FirestoreManager(), scrollManager: ScrollManager(), isEditable: false)
    ZStack {
        BackgroundCardView(viewModel: viewModel, isFocused: false)
        ReminderView(selectedTime: $selectedTime, isReminderOn: $isReminderOn)
            //.frame(width: 300)
    }
}
