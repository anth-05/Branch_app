import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func scheduleReminder(for task: TaskItem) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [task.notificationID.uuidString])

        guard let reminderDate = task.reminderDate, reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Branch reminder"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.notificationID.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelReminder(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.notificationID.uuidString])
    }
}
