//
//  DisplayNameField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct DisplayNameField: View {
    @Binding var displayName: String
    @FocusState.Binding var focusedField: FieldFocus?
    var body: some View {
        TextField("Display Name", text: $displayName)
            .focused($focusedField, equals: .displayname)
        .disableAutocorrection(true)
        .foregroundColor(.black.opacity(0.75))
        .padding(18)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(radius: 4)
    }
}

#Preview {
    @Previewable @State var displayName: String = ""
    @Previewable @FocusState var focusedField: FieldFocus?
    UsernameField(
        username: $displayName,
        focusedField: $focusedField
    )
}
