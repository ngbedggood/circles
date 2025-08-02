//
//  ToastView.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 20/07/2025.
//

import SwiftUI

struct ToastView: View {

    @Binding var isShown: Bool
    @State private var internalToastID = UUID()
    var type: ToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    @State private var toastDismissTask: Task<Void, Never>? = nil

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(maxWidth: 330, maxHeight: 50)
                    .shadow(radius: 8)
                    .padding(24)
            
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
                    .frame(maxWidth: 300, maxHeight: 50)
                }
            }
            .drawingGroup()
            .opacity(isShown ? 1 : 0)
            .offset(y: isShown ? -10 : 300)
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3), value: isShown)
            .onChange(of: isShown) { _, newValue in
                if newValue {
                    internalToastID = UUID()
                    let capturedID = internalToastID

                    // Cancel any existing task
                    toastDismissTask?.cancel()

                    toastDismissTask = Task {
                        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                        if Task.isCancelled { return }

                        if internalToastID == capturedID {
                            await MainActor.run {
                                isShown = false
                            }
                        }
                    }
                } else {
                    // If manually dismissed, cancel task
                    toastDismissTask?.cancel()
                    toastDismissTask = nil
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
