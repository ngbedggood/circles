//
//  ToastView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 20/07/2025.
//

import SwiftUI

struct ToastView: View {

    @Binding var isShown: Bool
    var type: ToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)

    var body: some View {
        VStack {
            Spacer()
                VStack {
                    HStack {
                        Image(systemName: type.iconFileName)
                            .foregroundColor(type.themeColor)
                            .font(.system(size: 24))
                        VStack(alignment: .leading) {
                            //Text(title)
                            Text(message)
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Button {
                            isShown = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.black)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .shadow(radius: 8)

                    //.padding()
                )
                .padding(24)
                .opacity(isShown ? 1 : 0)
                .offset(y: isShown ? 0 : 300)
                .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3), value: isShown)
                .onChange(of: isShown) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isShown = false
                    }
                }
        }
        .ignoresSafeArea()

    }
}

extension View {
    func toast(isShown: Binding<Bool>, type: ToastStyle, title: String, message: String) -> some View {
        
        ZStack {
            self
            ToastView(isShown: isShown, type: type, title: title, message: message, onCancelTapped: {})
        }
    }
}

#Preview {
    struct ToastPreviewWrapper: View {
        @State private var isShown = true

        var body: some View {
//            ToastView(
//                isShown: $isShown,
//                type: .success,
//                title: "Success:",
//                message: "Updated display name successfully!",
//                onCancelTapped: {}
//            )
            VStack{}
                .toast(
                    isShown: $isShown,
                    type: .success,
                    title: "Success:",
                    message: "Updated display name successfully!"
                )
        }
    }

    return ToastPreviewWrapper()
}
