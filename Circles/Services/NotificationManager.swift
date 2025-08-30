//
//  NotificationManager.swift
//  Circles
//
//  Created by Nathaniel Bedggood on 04/08/2025.
//

import Foundation
import UserNotifications

//@MainActor
class NotificationManager: ObservableObject{
    @Published private(set) var hasPermission = false
    private let reminderIdentifierPrefix = "daily-mood-reminder"
    private var hasMood: Bool = false
    
    init() {
        Task {
            await getAuthStatus()
        }
    }
    
    func requestAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
             await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    @MainActor
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
    
    // Reminder Notification related
    func updateReminderNotification(isReminderOn: Bool, selectedTime: Date) {
        UserDefaults.standard.set(isReminderOn, forKey: "reminderOn")
        UserDefaults.standard.set(selectedTime, forKey: "reminderTime")
        if isReminderOn {
            scheduleNextBatchOfReminders(forTime: selectedTime)
        } else {
            cancelAllMoodReminders()
        }
    }
    
    func scheduleNextBatchOfReminders(forTime date: Date, forNext days: Int = 3) {
        // Cancel first
        cancelAllMoodReminders()

        let content = UNMutableNotificationContent()
        content.title = "Hey there :)"
        content.body = "Don't forget to log your mood for the day."
        content.sound = .default

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        // Create notifications for next however many days
        for i in 1...days {
            guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "\(reminderIdentifierPrefix)-\(date.timeIntervalSince1970)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification for day \(i): \(error.localizedDescription)")
                }
            }
        }
        print("\(days) reminders have been scheduled starting from tomorrow.")
    }
    
    func cancelAllMoodReminders() {
        let center = UNUserNotificationCenter.current()
        // Find and cancel all pending notificationsa
        center.getPendingNotificationRequests { requests in
            let identifiersToCancel = requests
                .filter { $0.identifier.hasPrefix(self.reminderIdentifierPrefix) }
                .map { $0.identifier }
            
            if !identifiersToCancel.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
                print("Cancelled \(identifiersToCancel.count) pending mood reminders.")
            }
        }
    }
    
    func debugPrintPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending Notifications (\(requests.count)):")
            for request in requests {
                print("Identifier: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("Next trigger date: \(date)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("Time interval: \(trigger.timeInterval) seconds")
                    print("Repeats: \(trigger.repeats)")
                } else {
                    print("Trigger: \(String(describing: request.trigger))")
                }
//                if let body = request.content.body as String? {
//                    print("Body: \(body)")
//                }
            }
        }
    }
    
}
