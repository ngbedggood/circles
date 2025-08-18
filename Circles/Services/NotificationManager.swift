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
    
    private let dailyReminderIdentifier = "dailyReminder"
    private let tomorrowOnlyReminderIdentifier = "dailyReminder_tomorrow"
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
            scheduleRepeatingReminder(selectedTime: selectedTime)
        } else {
            cancelAllReminders()
        }
    }
    
    private func cancelReminderNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        print("Cancelled daily reminder notifications")
    }
    
    // Method to call when saving and deleting entries to ensure notifications are in sync with mood being present
    //@MainActor
    func syncNotificationStateWithMoodData(hasTodayMood: Bool) {
        let isReminderOn = UserDefaults.standard.bool(forKey: "reminderOn")
        
        guard isReminderOn else {
            cancelReminderNotification()
            return
        }
        
        guard let reminderTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date else {
            print("No reminder time set")
            return
        }
        
        if hasTodayMood {
            // User has mood today - check if we need to cancel today's notification
            print("[Notification Manager]: Cancelling today notifcation.")
            scheduleTomorrowOnlyNotification(selectedTime: reminderTime)
        } else {
            // User doesn't have mood - ensure recurring reminder is active
            scheduleRepeatingReminder(selectedTime: reminderTime)
            print("[Notification Manager]: Keeping active scheduled reminder.")
        }
    }
    
    private func scheduleRepeatingReminder(selectedTime: Date) {
        cancelAllReminders()
        
        guard hasPermission else {
            print("No notification permission")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Hey there :)"
        content.body = "Don't forget to log your mood for the day!"
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("Scheduled repeating daily reminder at \(selectedTime)")
    }
    
    private func scheduleTomorrowOnlyNotification(selectedTime: Date) {
        cancelAllReminders()
        
        guard hasPermission else {
            print("No notification permission")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let tomorrowReminderTime = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: tomorrow
              ) else {
            print("Failed to compute tomorrow reminder time")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Hey there :)"
        content.body = "Don't forget to log your mood for the day!"
        content.userInfo = ["type": "tomorrowOnly"] // so delegate knows
        
        var tomorrowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: tomorrowReminderTime)
        tomorrowComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrowComponents, repeats: false)
        let request = UNNotificationRequest(identifier: tomorrowOnlyReminderIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        debugPrintPendingNotifications()
        print("Scheduled one-off reminder for tomorrow at \(tomorrowReminderTime)")
    }
    
    private func cancelAllReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [dailyReminderIdentifier, tomorrowOnlyReminderIdentifier]
        )
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
