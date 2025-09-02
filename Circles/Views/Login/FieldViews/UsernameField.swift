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
            text: $username
        )
        .focused($focusedField, equals: .username)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onChange(of: username) { _, newValue in
            var filtered = newValue
                .lowercased()
                .filter { ($0.isLetter && $0.isLowercase) || $0 == "_" }
            
            if filtered.count > 16 {
                filtered = String(filtered.prefix(16))
            }
            
            if filtered != newValue {
                username = filtered
            }
        }
        .foregroundColor(.fakeBlack)
        .padding(18)
        .frame(height: 60)
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
    @Previewable @State var username: String = ""
    @Previewable @FocusState var focusedField: FieldFocus?
    UsernameField(
        username: $username,
        focusedField: $focusedField
    )
}
