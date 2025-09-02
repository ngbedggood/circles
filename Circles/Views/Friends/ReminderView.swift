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
        VStack{
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
            Text("(Reminders start from tomorrow)")
                .font(.satoshi(size: 12))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    @Previewable @State var selectedTime: Date = Date()
    @Previewable @State var isReminderOn: Bool = false
    ZStack {
        ReminderView(selectedTime: $selectedTime, isReminderOn: $isReminderOn)
            //.frame(width: 300)
    }
}
