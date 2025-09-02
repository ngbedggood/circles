//
//  PasswordField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 09/08/2025.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @FocusState.Binding var focusedField: FieldFocus?
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            Group {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .keyboardType(.asciiCapable)
                        .textContentType(.password)
                        .focused($focusedField, equals: .plain)
                } else {
                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .secure)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            
            Button {
                let wasFocused = focusedField
                isPasswordVisible.toggle()
                if wasFocused != nil {
                    focusedField = isPasswordVisible ? .plain : .secure
                }
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.fakeBlack)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 12)
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
    @Previewable @State var displayName: String = ""
    @Previewable @FocusState var focusedField: FieldFocus?
    PasswordField(password: $displayName, focusedField: $focusedField)
}
