//
//  CirclesApp.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import FirebaseCore
import SwiftUI

struct GlobalFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Satoshi Variable", size: 17))
            .environment(\.font, .custom("Satoshi Variable", size: 17))
    }
}

extension View {
    func globalSatoshiFont() -> some View {
        self.modifier(GlobalFontModifier())
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct CirclesApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var firestoreManager = FirestoreManager()
    @StateObject var authManager = AuthManager()
    @StateObject var scrollManager = ScrollManager()

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
        UILabel.appearance().font = UIFont(name: "Satoshi Variable", size: 17)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(firestoreManager)
                .environmentObject(scrollManager)
                .onAppear {
                    authManager.setFirestoreManager(firestoreManager)
                }
                .font(.satoshi(.body))
                .onOpenURL { url in
                    Task {
                        await authManager.handleIncomingURL(url: url)
                    }
                }
        }
    }
}
