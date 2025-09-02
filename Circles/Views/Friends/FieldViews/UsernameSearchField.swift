//
//  UsernameSearchField.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 02/09/2025.
//

import SwiftUI

struct UsernameSearchField: View {
    
    @Binding var searchQuery: String
    var onSubmit: () -> Void
    @FocusState.Binding var isFocused: Bool
        
    
    var body: some View {
        HStack {
            TextField("Search Username", text: $searchQuery)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchQuery) { _, newValue in
                    var filtered = newValue
                        .lowercased()
                        .filter { ($0.isLetter && $0.isLowercase) || $0 == "_" }
                    
                    if filtered.count > 16 {
                        filtered = String(filtered.prefix(16))
                    }
                    
                    if filtered != newValue {
                        searchQuery = filtered
                    }
                }
                .foregroundColor(.fakeBlack)
                .padding(18)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    onSubmit()
                }
            //.background(.white)

            Button(action: {
                isFocused = false
                onSubmit()
            }) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.fakeBlack)
                    .padding(.horizontal, 12)
            }
        }
    }
}

#Preview {
    @Previewable @State var searchQuery: String = ""
    @Previewable @FocusState var isFocused
    
    UsernameSearchField(
        searchQuery: $searchQuery, onSubmit: {}, isFocused: $isFocused)
}
