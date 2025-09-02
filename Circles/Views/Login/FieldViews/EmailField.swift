//
//  EmailField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct EmailField: View {
    @Binding var email: String
    @FocusState.Binding var focusedField: FieldFocus?
    var body: some View {
        TextField("Email", text: $email)
            .focused($focusedField, equals: .email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .foregroundColor(.fakeBlack)
            .padding(18)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.fakeBlack, lineWidth: 2)
            )
            .cornerRadius(30)
            .shadow(radius: 4)
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @FocusState var focusedField: FieldFocus?
    EmailField(email: $email, focusedField: $focusedField)
}
