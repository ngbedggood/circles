//
//  UsernameField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct UsernameField: View {
    @Binding var username: String
    @FocusState.Binding var focusedField: FieldFocus?
    var body: some View {
        TextField(
            "Username",
            text: Binding(
                get: { username },
                set: { newValue in
                    username = newValue.lowercased()
                }
            )
        )
        .focused($focusedField, equals: .username)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .foregroundColor(.fakeBlack)
        .padding(18)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(radius: 4)
    }
}

#Preview {
    @Previewable @State var username: String = ""
    @Previewable @FocusState var focusedField: FieldFocus?
    UsernameField(
        username: $username,
        focusedField: $focusedField
    )
}
