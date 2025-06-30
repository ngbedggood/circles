//
//  CirclesApp.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CirclesApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var firestoreManager = FirestoreManager()
    @StateObject var authManager = AuthManager()

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(firestoreManager)
                .onAppear {
                    authManager.setFirestoreManager(firestoreManager)
                }
        }
    }
}
