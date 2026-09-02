//
//  NotificationManager.swift
//  Bailanysta
//

import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let messageCount = 8
    private let scheduleDays = 14

    private init() {}

    // MARK: - Public

    func requestPermissionAndSchedule() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.schedule()
        }
    }

    func rescheduleIfNeeded() {
        center.getPendingNotificationRequests { [weak self] pending in
            guard pending.count < 7 else { return }
            self?.schedule()
        }
    }

    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Private

    private func schedule() {
        center.removeAllPendingNotificationRequests()

        for day in 0..<scheduleDays {
            let index = (day % messageCount) + 1

            let content = UNMutableNotificationContent()
            content.title = "Notification.\(index).Title".localized
            content.body  = "Notification.\(index).Body".localized
            content.sound = .default

            var components = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
            )
            components.hour = 21
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            center.add(UNNotificationRequest(identifier: "reminder.\(day)", content: content, trigger: trigger))
        }
    }
}
