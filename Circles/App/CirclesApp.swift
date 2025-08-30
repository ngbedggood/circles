//
//  CirclesApp.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 22/06/2025.
//

import FirebaseCore
import FirebaseMessaging
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

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    weak var authManager: AuthManager?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Retrieve device token and establish link with Firebase Cloud Messaging
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
        }
        
    // Retrieve FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = Messaging.messaging().fcmToken {
            //print("fcm", fcmToken)
            Task { await authManager?.uploadFCMToken(fcmToken) }
        }
    }
    
    // Lock screen orientation
    func application(
        _ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Handling local notification scheduling
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct CirclesApp: App {
    
    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager: AuthManager
    @StateObject var firestoreManager: FirestoreManager
    @StateObject var streakManager: StreakManager
    @StateObject var scrollManager = ScrollManager()
    @StateObject var notificationManager = NotificationManager()

    init() {
        FirebaseApp.configure()
        UIView.appearance().overrideUserInterfaceStyle = .light
        UILabel.appearance().font = UIFont(name: "Satoshi Variable", size: 17)
        let firestore = FirestoreManager()
        let auth = AuthManager(firestoreManager: firestore)
        let streak = StreakManager(authManager: auth, firestoreManager: firestore)
        _firestoreManager = StateObject(wrappedValue: firestore)
        _authManager = StateObject(wrappedValue: auth)
        _streakManager = StateObject(wrappedValue: streak)
        delegate.authManager = auth
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(firestoreManager)
                .environmentObject(streakManager)
                .environmentObject(scrollManager)
                .environmentObject(notificationManager)
                .font(.satoshi(.body))
                .onOpenURL { url in
                    Task { await authManager.handleIncomingURL(url: url) }
                }
                .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task {
                        await streakManager.manageStreak(isNewEntry: false)
                        print("Checking streak in background...")
                    }
                }
            }
        }
    }
}
